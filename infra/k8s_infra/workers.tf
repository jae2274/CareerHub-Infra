resource "aws_instance" "workers" {
  for_each = var.workers.worker

  ami           = var.ami
  instance_type = var.workers.instance_type

  subnet_id = each.value.subnet_id
  key_name  = aws_key_pair.k8s_keypair.key_name
  user_data = templatefile("${path.module}/init_scripts/install_k8s.sh", {
    additionals = templatefile("${path.module}/init_scripts/join_k8s.sh", { master_private_key = tls_private_key.k8s_private_key.private_key_pem, master_ip = aws_instance.master_instance.private_ip })
  })
  vpc_security_group_ids = [aws_security_group.k8s_worker_sg.id]

  tags = {
    Name = "${var.cluster_name}-worker-${each.key}"
  }
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
