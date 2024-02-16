terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.19.0"
    }
    mongodbatlas = {
      source  = "mongodb/mongodbatlas"
      version = "1.14.0"
    }
  }
}


locals {
  service_name        = "careerhub"
  prefix_service_name = "${local.prefix}${local.service_name}"
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



