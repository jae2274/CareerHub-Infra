#variable "aws_atlas_key_secret_manager" {
#  type = object({
#    role_arn = string
#    secret_name = string
#    region = string
#  })
#}
#
variable "vpc_id" {
  type = string
}

variable "mongodb_sg_id" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "atlas_key" {
  type = object({
    public_key  = string
    private_key = string
  })
}

variable "mongodb_region" {
  type = string
}

variable "project_name" {
  type = string
}

variable "serverless_databases" {
  type = list(string)
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "admin_db_user" {
  type = object({
    username = string
    password = string
  })
}
