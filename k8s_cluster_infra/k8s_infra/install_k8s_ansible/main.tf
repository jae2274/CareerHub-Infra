

resource "ansible_host" "worker_nodes" {
  for_each = var.target_nodes

  name   = each.value
  groups = ["worker_nodes"]

  variables = {
    ansible_ssh_private_key_file = var.ssh_private_key_path
  }
}

resource "ansible_playbook" "playbook" {
  playbook = "${path.module}/test.yml"
  name     = "worker_nodes"
  groups   = ["worker_nodes"]
}

output "ansible_playbook_stdout" {
  value = ansible_playbook.playbook.ansible_playbook_stdout
}
