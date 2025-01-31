module "set_kubecfg_secret" {
  source = "../../ansible_module"

  log_dir_path = var.log_dir_path
  group_name   = var.group_name
  playing_name = "set_kubecfg_secret"

  host_groups   = var.host_groups
  playbook_path = "${path.module}/set_kubecfg_secret.yml"

  ansible_vars = {
    secret_id = var.secret_id
  }
}
