
variable "cicd_name" {
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
