variable "vpc_id" {
  type = string
}

variable "key_name" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "common_cluster_sg_id" {
  type = string
}

variable "master_ip" {
  type = string
}

variable "master_private_key" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "workers" {
  type = map(object({
    subnet_id = string
  }))
}

variable "ami" {
  type = string
}

variable "labels" {
  type = map(string)
}

variable "taints" {
  type    = map(string)
  default = {}
}


locals {
  install_k8s_sh = file("${path.module}/../init_scripts/install_k8s.sh")

  join_k8s_sh = templatefile("${path.module}/init_scripts/join_k8s.sh", {
    master_ip          = var.master_ip,
    master_private_key = var.master_private_key
    labels             = var.labels
    taints             = var.taints
  })
}
