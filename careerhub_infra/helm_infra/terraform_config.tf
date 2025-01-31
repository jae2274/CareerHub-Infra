terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.19.0"
    }
  }
}


locals {
  prefix_service_name = "${var.prefix}${var.service_name}"
}
