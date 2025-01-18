
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

  ingress { //TODO: 이후 세부적으로 수정
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





resource "aws_instance" "master_instance" {
  ami           = var.ami
  instance_type = var.master.instance_type

  subnet_id = var.master.subnet_id
  key_name  = var.key_name

  iam_instance_profile = aws_iam_instance_profile.iam_instance_profile.name

  vpc_security_group_ids = [aws_security_group.k8s_master_sg.id, aws_security_group.k8s_node_sg.id]

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

resource "null_resource" "wait_for_ok" {
  provisioner "local-exec" { command = "aws ec2 wait instance-status-ok --region ${var.region} --instance-ids ${aws_instance.master_instance.id}" }
}

module "install_k8s" {
  source = "../ansible/common/install_k8s"

  group_name = "master"

  host_groups = {
    "master" = [
      {
        name                         = aws_eip.master_public_ip.public_ip
        ansible_user                 = "ubuntu"
        ansible_ssh_private_key_file = var.ssh_private_key_path
      }
    ]
  }

  log_dir_path = var.log_dir_path

  depends_on = [null_resource.wait_for_ok]
}

module "init_k8s" {
  source = "../ansible/master/init_k8s"

  group_name = "master"
  host_groups = {
    "master" = [
      {
        name                         = aws_eip.master_public_ip.public_ip
        ansible_user                 = "ubuntu"
        ansible_ssh_private_key_file = var.ssh_private_key_path
      }
    ]
  }
  depends_on = [module.install_k8s]

  log_dir_path = var.log_dir_path
}

module "login_ecr" {
  source = "../ansible/master/login_ecr"

  group_name = "master"
  host_groups = {
    "master" = [
      {
        name                         = aws_eip.master_public_ip.public_ip
        ansible_user                 = "ubuntu"
        ansible_ssh_private_key_file = var.ssh_private_key_path
      }
    ]
  }
  depends_on = [module.init_k8s]

  log_dir_path = var.log_dir_path
  ecrs         = var.ecrs
}

output "master_public_ip" {
  value = aws_eip.master_public_ip.public_ip
}

output "master_private_ip" {
  value = aws_instance.master_instance.private_ip
}
