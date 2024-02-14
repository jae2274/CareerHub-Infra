variable "region" {
  type = string
}
variable "terraform_role" {
  type = string
}

variable "atlas_public_key" {
  type = string
}

variable "atlas_private_key" {
  type = string
}

variable "admin_db_username" {
  type = string
}

variable "admin_db_password" {
  type = string
}


variable "eks_cluster_admin_role_names" {
  type    = list(string)
  default = []
}

variable "eks_cluster_admin_user_names" {
  type    = list(string)
  default = []
}

variable "eks_cluster_user_arn" {
  type = string
}
