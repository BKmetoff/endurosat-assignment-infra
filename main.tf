locals {
  region                   = "eu-west-1"
  environment              = "production"
  cluster_name             = "${local.region}-${local.environment}"
  github_oidc_provider_arn = "arn:aws:iam::936892409162:oidc-provider/token.actions.githubusercontent.com"
  org                      = "bkmetoff"
  repo                     = "endurosat-assignment-infra"
  role_name_suffix         = local.repo
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

# module "gh_actions" {
#   source = "./modules/github_actions"

#   role_name_suffix = local.role_name_suffix
#   gh_org           = local.org
#   gh_repo          = local.repo
#   oidc_arn         = local.github_oidc_provider_arn
# }

module "aws_ecr_repository" {
  source = "./modules/ECR"

  name = local.repo
  github_actions = {
    oidc_arn     = local.github_oidc_provider_arn,
    organization = local.org,
    repository   = local.repo
  }

}
