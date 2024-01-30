
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

  subnet_id = var.master.subnet_id
  key_name  = aws_key_pair.k8s_keypair.key_name
  # user_data = file("${path.module}/init_scripts/install_k8s.sh")
  user_data = templatefile("${path.module}/init_scripts/init_k8s_cluster.sh", {
    install_k8s_sh = file("${path.module}/init_scripts/install_k8s.sh")
    region         = local.region
    ecr_domain     = var.ecr_domain
  })
  vpc_security_group_ids = [aws_security_group.k8s_master_sg.id]

  tags = {
    Name = "${var.cluster_name}-master"
  }

}



