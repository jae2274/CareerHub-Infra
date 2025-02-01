terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.84.0"
    }
    mongodbatlas = {
      source  = "mongodb/mongodbatlas"
      version = "1.14.0"
    }
  }
}


locals {
  service_name        = "careerhub"
  prefix_service_name = "${var.prefix}${local.service_name}"
}
