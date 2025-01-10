terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.19.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.5.1"
    }
    ansible = {
      source  = "ansible/ansible"
      version = "1.3.0"
    }
  }
}

locals {
  service_name        = "careerhub"
  prefix_service_name = "${local.prefix}${local.service_name}"
}

provider "local" {
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

  region = local.region
}


provider "ansible" {}
