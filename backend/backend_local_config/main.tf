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

locals {
  terraform_root_dir = "${path.root}/../../"
}

resource "local_file" "env_yaml" {
  filename = "${local.terraform_root_dir}careerhub_infra/env.yaml"

  content = <<EOF
env: "${module.git_branch.env}"
prefix: "${module.git_branch.prefix}"
branch: "${module.git_branch.branch}"
EOF
}
