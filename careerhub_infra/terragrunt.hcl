locals {
  env_vars = yamldecode(file("env.yaml"))
  env = local.env_vars.env
  prefix = local.env_vars.prefix

  secret_vars = yamldecode(file("secret.yaml"))

  region = local.secret_vars.region
  service_name = "careerhub"
  terraform_role = local.secret_vars.terraform_role

  backend_config = local.secret_vars.backend_config
}

remote_state {
    backend = "s3"
    generate = {
        path = "backend.tf"
        if_exists = "overwrite_terragrunt"
    }

    config = {
      bucket = local.backend_config.bucket
      region = local.backend_config.region
      encrypt = local.backend_config.encrypt
      dynamodb_table = local.backend_config.dynamodb_table
      key = "${local.env_vars.env}/${path_relative_to_include()}/terraform.tfstate"
    }
}

generate "env_validator" {
    path = "env_validator.tf"
    if_exists = "overwrite_terragrunt"
    contents = <<EOF
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
      error_message = "Environment and branch are not matched each other, please execute set_backend_config.sh"
    }
  }
}
EOF
}