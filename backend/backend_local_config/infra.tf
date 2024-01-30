


locals {
  backend                = data.terraform_remote_state.backend.outputs.backend
  backend_bucket         = local.backend.bucket
  backend_region         = local.backend.region
  backend_encrypt        = local.backend.encrypt
  backend_dynamodb_table = local.backend.dynamodb_table

  backend_file_without_prefix = "backend.tf"
  backend_file                = "${local.prefix}${local.backend_file_without_prefix}"
}

resource "local_file" "backend_config" {
  filename = "${local.terraform_root_dir}infra/${local.backend_file}"
  content  = <<EOF
terraform {
  backend "s3" {
    bucket = "${local.backend_bucket}"
    key = "${local.key}"
    region = "${local.backend_region}"
    encrypt= ${local.backend_encrypt}
    dynamodb_table = "${local.backend_dynamodb_table}"
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
data "local_file" "check_backend_config" {
  filename = "${local.backend_file}"
}

// This file is generated automatically by backend/backend_local_config and should not be modified manually
// 이 파일은 backend/backend_local_config에 의해 자동으로 생성되며 수동으로 수정하지 마십시오.

// 이와 같이 해당 파일을 생성하는 이유는, terraform backend의 속성에 상수 이외의 변수를 사용할 수 없기 때문입니다.
EOF
}
