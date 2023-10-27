terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.19.0"
    }
  }
}
// GET CURRENT BRANCH
module "git_branch" {
  source = "github.com/jae2274/terraform_modules/git_branch"
  branch_map = {
    main = {
        prefix = ""
        env = "prod"
    }
  }
  prefix_separator = "-"
}
// END CURRENT BRANCH

locals {
  prefix = module.git_branch.prefix
  branch = module.git_branch.branch
  env = module.git_branch.env
  backend_config_file = "${local.prefix}backend.tf"
  service_name = "career-hub"
}

//CHECK BACKEND CONFIG FILE
data "local_file" "check_backend_config"{
  filename = "${path.root}/${local.backend_config_file}"
}

provider "aws" {
  assume_role {
    role_arn = var.terraform_role
    tags = {
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

module "mongodb_atlas" {
  source = "./mongodb_atlas"

  atlas_key = {
    public_key= var.atlas_key.public_key
    private_key= var.atlas_key.private_key
  }

  mongodb_region = var.region
  project_name = "${local.prefix}${local.service_name}-project"

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