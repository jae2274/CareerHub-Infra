variable "region" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "key_name" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "master" {
  type = object({
    instance_type = string
    subnet_id     = string
  })
}

variable "ecrs" {
  type = list(object({
    region = string
    domain = string
  }))
}

variable "ami" {
  type = string
}

variable "ssh_private_key_path" {
  type = string
}

data "aws_region" "current" {}
locals {
  region = data.aws_region.current.name

  install_k8s_sh = file("${path.module}/../init_scripts/install_k8s.sh")

  init_k8s_sh = templatefile("${path.module}/init_scripts/init_k8s.sh", {
    public_ip = aws_eip.master_public_ip.public_ip
    ecrs      = var.ecrs #TODO: 불필요한 정보 제거
  })

  login_ecr_sh = templatefile("${path.module}/init_scripts/login_ecr.sh", {
    ecrs = var.ecrs
  })

  set_secret_sh = templatefile("${path.module}/init_scripts/set_secret.sh", {
    secret_id = aws_secretsmanager_secret.kubeconfig.id
    master_ip = aws_eip.master_public_ip.public_ip
  })
  # ami = "ami-0a7cf821b91bcccbc" # ubuntu 20.04 LTS x86_64
  # ami = "ami-025a235c91853ccbe" # ubuntu 20.04 LTS arm64
}
