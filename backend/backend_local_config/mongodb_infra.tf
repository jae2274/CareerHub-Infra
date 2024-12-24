locals {
  mongodb_infra_backend                = data.terraform_remote_state.backend.outputs.mongodb_infra_backend
  mongodb_infra_backend_bucket         = local.mongodb_infra_backend.bucket
  mongodb_infra_backend_region         = local.mongodb_infra_backend.region
  mongodb_infra_backend_encrypt        = local.mongodb_infra_backend.encrypt
  mongodb_infra_backend_dynamodb_table = local.mongodb_infra_backend.dynamodb_table

  mongodb_infra_backend_file_without_prefix = "backend.tf"
  mongodb_infra_backend_file                = "${local.prefix}${local.mongodb_infra_backend_file_without_prefix}"

}

resource "local_file" "mongodb_backend_config" {
  filename = "${local.terraform_root_dir}mongodb_infra/${local.mongodb_infra_backend_file}"
  content  = <<EOF
terraform {
  backend "s3" {
    bucket = "${local.mongodb_infra_backend_bucket}"
    key = "${local.key}"
    region = "${local.mongodb_infra_backend_region}"
    encrypt= ${local.backend_encrypt}
    dynamodb_table = "${local.mongodb_infra_backend_dynamodb_table}"
  }
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

locals {
  env                 = module.git_branch.env
  prefix              = module.git_branch.prefix
  branch              = module.git_branch.branch
}

//CHECK BACKEND CONFIG FILE
data "local_file" "check_remote_state_config" {
  filename = "$${local.env}-${local.mongodb_infra_backend_file_without_prefix}"
}

data "terraform_remote_state" "network_infra" {
  backend = "s3"

  config = {
    bucket = "${local.network_infra_backend_bucket}"
    key = "${local.key}"
    region = "${local.network_infra_backend_region}"
    encrypt= ${local.network_infra_backend_encrypt}
  }
}
EOF
}


