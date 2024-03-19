data "aws_caller_identity" "current" {}


module "k8s_infra" {
  source = "./k8s_infra"

  vpc_id       = local.vpc_id
  cluster_name = local.prefix_service_name

  ecrs = [for key, ecr in toset([local.dataprovider_ecr, local.dataprocessor_ecr]) : ecr]

  master = {
    instance_type = "t4g.small"
    subnet_id     = local.public_subnets[local.public_subnet_key_1].id
  }

  node_ports = [local.node_port]

  workers = {
    instance_type = "t4g.small"
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


locals {
  master_ip            = module.k8s_infra.master_public_ip
  worker_ips           = module.k8s_infra.worker_public_ips
  kubeconfig_secret_id = module.k8s_infra.kubeconfig_secret_id
}
