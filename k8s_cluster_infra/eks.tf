
locals {
  eks_cluster_name = "${local.prefix_service_name}-eks"
}



resource "aws_eks_cluster" "careerhub" {
  name = local.eks_cluster_name

  access_config {
    bootstrap_cluster_creator_admin_permissions = false
    authentication_mode                         = "API" #TODO: API_AND_CONFIGMAP 
  }

  role_arn = aws_iam_role.eks_cluster.arn

  vpc_config {
    endpoint_public_access  = true
    endpoint_private_access = true

    subnet_ids = [for subnet in local.network_output.public_subnets : subnet.id]
    security_group_ids = [
      aws_security_group.eks_cluster_sg.id,
    ]
  }

  # Ensure that IAM Role permissions are created before and deleted
  # after EKS Cluster handling. Otherwise, EKS will not be able to
  # properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy,
  ]
}

resource "aws_iam_role" "eks_cluster" {
  name = "${local.eks_cluster_name}-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster.name
}

resource "aws_security_group" "eks_cluster_sg" {
  name        = "${local.prefix_service_name}-eks-cluster-sg"
  description = "Security group for EKS Cluster"
  vpc_id      = local.network_output.vpc_id

  # EKS 클러스터 -> 노드로의 통신 허용 (TCP 443)
  ingress {
    description = "Allow worker node communication"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "eks-cluster-sg"
  }
}
