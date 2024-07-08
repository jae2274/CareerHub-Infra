locals {
  k8s_cluster_infra_backend                = data.terraform_remote_state.backend.outputs.k8s_cluster_infra_backend
  k8s_cluster_infra_backend_bucket         = local.k8s_cluster_infra_backend.bucket
  k8s_cluster_infra_backend_region         = local.k8s_cluster_infra_backend.region
  k8s_cluster_infra_backend_encrypt        = local.k8s_cluster_infra_backend.encrypt
  k8s_cluster_infra_backend_dynamodb_table = local.k8s_cluster_infra_backend.dynamodb_table

  k8s_cluster_infra_backend_file_without_prefix = "backend.tf"
  k8s_cluster_infra_backend_file                = "${local.prefix}${local.k8s_cluster_infra_backend_file_without_prefix}"

}

resource "local_file" "k8s_cluster_backend_config" {
  filename = "${local.terraform_root_dir}k8s_cluster_infra/${local.k8s_cluster_infra_backend_file}"
  content  = <<EOF
terraform {
  backend "s3" {
    bucket = "${local.k8s_cluster_infra_backend_bucket}"
    key = "${local.key}"
    region = "${local.k8s_cluster_infra_backend_region}"
    encrypt= ${local.backend_encrypt}
    dynamodb_table = "${local.k8s_cluster_infra_backend_dynamodb_table}"
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
  filename = "$${local.env}-${local.k8s_cluster_infra_backend_file_without_prefix}"
}
EOF
}


