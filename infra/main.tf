terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.19.0"
    }
  }
}
// GET CURRENT BRANCH
module "git_branch" {
  source     = "github.com/jae2274/terraform_modules/git_branch"
  branch_map = {
    main = {
      prefix = ""
      env    = "prod"
    }
  }
  prefix_separator = "-"
}
// END CURRENT BRANCH

locals {
  prefix              = module.git_branch.prefix
  branch              = module.git_branch.branch
  env                 = module.git_branch.env
  backend_config_file = "${local.prefix}backend.tf"
  service_name        = "career-hub"
}

//CHECK BACKEND CONFIG FILE
data "local_file" "check_backend_config" {
  filename = "${path.root}/${local.backend_config_file}"
}

provider "aws" {
  assume_role {
    role_arn = var.terraform_role
    tags     = {
      env = local.env
    }
  }

  default_tags {
    tags = {
      env = local.env
    }
  }

  region = var.region
}

data "aws_availability_zones" "available" {
  state = "available"
}


module "vpc_infra" {
  source = "./vpc_infra"

  vpc_name       = "${local.prefix}${local.service_name}-vpc"
  vpc_cidr_block = "10.0.0.0/16"
  pair_subnets   = {
    "set1" = {
      public_cidr_block  = "10.0.1.0/24"
      private_cidr_block = "10.0.2.0/24"
      az                 = data.aws_availability_zones.available.names[0]
    }
  }
}


module "mongodb_atlas" {
  source = "./mongodb_atlas"

  atlas_key = {
    public_key  = var.atlas_key.public_key
    private_key = var.atlas_key.private_key
  }

  mongodb_region = var.region
  project_name   = "${local.prefix}${local.service_name}-project"

  admin_db_user = {
    username = var.admin_db_user.username
    password = var.admin_db_user.password
  }

  serverless_databases = [
    "${local.prefix}${local.service_name}-db"
  ]

  tags = {
    env = local.env
  }
}

#resource "aws_security_group" "mongodb_security_group" {
#
#}
#
#resource "aws_vpc_endpoint" "ptfe_service" {
#  vpc_id            = module.vpc_infra.vpc.id
#  service_name      = module.mongodb_atlas.privatelink_endpoint_service_name
#  vpc_endpoint_type = "Interface"
#
#  security_group_ids = [
#    aws_security_group.ptfe_service.id,
#  ]
#
#  subnet_ids          = [module.vpc_infra.public_subnet_ids["set1"].id]
#  private_dns_enabled = false
#}