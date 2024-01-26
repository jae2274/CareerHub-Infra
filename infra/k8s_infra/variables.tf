variable "vpc_id" {
  type = string
}
variable "ami" {
  type = string
  # default = "ami-077885f59ecb77b84" # ubuntu 22.04 LTS
}

variable "cluster_name" {
  type = string
}

variable "master" {
  type = object({
    instance_type = string
    subnet_id     = string
  })
}

variable "workers" {
  type = object({
    instance_type = string

    worker = map(object({
      subnet_id = string
    }))
  })
}



