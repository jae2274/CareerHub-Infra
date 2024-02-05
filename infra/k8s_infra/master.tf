
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
    from_port   = 10250
    to_port     = 10250
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 2379
    to_port     = 2380
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 10257
    to_port     = 10257
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 6443
    to_port     = 6443
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



resource "aws_instance" "master_instance" {
  ami                  = var.ami
  instance_type        = var.master.instance_type
  iam_instance_profile = aws_iam_instance_profile.iam_instance_profile.name

  subnet_id                   = var.master.subnet_id
  key_name                    = aws_key_pair.k8s_keypair.key_name
  associate_public_ip_address = false

  user_data = <<EOT
#!/bin/bash

${local.install_k8s_sh}

${local.init_k8s_sh}
  EOT

  vpc_security_group_ids = [aws_security_group.k8s_master_sg.id]

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
