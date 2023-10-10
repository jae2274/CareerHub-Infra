terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.19.0"
    }
  }
}
// GET CURRENT BRANCH
module "git_branch" {
  source = "./module/git_branch"
  branch_to_prefix_map = {
    "main" = ""
  }
  prefix_separator = "-"
}
// END CURRENT BRANCH

locals {
  prefix = module.git_branch.prefix
  branch = module.git_branch.branch
  backend_config_file = "${local.prefix}backend.tf"
}

//CHECK BACKEND CONFIG FILE
data "local_file" "check_backend_config"{
  filename = "${path.root}/${local.backend_config_file}"
}



