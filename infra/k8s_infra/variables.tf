variable "vpc_id" {
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

  # eks_name = "${var.cluster_name}-eks"
  eks_connector_sh = templatefile("${path.module}/init_scripts/eks_connector.sh", {
    eks_name           = var.cluster_name
    region             = local.region
    connector_role_arn = aws_iam_role.eks_connector_role.arn
  })

  ami = "ami-0a7cf821b91bcccbc" # ubuntu 20.04 LTS x86_64
  # ami = "ami-025a235c91853ccbe" # ubuntu 20.04 LTS arm64
}
