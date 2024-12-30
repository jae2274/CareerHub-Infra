locals {
  edge_infra_backend                = data.terraform_remote_state.backend.outputs.edge_infra_backend
  edge_infra_backend_bucket         = local.edge_infra_backend.bucket
  edge_infra_backend_region         = local.edge_infra_backend.region
  edge_infra_backend_encrypt        = local.edge_infra_backend.encrypt
  edge_infra_backend_dynamodb_table = local.edge_infra_backend.dynamodb_table

  edge_infra_backend_file_without_prefix = "backend.tf"
  edge_infra_backend_file                = "${local.prefix}${local.edge_infra_backend_file_without_prefix}"

}


resource "local_file" "edge_backend_config" {
  filename = "${local.terraform_root_dir}edge_infra/${local.edge_infra_backend_file}"
  content  = <<EOF
terraform {
  backend "s3" {
    bucket = "${local.edge_infra_backend_bucket}"
    key = "${local.key}"
    region = "${local.edge_infra_backend_region}"
    encrypt= ${local.edge_infra_backend_encrypt}
    dynamodb_table = "${local.edge_infra_backend_dynamodb_table}"
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
  filename = "$${local.env}-${local.edge_infra_backend_file_without_prefix}"
}

data "terraform_remote_state" "core_infra" {
  backend = "s3"

  config = {
    bucket = "${local.backend_bucket}"
    key = "${local.key}"
    region = "${local.backend_region}"
    encrypt= ${local.backend_encrypt}
  }
}
EOF
}


