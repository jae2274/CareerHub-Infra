

module "git_branch" {
  source = "../module/git_branch"
  branch_to_prefix_map = {
    "main" = ""
  }
  prefix_separator = "-"
}

locals {
  prefix = module.git_branch.prefix

  terraform_root_dir = "${path.root}/../"
  project_root_dir = local.terraform_root_dir
  backend_file_without_prefix = "backend.tf"

  backend_file = "${local.prefix}${local.backend_file_without_prefix}"
  key = "${local.prefix}terraform.tfstate"
}

data terraform_remote_state backend{
  backend = "local"

  config = {
    path = "${local.terraform_root_dir}/backend_infra/terraform.tfstate"
  }
}


locals {
  backend = data.terraform_remote_state.backend.outputs.backend
}

resource "local_file" "backend_config" {
  filename = "${local.terraform_root_dir}${local.backend_file}"
  content = <<EOF
terraform {
  backend "s3" {
    bucket = "${local.backend.bucket}"
    key = "${local.key}"
    region = "${local.backend.region}"
    encrypt= ${local.backend.encrypt}
    dynamodb_table = "${local.backend.dynamodb_table}"
  }
}
EOF
}

resource "local_file" "gitattributes"{
  filename = "${local.project_root_dir}.gitattributes"
  content = <<EOF
*${local.backend_file_without_prefix} merge=ours
EOF
}