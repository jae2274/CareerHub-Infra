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
    random = {
      source  = "hashicorp/random"
      version = "3.6.3"
    }
  }
}


locals {
  prefix_service_name = "${var.prefix}${var.service_name}"
}

provider "local" {}

provider "random" {}

