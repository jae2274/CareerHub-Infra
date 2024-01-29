module "k8s_infra" {
  source = "./k8s_infra"

  vpc_id       = local.vpc_id
  ami          = "ami-025a235c91853ccbe" # ubuntu 20.04 LTS
  cluster_name = local.prefix_service_name

  master = {
    instance_type = "t4g.medium"
    subnet_id     = local.public_subnets[local.public_subnet_key_2].id
  }

  workers = {
    instance_type = "t4g.medium"
    worker = {
      "3" = {
        subnet_id = local.public_subnets[local.public_subnet_key_1].id
      }
      "4" = {
        subnet_id = local.public_subnets[local.public_subnet_key_2].id
      }
    }
  }
}
