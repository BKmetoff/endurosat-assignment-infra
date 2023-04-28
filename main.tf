locals {
  region = "eu-west-1"
  org    = "BKmetoff"
  repo   = "endurosat-assignment"
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


module "aws_ecr_repository" {
  source = "./modules/ECR"

  name = local.repo
  github_actions = {
    organization = local.org,
    repository   = local.repo
  }
}
