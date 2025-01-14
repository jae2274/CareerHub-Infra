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
