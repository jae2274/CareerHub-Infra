remote_state {
    backend = "local"
    generate = {
        path = "backend.tf"
        if_exists = "overwrite_terragrunt"
    }

    config = {
        path = "${path_relative_to_include()}/terraform.tfstate"
    }
}



locals {
  region = "ap-south-1"
  service_name = "careerhub"
  terraform_role = "arn:aws:iam::986069063944:role/terraform_role"
}

generate "provider" {
    path = "provider.tf"
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

// GET CURRENT BRANCH
module "git_branch" {
  source = "github.com/jae2274/terraform_modules/git_branch"
  branch_map = {
    prod = {
      prefix = ""
      env    = "prod"
    }
  }
  prefix_separator = "-"
}
// END CURRENT BRANCH

resource "terraform_data" "validate_env" {
  lifecycle {
    precondition {
      condition = module.git_branch.env == var.env
      error_message = "Different environments, please execute set_backend_config.sh"
    }
  }
}

locals {
  prefix = module.git_branch.prefix
}

EOF
}

