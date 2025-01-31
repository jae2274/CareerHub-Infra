variable "subnet_prefix_name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "private_subnets" {
  type = map(object({
    nat_gateway_id = string
    cidr_block     = string
    az             = string
  }))
}

variable "tags" {
  type    = map(string)
  default = {}
}
