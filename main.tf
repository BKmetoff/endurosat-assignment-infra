locals {
  org                 = "BKmetoff"
  resource_identifier = "endurosat-assignment"
  docker_image_name   = local.resource_identifier
  docker_image_tag    = "latest"
  environments        = ["staging", "production"]
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }

  backend "s3" {
    key     = "endurosat-assignment-tf-state-prod.tfstate"
    bucket  = "endurosat-assignment-tf-state-prod"
    region  = "eu-west-1"
    encrypt = true
    acl     = "bucket-owner-full-control"
  }
}


provider "aws" {
  profile = "default"
  region  = var.aws_region
}

module "vpc" {
  source = "./modules/VPC"

  # outputs 'endurosat' to fit within the 32 char limit
  # of the 'name' property of AWS resources
  name = substr(local.resource_identifier, 0, 9)

  environments = local.environments
  aws_region   = var.aws_region
  subnet_count = 2
}

module "ecr" {
  source = "./modules/ECR"

  name         = local.resource_identifier
  environments = local.environments

  github_actions = {
    organization = local.org
    repository   = local.resource_identifier
  }
}

data "aws_caller_identity" "current" {}

module "ecs" {
  source = "./modules/ECS"

  environments = local.environments

  private_subnet_ids              = module.vpc.private_subnet_ids
  load_balancer_target_group_ids  = module.vpc.load_balancer_target_group_ids
  load_balancer_security_group_id = module.vpc.load_balancer_security_group_id
  vpc_id                          = module.vpc.vpc_id

  aws_region    = var.aws_region
  account_id    = data.aws_caller_identity.current.account_id
  service_count = 1

  container_port = 8000

  container_resources = {
    cpu    = 1024
    memory = 2048
  }

  docker_image = {
    name = local.docker_image_name,
    tag  = local.docker_image_tag
  }

  depends_on = [module.ecr, module.vpc]
}
