resource "aws_instance" "workers" {
  for_each = var.workers.worker

  ami                  = local.ami
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
  vpc_security_group_ids = [aws_security_group.k8s_worker_sg.id, aws_security_group.k8s_node_sg.id]

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

  ingress { //TODO: 이후 세부적으로 수정
    from_port   = 8080
    to_port     = 8080
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

output "worker_public_ips" {
  value = [for worker in aws_instance.workers : worker.public_ip]
}
