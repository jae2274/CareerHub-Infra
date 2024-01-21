locals {
  eks_cluster_name = "${local.prefix_service_name}-eks"
}

resource "tls_private_key" "eks_node_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "eks_keypair" {
  key_name   = "${local.eks_cluster_name}-keypair.pem"
  public_key = tls_private_key.eks_node_key.public_key_openssh
}

resource "local_file" "private_key_file" {
  filename        = "./keypair/${local.eks_cluster_name}-keypair.pem"
  content         = tls_private_key.eks_node_key.private_key_pem
  file_permission = "0600"
}

module "eks_infra" {
  source = "./eks_infra"

  eks_cluster_name  = local.eks_cluster_name
  vpc_id            = module.vpc_infra.vpc.id
  subnet_ids        = [for subnet in module.vpc_infra.public_subnets : subnet.id]
  node_ssh_key_name = aws_key_pair.eks_keypair.key_name

  # instance_types               = ["t3a.medium"]
  instance_types               = ["t3a.small"]
  capacity_type                = "ON_DEMAND"
  eks_cluster_admin_role_names = var.eks_cluster_admin_role_names
  eks_cluster_admin_user_names = var.eks_cluster_admin_user_names
}
