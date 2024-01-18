resource "tls_private_key" "eks_node_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "eks_keypair" {
  key_name   = "${local.prefix}${local.service_name}-eks-keypair.pem"
  public_key = tls_private_key.eks_node_key.public_key_openssh
}

resource "local_file" "private_key_file" {
  filename        = "./keypair/eks-keypair.pem"
  content         = tls_private_key.eks_node_key.private_key_pem
  file_permission = "0600"
}

resource "aws_security_group" "remote_access" {
  name_prefix = "${local.prefix}${local.service_name}-eks-ssh-sg"
  description = "Allow remote SSH access"
  vpc_id      = module.vpc_infra.vpc.id

  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

}

# module "eks_playground" {
#   source  = "terraform-aws-modules/eks/aws"
#   version = "18.26.6"

#   cluster_name    = "${local.prefix}${local.service_name}-eks"
#   cluster_version = "1.28"
#   vpc_id          = module.vpc_infra.vpc.id
#   subnet_ids      = [for subnet in module.vpc_infra.public_subnet_ids : subnet.id]


#   eks_managed_node_groups = {
#     default_node_group = {
#       min_size       = 2
#       max_size       = 3
#       desired_size   = 2
#       instance_types = ["t3a.medium"]
#       remote_access = {
#         ec2_ssh_key               = aws_key_pair.eks_keypair.key_name
#         source_security_group_ids = [aws_security_group.remote_access.id]
#       }
#       #   capacity_type  = "SPOT"
#     }
#   }

#   tags = {
#     env = local.env
#   }
# }
