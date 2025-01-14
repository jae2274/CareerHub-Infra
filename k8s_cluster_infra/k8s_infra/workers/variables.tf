variable "vpc_id" {
  type = string
}

variable "node_group_name" {
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
  type = list(object({
    key    = string
    value  = string
    effect = string
  }))
  default = []
}

variable "volume_gb_size" {
  type    = number
  default = 8
}
variable "ssh_private_key_path" {
  type = string
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
