variable "build_arch" {
  type = string
}


check "build_arch" {
  assert {
    condition     = var.build_arch == "arm64" || var.build_arch == "x86_64"
    error_message = "build_arch must be either arm64 or x86_64"
  }
}

variable "cicd_name" {
  type = string
}


variable "repository_path" {
  type = string
}

variable "other_latest_tag" {
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

variable "subnet_arns" {
  type = list(string)
}
