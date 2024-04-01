
resource "aws_security_group" "k8s_master_sg" {
  vpc_id      = var.vpc_id
  name        = "${var.cluster_name}-master-sg"
  description = "For k8s worker nodes"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  dynamic "ingress" { //TODO: 이후 세부적으로 수정
    for_each = var.node_ports
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}





resource "aws_instance" "master_instance" {
  ami                  = var.ami
  instance_type        = var.master.instance_type
  iam_instance_profile = var.iam_instance_profile

  subnet_id = var.master.subnet_id
  key_name  = var.key_name

  user_data = <<EOT
#!/bin/bash

${local.install_k8s_sh}

${local.init_k8s_sh}

${local.set_secret_sh}
  EOT

  vpc_security_group_ids = [aws_security_group.k8s_master_sg.id, var.common_cluster_sg_id]

  tags = {
    Name = "${var.cluster_name}-master"
  }
}




resource "aws_eip" "master_public_ip" {
  domain = "vpc"
}

resource "aws_eip_association" "master_public_ip" {
  instance_id   = aws_instance.master_instance.id
  allocation_id = aws_eip.master_public_ip.id
}

output "master_public_ip" {
  value = aws_eip.master_public_ip.public_ip
}

output "master_private_ip" {
  value = aws_instance.master_instance.private_ip
}
