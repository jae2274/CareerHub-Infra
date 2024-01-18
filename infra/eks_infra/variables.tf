variable "eks_cluster_name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "instance_types" {
  type = list(string)
}

variable "capacity_type" {
  type = string
}

variable "node_ssh_key_name" {
  type = string

}

variable "cluster_version" {
  type    = string
  default = "1.28"
}
