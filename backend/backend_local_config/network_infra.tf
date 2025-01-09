locals {
  network_infra_backend                = data.terraform_remote_state.backend.outputs.network_infra_backend
  network_infra_backend_bucket         = local.network_infra_backend.bucket
  network_infra_backend_region         = local.network_infra_backend.region
  network_infra_backend_encrypt        = local.network_infra_backend.encrypt
  network_infra_backend_dynamodb_table = local.network_infra_backend.dynamodb_table

  network_infra_backend_file_without_prefix = "backend.tf"
  network_infra_backend_file                = "${local.prefix}${local.network_infra_backend_file_without_prefix}"

}


resource "local_file" "network_backend_config" {
  filename = "${local.terraform_root_dir}network_infra/${local.network_infra_backend_file}"
  content  = <<EOF
terraform {
  backend "s3" {
    bucket = "${local.network_infra_backend_bucket}"
    key = "${local.key}"
    region = "${local.network_infra_backend_region}"
    encrypt= ${local.network_infra_backend_encrypt}
    dynamodb_table = "${local.network_infra_backend_dynamodb_table}"
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
  filename = "$${local.env}-${local.network_infra_backend_file_without_prefix}"
}
EOF
}


