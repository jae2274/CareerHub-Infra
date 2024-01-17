variable "jasypt_password" {
  type = string
}

variable "atlas_key" {
  type = object({
    public_key  = string
    private_key = string
  })
}

variable "admin_db_user" {
  type = object({
    username = string
    password = string
  })
}


