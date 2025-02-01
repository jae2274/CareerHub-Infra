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
  }
}

locals {
  prefix_service_name = "${var.prefix}${var.service_name}"
}

provider "local" {
}
