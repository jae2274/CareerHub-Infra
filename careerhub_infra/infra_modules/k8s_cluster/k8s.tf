data "aws_caller_identity" "current" {}

locals {
  cluster_name = local.prefix_service_name
  ami          = "ami-025a235c91853ccbe" # ubuntu 20.04 LTS arm64
  ecr_domain   = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.region}.amazonaws.com"

  log_dir_path = "${path.root}/logs"
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

  region       = var.region
  vpc_id       = var.vpc_id
  cluster_name = local.cluster_name

  ecrs = [{ domain = local.ecr_domain, region = var.region }]

  master = {
    instance_type = "t4g.small"
    subnet_id     = var.public_subnet_ids[var.public_subnet_key_2]
  }

  ami      = local.ami
  key_name = aws_key_pair.k8s_keypair.key_name

  ssh_private_key_path = var.ssh_private_key_path

  log_dir_path = local.log_dir_path
}

locals {
  master_private_ip    = module.k8s_infra.master_private_ip
  master_public_ip     = module.k8s_infra.master_public_ip
  kubeconfig_secret_id = module.k8s_infra.kubeconfig_secret_id
  common_cluster_sg_id = module.k8s_infra.common_cluster_sg_id
}




module "worker_nodes" {
  source = "./k8s_infra/workers"

  node_group_name = "app"
  region          = var.region
  vpc_id          = var.vpc_id
  cluster_name    = local.cluster_name
  key_name        = aws_key_pair.k8s_keypair.key_name

  common_cluster_sg_id = local.common_cluster_sg_id
  master_ip            = local.master_public_ip

  instance_type = "t4g.small"

  labels = {
    "usage" = "app"
  }

  workers = {
    "3" = {
      subnet_id = var.public_subnet_ids[var.public_subnet_key_1]
    }
    "4" = {
      subnet_id = var.public_subnet_ids[var.public_subnet_key_2]
    }
  }

  ami                  = local.ami
  ssh_private_key_path = var.ssh_private_key_path
  log_dir_path         = local.log_dir_path
  depends_on           = [module.k8s_infra]
}

# output "inventory_content" {
#   value = module.worker_nodes.inventory_content
# }
module "monitoring_nodes" {
  source = "./k8s_infra/workers"

  node_group_name = "monitoring"
  region          = var.region
  vpc_id          = var.vpc_id
  cluster_name    = local.cluster_name
  key_name        = aws_key_pair.k8s_keypair.key_name

  common_cluster_sg_id = local.common_cluster_sg_id
  master_ip            = local.master_public_ip

  instance_type = "t4g.medium"

  volume_gb_size = 32

  labels = {
    "usage" = "monitoring"
  }

  taints = [{
    key    = "usage"
    value  = "monitoring"
    effect = "PreferNoSchedule"
  }]

  workers = {
    "monitoring" = {
      subnet_id = var.public_subnet_ids[var.public_subnet_key_3]
    }
  }

  ami                  = local.ami
  ssh_private_key_path = var.ssh_private_key_path
  log_dir_path         = local.log_dir_path
  depends_on           = [module.k8s_infra]
}

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
