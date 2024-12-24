variable "terraform_role" {
  type = string
}

variable "eks_cluster_admin_role_arns" {
  type = list(string)
}

variable "eks_cluster_admin_user_arns" {
  type = list(string)
}
