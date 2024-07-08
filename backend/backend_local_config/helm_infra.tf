locals {
  helm_infra_backend                = data.terraform_remote_state.backend.outputs.helm_infra_backend
  helm_infra_backend_bucket         = local.helm_infra_backend.bucket
  helm_infra_backend_region         = local.helm_infra_backend.region
  helm_infra_backend_encrypt        = local.helm_infra_backend.encrypt
  helm_infra_backend_dynamodb_table = local.helm_infra_backend.dynamodb_table

  helm_infra_backend_file_without_prefix = "backend.tf"
  helm_infra_backend_file                = "${local.prefix}${local.helm_infra_backend_file_without_prefix}"

}

resource "local_file" "infra_remote_config" {
  filename = "${local.terraform_root_dir}helm_infra/${local.helm_infra_backend_file}"
  content  = <<EOF
terraform {
  backend "s3" {
    bucket = "${local.helm_infra_backend_bucket}"
    key = "${local.key}"
    region = "${local.helm_infra_backend_region}"
    encrypt= ${local.backend_encrypt}
    dynamodb_table = "${local.helm_infra_backend_dynamodb_table}"
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
  filename = "$${local.prefix}${local.helm_infra_backend_file_without_prefix}"
}
EOF
}


