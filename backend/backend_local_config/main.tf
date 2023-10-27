

module "git_branch" {
  source = "github.com/jae2274/terraform_modules/git_branch"
  branch_map = {
    main = {
      prefix = ""
      env = "prod"
    }
  }
  prefix_separator = "-"
}

locals {
  prefix = module.git_branch.prefix

  terraform_root_dir = "${path.root}/../../"
  project_root_dir = local.terraform_root_dir
  backend_file_without_prefix = "backend.tf"

  backend_file = "${local.prefix}${local.backend_file_without_prefix}"
  key = "${local.prefix}terraform.tfstate"
}

data terraform_remote_state backend{
  backend = "local"

  config = {
    path = "${local.terraform_root_dir}/backend/backend_infra/terraform.tfstate"
  }
}


locals {
  backend = data.terraform_remote_state.backend.outputs.backend
}

resource "local_file" "backend_config" {
  filename = "${local.terraform_root_dir}infra/${local.backend_file}"
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
// This file is generated automatically by backend/backend_local_config and should not be modified manually
// 이 파일은 backend/backend_local_config에 의해 자동으로 생성되며 수동으로 수정하지 마십시오.

// 이와 같이 해당 파일을 생성하는 이유는, terraform backend의 속성에 상수 이외의 변수를 사용할 수 없기 때문입니다.
EOF
}