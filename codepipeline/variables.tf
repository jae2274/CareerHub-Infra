variable "role_arn" {
  type = string
}

variable "prefix_service_name" {
  type = string
}

variable "s3_bucket" {
  type = string
}

variable "code_connection_arn" {
  type = string
}

variable "repository_path" {
  type = string
}

variable "branch_name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}
