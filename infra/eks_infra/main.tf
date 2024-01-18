

resource "aws_security_group" "remote_access" {
  name_prefix = "${var.eks_cluster_name}-ssh-sg"
  description = "Allow remote SSH access"
  vpc_id      = var.vpc_id

  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

}

module "eks_managed_node_group" {
  source = "terraform-aws-modules/eks/aws//modules/eks-managed-node-group"

  name            = "${var.eks_cluster_name}-ng"
  cluster_name    = var.eks_cluster_name
  cluster_version = var.cluster_version

  subnet_ids = var.subnet_ids

  key_name = var.node_ssh_key_name

  cluster_primary_security_group_id = module.eks.cluster_primary_security_group_id
  vpc_security_group_ids            = [module.eks.node_security_group_id, aws_security_group.remote_access.id]


  min_size     = 2
  max_size     = 3
  desired_size = 2

  instance_types = var.instance_types
  capacity_type  = var.capacity_type

  labels = {
  }

  taints = {

  }

}




module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "18.26.6"

  vpc_id     = var.vpc_id
  subnet_ids = var.subnet_ids

  cluster_name    = var.eks_cluster_name
  cluster_version = var.cluster_version

  tags = merge(var.tags, { Name = var.eks_cluster_name })
}
