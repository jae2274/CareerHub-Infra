variable "jasypt_password" {
  type = string
}

variable "atlas_key" {
  type = object({
    public_key = string
    private_key = string
  })
}