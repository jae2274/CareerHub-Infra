variable "log_dir_path" {
  description = "Directory path to store logs"
  type        = string
}

variable "group_name" {
  description = "Name of the group"
  type        = string
}

variable "host_groups" {
  description = "Host groups"
  type = map(list(object({
    name                         = string
    ansible_user                 = string
    ansible_ssh_private_key_file = string
  })))
}

variable "secret_id" {
  type        = string
  description = "aws secret id"
}
