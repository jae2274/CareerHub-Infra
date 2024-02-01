data "aws_caller_identity" "current" {}

module "k8s_infra" {
  source = "./k8s_infra"

  vpc_id       = local.vpc_id
  ami          = "ami-025a235c91853ccbe" # ubuntu 20.04 LTS
  cluster_name = local.prefix_service_name

  ecrs = [for key, ecr in toset([local.dataprovider_ecr, local.dataprocessor_ecr]) : ecr]

  master = {
    instance_type = "t4g.medium"
    subnet_id     = local.public_subnets[local.public_subnet_key_2].id
  }

  workers = {
    instance_type = "t4g.medium"
    worker = {
      "1" = {
        subnet_id = local.public_subnets[local.public_subnet_key_2].id
      }
      "2" = {
        subnet_id = local.public_subnets[local.public_subnet_key_1].id
      }
    }
  }
}

