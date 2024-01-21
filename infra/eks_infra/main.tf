

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

  labels = {}
  taints = {}
}

data "aws_iam_role" "map_roles" {
  for_each = toset(var.eks_cluster_admin_role_names)
  name     = each.key
}

data "aws_iam_user" "map_users" {
  for_each  = toset(var.eks_cluster_admin_user_names)
  user_name = each.key
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "18.26.6"

  cluster_name    = var.eks_cluster_name
  cluster_version = var.cluster_version

  vpc_id     = var.vpc_id
  subnet_ids = var.subnet_ids

  create_aws_auth_configmap = true
  manage_aws_auth_configmap = true
  aws_auth_roles = concat(
    [{
      rolearn  = module.eks_managed_node_group.iam_role_arn
      username = "system:node:{{EC2PrivateDNSName}}"
      groups   = ["system:bootstrappers", "system:nodes"]
    }],
    [
      for key, role in data.aws_iam_role.map_roles : {
        rolearn  = role.arn
        username = key
        groups   = ["system:masters"]
      }
    ]
  )

  aws_auth_users = [
    for key, user in data.aws_iam_user.map_users : {
      userarn  = user.arn
      username = key
      groups   = ["system:masters"]
    }
  ]

  tags = merge(var.tags, { Name = var.eks_cluster_name })
}

data "aws_eks_cluster_auth" "default" {
  name = var.eks_cluster_name
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.default.token
}
