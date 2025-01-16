variable "group_name" {
  type = string
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

variable "labels" {
  description = "Labels to be set on the nodes"
  type        = map(string)

  default = {}
}

variable "taints" {
  description = "Taints to be set on the nodes"
  type = list(object({
    key    = string
    value  = string
    effect = string
  }))

  default = []
}

variable "log_dir_path" {
  type = string
}
