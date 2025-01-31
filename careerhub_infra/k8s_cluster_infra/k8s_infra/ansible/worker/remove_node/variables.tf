variable "group_name" {
  type = string
}


variable "master" {
  type = object({
    name                         = string
    ansible_user                 = string
    ansible_ssh_private_key_file = string
  })
}

variable "target_node" {
  type = object({
    name                         = string
    ansible_user                 = string
    ansible_ssh_private_key_file = string
  })
}

variable "log_dir_path" {
  type = string
}
