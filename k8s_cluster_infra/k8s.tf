data "aws_caller_identity" "current" {}

locals {
  cluster_name = local.prefix_service_name
  ami          = "ami-025a235c91853ccbe" # ubuntu 20.04 LTS arm64
  ecr_domain   = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${local.region}.amazonaws.com"
}


resource "aws_key_pair" "k8s_keypair" {
  key_name   = "${local.cluster_name}-keypair.pem"
  public_key = file(var.ssh_public_key_path)
}

resource "aws_secretsmanager_secret" "k8s_node_private_key" {
  name                    = "${local.cluster_name}-node-private-key"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "k8s_node_private_key_version" {
  secret_id     = aws_secretsmanager_secret.k8s_node_private_key.id
  secret_string = file(var.ssh_private_key_path)
}

module "k8s_infra" {
  source = "./k8s_infra/cluster"

  vpc_id       = local.vpc_id
  cluster_name = local.cluster_name

  ecrs = [{ domain = local.ecr_domain, region = local.region }]

  master = {
    instance_type = "t4g.small"
    subnet_id     = local.public_subnets[local.public_subnet_key_2].id
  }

  ami      = local.ami
  key_name = aws_key_pair.k8s_keypair.key_name
}


locals {
  master_private_ip    = module.k8s_infra.master_private_ip
  master_public_ip     = module.k8s_infra.master_public_ip
  kubeconfig_secret_id = module.k8s_infra.kubeconfig_secret_id
  common_cluster_sg_id = module.k8s_infra.common_cluster_sg_id
}




module "worker_nodes" {
  depends_on = [module.k8s_infra]
  source     = "./k8s_infra/workers"

  node_group_name = "app"
  vpc_id          = local.vpc_id
  cluster_name    = local.cluster_name
  key_name        = aws_key_pair.k8s_keypair.key_name

  common_cluster_sg_id = local.common_cluster_sg_id
  master_ip            = local.master_private_ip
  master_private_key   = file(var.ssh_private_key_path)
  instance_type        = "t4g.small"

  labels = {
    "usage" = "app"
  }

  workers = {
    "3" = {
      subnet_id = local.public_subnets[local.public_subnet_key_1].id
    }
    # "4" = { 
    #   subnet_id = local.public_subnets[local.public_subnet_key_2].id
    # }
  }

  ami                  = local.ami
  ssh_private_key_path = var.ssh_private_key_path
}

# output "inventory_content" {
#   value = module.worker_nodes.inventory_content
# }
# module "monitoring_nodes" {
#   depends_on = [module.k8s_infra]

#   source = "./k8s_infra/workers"

#   node_group_name = "monitoring"
#   vpc_id          = local.vpc_id
#   cluster_name    = local.cluster_name
#   key_name        = aws_key_pair.k8s_keypair.key_name

#   common_cluster_sg_id = local.common_cluster_sg_id
#   master_ip            = local.master_private_ip
#   master_private_key   = tls_private_key.k8s_private_key.private_key_pem
#   instance_type        = "t4g.medium"

#   volume_gb_size = 32

#   labels = {
#     "usage" = "monitoring"
#   }

#   taints = [{
#     key    = "usage"
#     value  = "monitoring"
#     effect = "PreferNoSchedule"
#   }]

#   workers = {
#     "monitoring" = {
#       subnet_id = local.public_subnets[local.public_subnet_key_3].id
#     }
#   }

#   ami = local.ami
# }

output "worker_ips" {
  value = module.worker_nodes.worker_public_ips
}

output "master_public_ip" {
  value = local.master_public_ip
}

output "kubeconfig_secret_id" {
  value = local.kubeconfig_secret_id
}

# output "ansible_playbook_stdout" {
#   value = module.worker_nodes.ansible_playbook_stdout
# }
