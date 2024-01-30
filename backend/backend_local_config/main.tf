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

locals {
  prefix = module.git_branch.prefix

  terraform_root_dir = "${path.root}/../../"
  project_root_dir   = local.terraform_root_dir

  key = "${local.prefix}terraform.tfstate"
}

data "terraform_remote_state" "backend" {
  backend = "local"

  config = {
    path = "${local.terraform_root_dir}/backend/backend_infra/terraform.tfstate"
  }
}
