
generate "aws_provider" {
    path = "aws_provider.tf"
    if_exists = "overwrite_terragrunt"
    #if_exists = "skip"
    contents = <<EOF
provider "aws" {
  assume_role {
    role_arn = var.terraform_role
    tags = {
      env = var.env
    }
  }

  default_tags {
    tags = {
      env = var.env
    }
  }

  region = var.region
}
EOF
}