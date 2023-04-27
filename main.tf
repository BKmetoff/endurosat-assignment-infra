locals {
  region                   = "eu-west-1"
  environment              = "production"
  cluster_name             = "${local.region}-${local.environment}"
  github_oidc_provider_arn = "arn:aws:iam::270286309069:oidc-provider/token.actions.githubusercontent.com"
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
  source       = "./modules/vpc"
  cluster_name = local.cluster_name
  region       = local.region
}
