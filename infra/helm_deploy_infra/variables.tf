variable "deploy_name" {
  type = string
}

variable "namespace" {
  type = string
}

variable "eks_admin_role_arn" {
  type = string
}

variable "helm_value_secret_ids" {
  type = map(string)
}

variable "chart_repo" {
  type = string
}

variable "ecr_repo_name" {
  type    = string
  default = ""
}

variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "subnet_arns" {
  type = list(string)
}
