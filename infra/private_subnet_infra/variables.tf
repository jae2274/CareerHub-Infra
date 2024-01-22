variable "subnet_prefix_name" {
  type = string
}

variable "private_subnets" {
  type = map(object({
    paired_public_subnet_id = string
    cidr_block              = string
  }))
}
