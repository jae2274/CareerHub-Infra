module "set_taints_labels" {
  source       = "../../ansible_module"
  log_dir_path = var.log_dir_path
  group_name   = var.group_name
  playing_name = "set_taints_labels"

  host_groups   = var.host_groups
  playbook_path = "${path.module}/set_taints_labels.yml"
  ansible_vars = {
    labels = [for key, value in var.labels : { key = key, value = value }]
    taints = var.taints
  }
}
