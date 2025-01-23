locals {
  db_infra_backend                = data.terraform_remote_state.backend.outputs.db_infra_backend
  db_infra_backend_bucket         = local.db_infra_backend.bucket
  db_infra_backend_region         = local.db_infra_backend.region
  db_infra_backend_encrypt        = local.db_infra_backend.encrypt
  db_infra_backend_dynamodb_table = local.db_infra_backend.dynamodb_table

  db_infra_backend_file_without_prefix = "backend.tf"
  db_infra_backend_file                = "${local.prefix}${local.db_infra_backend_file_without_prefix}"

}


resource "local_file" "db_backend_config" {
  filename = "${local.terraform_root_dir}db_infra/${local.db_infra_backend_file}"
  content  = <<EOF
terraform {
  backend "s3" {
    bucket = "${local.db_infra_backend_bucket}"
    key = "${local.key}"
    region = "${local.db_infra_backend_region}"
    encrypt= ${local.db_infra_backend_encrypt}
    dynamodb_table = "${local.db_infra_backend_dynamodb_table}"
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
  filename = "$${local.env}-${local.db_infra_backend_file_without_prefix}"
}
EOF
}


