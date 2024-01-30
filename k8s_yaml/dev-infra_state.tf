data "terraform_remote_state" "infra" {
  backend = "s3"

  config = {
    bucket = "careerhub-infra-tfstate"
    region = "ap-northeast-2"
    key    = "dev-terraform.tfstate"
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
  filename = "dev-infra_state.tf"
}
