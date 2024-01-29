data "aws_iam_policy_document" "codebuild_policy_doc" {

  statement {
    effect = "Allow"
    actions = [
      "ecr:BatchGetImage",
      "ecr:BatchCheckLayerAvailability",
      "ecr:CompleteLayerUpload",
      "ecr:GetDownloadUrlForLayer",
      "ecr:InitiateLayerUpload",
      "ecr:PutImage",
      "ecr:UploadLayerPart"
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

resource "aws_iam_role" "worker_role" {
  name               = "${var.cluster_name}-worker-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy_doc.json
}

resource "aws_iam_role_policy" "codebuild_role_policy" {
  role   = aws_iam_role.worker_role.name
  policy = data.aws_iam_policy_document.codebuild_policy_doc.json
}

resource "aws_iam_instance_profile" "iam_instance_profile" {
  name = "${var.cluster_name}-worker-profile"
  role = aws_iam_role.worker_role.name
}

resource "aws_instance" "workers" {
  for_each = var.workers.worker

  ami                  = var.ami
  instance_type        = var.workers.instance_type
  iam_instance_profile = aws_iam_instance_profile.iam_instance_profile.name

  subnet_id = each.value.subnet_id
  key_name  = aws_key_pair.k8s_keypair.key_name
  # user_data = file("${path.module}/init_scripts/install_k8s.sh")
  user_data = templatefile("${path.module}/init_scripts/join_k8s.sh", {
    install_k8s_sh     = file("${path.module}/init_scripts/install_k8s.sh"),
    master_ip          = aws_instance.master_instance.private_ip
    master_private_key = tls_private_key.k8s_private_key.private_key_pem,
  })
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
