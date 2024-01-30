data "aws_iam_policy_document" "ec2_policy_doc" {

  statement {
    effect = "Allow"
    actions = [
      "ecr:*"
      # "ecr:GetAuthorizationToken",
      # "ecr:BatchCheckLayerAvailability",
      # "ecr:GetDownloadUrlForLayer",
      # "ecr:GetRepositoryPolicy",
      # "ecr:DescribeRepositories",
      # "ecr:ListImages",
      # "ecr:BatchGetImage"
    ]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "assume_role_policy_doc" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "k8s_node_role" {
  name               = "${var.cluster_name}-k8s_node-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy_doc.json
}

resource "aws_iam_role_policy" "ec2_role_policy" {
  role   = aws_iam_role.k8s_node_role.name
  policy = data.aws_iam_policy_document.ec2_policy_doc.json
}

resource "aws_iam_instance_profile" "iam_instance_profile" {
  name = "${var.cluster_name}-k8s_node-profile"
  role = aws_iam_role.k8s_node_role.name
}

resource "aws_instance" "workers" {
  for_each = var.workers.worker

  ami                  = var.ami
  instance_type        = var.workers.instance_type
  iam_instance_profile = aws_iam_instance_profile.iam_instance_profile.name

  subnet_id = each.value.subnet_id
  key_name  = aws_key_pair.k8s_keypair.key_name
  # user_data = file("${path.module}/init_scripts/install_k8s.sh")
  user_data              = <<EOT
#!/bin/bash

${local.install_k8s_sh}

${local.join_k8s_sh}

${local.login_ecr_sh}
  EOT
  vpc_security_group_ids = [aws_security_group.k8s_worker_sg.id]

  tags = {
    Name = "${var.cluster_name}-worker-${each.key}"
  }

  depends_on = [aws_instance.master_instance]
}

resource "aws_security_group" "k8s_worker_sg" {
  name        = "k8s_node_sg"
  description = "For k8s worker nodes"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 10250
    to_port     = 10250
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 30000
    to_port     = 32767
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
