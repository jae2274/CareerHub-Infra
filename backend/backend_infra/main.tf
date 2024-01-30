resource "null_resource" "git_merge_ours_driver" {
  provisioner "local-exec" {
    command = "git config merge.ours.driver true"
  }
}

locals {
  backend_region = "ap-northeast-2"
}
provider "aws" {
  region = local.backend_region
}
