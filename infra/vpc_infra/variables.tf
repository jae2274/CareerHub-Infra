variable "vpc_name" {
  type = string
}

variable "vpc_cidr_block" {
  type = string
}

variable "pair_subnets" {
  type = map(object({
    public_cidr_block  = string
    private_cidr_block = string
    az                 = string
  }))

  default = {}
}

variable "instance_tenancy" {
  type    = string
  default = "default"
}

variable "enable_dns_hostnames" {
  type    = bool
  default = true
}

variable "tags" {
  type    = map(string)
  default = {}
}