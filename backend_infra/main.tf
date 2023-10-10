resource "null_resource" "git_merge_ours_driver" {
  provisioner "local-exec" {
    command = "git config merge.ours.driver true"
  }
}

locals {
  backend = {
    bucket         = "careerhub-infra-tfstate"
    dynamodb_table = "careerhub-infra-tfstate-lock"
    region = "ap-northeast-2"
    encrypt        = true
  }
}

provider "aws" {
  region = local.backend.region
}

module s3_backend{
  source = "../module/s3_backend"
  bucket = local.backend.bucket
  dynamodb_lock_table = local.backend.dynamodb_table
}

output backend {
  value =  merge(local.backend,
      {
        bucket_arn = module.s3_backend.bucket_arn
        dynamodb_table_arn = module.s3_backend.dynamodb_table_arn
      }
    )
}