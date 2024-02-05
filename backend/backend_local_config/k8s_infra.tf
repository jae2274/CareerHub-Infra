locals {
  k8s_backend                = data.terraform_remote_state.backend.outputs.k8s_backend
  k8s_backend_bucket         = local.k8s_backend.bucket
  k8s_backend_region         = local.k8s_backend.region
  k8s_backend_encrypt        = local.k8s_backend.encrypt
  k8s_backend_dynamodb_table = local.k8s_backend.dynamodb_table

  k8s_backend_file_without_prefix = "backend.tf"
  k8s_backend_file                = "${local.prefix}${local.k8s_backend_file_without_prefix}"

}

resource "local_file" "infra_remote_config" {
  filename = "${local.terraform_root_dir}k8s_infra/${local.k8s_backend_file}"
  content  = <<EOF
terraform {
  backend "s3" {
    bucket = "${local.k8s_backend_bucket}"
    key = "${local.key}"
    region = "${local.k8s_backend_region}"
    encrypt= ${local.backend_encrypt}
    dynamodb_table = "${local.k8s_backend_dynamodb_table}"
  }
}

// GET CURRENT BRANCH
module "git_branch" {
  source = "github.com/jae2274/terraform_modules/git_branch"
  branch_map = {
    main = {
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
  filename = "$${local.prefix}${local.k8s_backend_file_without_prefix}"
}

data "terraform_remote_state" "infra" {
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


