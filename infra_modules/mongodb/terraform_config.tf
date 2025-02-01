terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.81.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.5.1"
    }
    mongodbatlas = {
      source  = "mongodb/mongodbatlas",
      version = "1.14.0"
    }
  }
}

locals {
  service_name        = "careerhub"
  prefix_service_name = "${var.prefix}${local.service_name}"
}

provider "local" {
}


