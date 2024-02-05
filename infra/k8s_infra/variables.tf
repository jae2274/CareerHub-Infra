variable "vpc_id" {
  type = string
}


variable "ami" {
  type = string
  # default = "ami-077885f59ecb77b84" # ubuntu 22.04 LTS
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

variable "workers" {
  type = object({
    instance_type = string

    worker = map(object({
      subnet_id = string
    }))
  })
}

variable "ecrs" {
  type = list(object({
    region = string
    domain = string
  }))
}

data "aws_region" "current" {}
locals {
  region = data.aws_region.current.name

  install_k8s_sh = file("${path.module}/init_scripts/install_k8s.sh")

  init_k8s_sh = templatefile("${path.module}/init_scripts/init_k8s.sh", {
    public_ip = aws_eip.master_public_ip.public_ip,
    ecrs      = var.ecrs
  })

  join_k8s_sh = templatefile("${path.module}/init_scripts/join_k8s.sh", {
    master_ip          = aws_instance.master_instance.private_ip
    master_private_key = tls_private_key.k8s_private_key.private_key_pem,
  })

  login_ecr_sh = templatefile("${path.module}/init_scripts/login_ecr.sh", {
    ecrs = var.ecrs
  })
}
