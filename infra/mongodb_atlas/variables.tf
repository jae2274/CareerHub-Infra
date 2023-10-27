#variable "aws_atlas_key_secret_manager" {
#  type = object({
#    role_arn = string
#    secret_name = string
#    region = string
#  })
#}
#
variable "atlas_key" {
  type = object({
    public_key = string
    private_key = string
  })
}

variable mongodb_region{
  type = string
}

variable "project_name" {
  type = string
}

variable "serverless_databases" {
  type = list(string)
}