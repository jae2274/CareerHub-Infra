variable "log_dir_path" {
  description = "Path to the log directory"
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

variable "playbook_path" {
  description = "Path to the playbook file"
  type        = string
}
