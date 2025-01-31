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

  # ami = "ami-0a7cf821b91bcccbc" # ubuntu 20.04 LTS x86_64
  # ami = "ami-025a235c91853ccbe" # ubuntu 20.04 LTS arm64
}

variable "log_dir_path" {
  type = string
}
