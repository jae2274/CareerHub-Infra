variable "env" {
  type = string
}

variable "branch" {
  type = string
}

variable "prefix" {
  type = string
}

variable "terraform_role" {
  type = string
}

variable "atlas_public_key" {
  type = string
}

variable "atlas_private_key" {
  type = string
}


variable "mysql_db_name" {
  type = string
}

variable "mysql_admin_username" {
  type = string
}

variable "mysql_admin_password" {
  type = string
}


variable "google_client_id" {
  type = string
}

variable "google_client_secret" {
  type = string
}

variable "google_redirect_path" {
  type = string
}

variable "jwt_secretkey" {
  type = string
}

variable "initialAdminPassword" {
  type = string
}

variable "root_domain_name" {
  type = string
}
