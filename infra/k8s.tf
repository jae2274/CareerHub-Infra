module "k8s_infra" {
  source = "./k8s_infra"

  vpc_id       = local.vpc_id
  ami          = "ami-077885f59ecb77b84" # ubuntu 22.04 LTS
  cluster_name = local.prefix_service_name

  master = {
    instance_type = "t4g.medium"
    subnet_id     = local.public_subnets[local.public_subnet_key_1].id
  }

  workers = {
    instance_type = "t4g.medium"
    worker = {
      "1" = {
        subnet_id = local.public_subnets[local.public_subnet_key_1].id
      }
      "2" = {
        subnet_id = local.public_subnets[local.public_subnet_key_2].id
      }
    }
  }
}
