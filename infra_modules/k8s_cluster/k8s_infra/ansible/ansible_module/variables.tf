variable "log_dir_path" {
  description = "Path to the log directory"
  type        = string
}

variable "group_name" {
  description = "Name of the target"
  type        = string
}

variable "playing_name" {
  description = "What to play"
  type        = string
}

variable "host_groups" {
  description = "Host groups to be created in the inventory file"
  type = map(
    list(
      object({
        name                         = string
        ansible_user                 = string
        ansible_ssh_private_key_file = string
      })
    )
  )
}

variable "ansible_vars" {
  type = any
  default = {

  }
}

variable "playbook_path" {
  description = "Path to the playbook file"
  type        = string
}
