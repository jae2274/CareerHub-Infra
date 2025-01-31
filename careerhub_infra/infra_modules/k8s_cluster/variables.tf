variable "env" {
  type = string
}

variable "prefix" {
  type = string
}

variable "service_name" {
  type = string
}

variable "terraform_role" {
  type = string
}

variable "ssh_public_key_path" {
  type = string
}

variable "ssh_private_key_path" {
  type = string
}

variable "region" {
  type = string
}

variable "vpc_id" {
  type = string
}
variable "public_subnet_ids" {
  type = map(string)
}

variable "public_subnet_key_1" {
  type = string
}

variable "public_subnet_key_2" {
  type = string
}

variable "public_subnet_key_3" {
  type = string
}

# region =  local.network_output.region
# vpc_id         = local.network_output.vpc_id
# public_subnets = local.network_output.public_subnets

# public_subnet_key_1 = local.network_output.public_subnet_key_1
# public_subnet_key_2 = local.network_output.public_subnet_key_2
# public_subnet_key_3 = local.network_output.public_subnet_key_3
