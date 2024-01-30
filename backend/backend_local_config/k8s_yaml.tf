locals {
  infra_remote_state_without_prefix = "infra_state.tf"

  infra_remote_state = "${local.prefix}${local.infra_remote_state_without_prefix}"
}

resource "local_file" "infra_remote_config" {
  filename = "${local.terraform_root_dir}k8s_infra/${local.infra_remote_state}"
  content  = <<EOF
data "terraform_remote_state" "infra" {
  backend = "s3"

  config = {
    bucket = "${local.backend_bucket}"
    region = "${local.backend_region}"
    key    = "${local.key}"
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
  prefix              = module.git_branch.prefix
  branch              = module.git_branch.branch
}

//CHECK BACKEND CONFIG FILE
data "local_file" "check_remote_state_config" {
  filename = "${local.infra_remote_state}"
}
EOF
}


