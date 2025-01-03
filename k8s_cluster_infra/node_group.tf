resource "tls_private_key" "k8s_private_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "k8s_keypair" {
  key_name   = "${local.eks_cluster_name}-keypair.pem"
  public_key = tls_private_key.k8s_private_key.public_key_openssh
}

resource "aws_secretsmanager_secret" "k8s_node_private_key" {
  name                           = "${local.eks_cluster_name}-node-private-key"
  recovery_window_in_days        = 0
  force_overwrite_replica_secret = true
}

resource "aws_secretsmanager_secret_version" "k8s_node_private_key_version" {
  secret_id     = aws_secretsmanager_secret.k8s_node_private_key.id
  secret_string = tls_private_key.k8s_private_key.private_key_pem
}


resource "aws_eks_node_group" "careerhub" {
  cluster_name    = aws_eks_cluster.careerhub.name
  node_group_name = "${local.eks_cluster_name}-ng"
  node_role_arn   = aws_iam_role.node_group.arn
  subnet_ids      = [for subnet in local.network_output.public_subnets : subnet.id]

  scaling_config {
    desired_size = 1
    max_size     = 2
    min_size     = 1
  }
  instance_types = ["t4g.small"]
  version        = aws_eks_cluster.careerhub.version

  ami_type = "AL2023_ARM_64_STANDARD"

  update_config {
    max_unavailable = 1
  }

  remote_access {
    ec2_ssh_key = aws_key_pair.k8s_keypair.key_name
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
  ]
}

resource "aws_eks_node_group" "monitoring" {
  cluster_name    = aws_eks_cluster.careerhub.name
  node_group_name = "${local.eks_cluster_name}-monitoring-ng"
  node_role_arn   = aws_iam_role.node_group.arn
  subnet_ids      = [for subnet in local.network_output.public_subnets : subnet.id]

  scaling_config {
    desired_size = 1
    max_size     = 1
    min_size     = 1
  }
  instance_types = ["t4g.medium"]
  version        = aws_eks_cluster.careerhub.version

  ami_type = "AL2023_ARM_64_STANDARD"

  update_config {
    max_unavailable = 1
  }

  remote_access {
    ec2_ssh_key = aws_key_pair.k8s_keypair.key_name
  }

  taint {
    key    = "usage"
    value  = "monitoring"
    effect = "PREFER_NO_SCHEDULE"
  }

  labels = {
    usage = "monitoring"
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
  ]
}

resource "aws_iam_role" "node_group" {
  name = "${local.eks_cluster_name}-ng-role"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.node_group.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.node_group.name
}

resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.node_group.name
}

data "aws_iam_policy_document" "ecr_readonly_policy" {
  statement {
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchGetImage",
      "ecr:GetDownloadUrlForLayer",
      "ecr:GetAuthorizationToken"
    ]

    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "ecr_readonly_policy" {
  name   = replace("${local.prefix_service_name}-ecr-readonly", "_", "-")
  role   = aws_iam_role.node_group.name
  policy = data.aws_iam_policy_document.ecr_readonly_policy.json
}

# # EKS 노드 그룹 보안 그룹
resource "aws_security_group" "eks_node_sg" {
  name        = "${local.prefix_service_name}-eks-node-sg"
  description = "Security group for EKS Worker Nodes"
  vpc_id      = local.network_output.vpc_id

  # 노드 -> 클러스터로의 통신 허용 (TCP 443)
  ingress {
    description = "Allow cluster communication"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [local.network_output.vpc_cidr_block]
  }

  # 외부에서의 SSH 접근 허용 (TCP 22)
  ingress {
    description = "Allow SSH access from outside"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # EKS 노드 간 통신 허용
  ingress {
    description = "Allow node-to-node communication"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = [local.network_output.vpc_cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
