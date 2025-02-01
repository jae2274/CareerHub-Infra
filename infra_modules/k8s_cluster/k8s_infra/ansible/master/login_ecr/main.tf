module "set_ecr_env_var" {
  source = "../../ansible_module"

  log_dir_path = var.log_dir_path
  group_name   = var.group_name
  playing_name = "set_ecr_env_var"

  host_groups   = var.host_groups
  playbook_path = "${path.module}/tasks/set_ecr_env_var.yml"

  ansible_vars = {
    ecr_list_json = jsonencode(var.ecrs)
  }
}

module "login_ecr" {
  source = "../../ansible_module"

  log_dir_path = var.log_dir_path
  group_name   = var.group_name
  playing_name = "login_ecr"

  host_groups   = var.host_groups
  playbook_path = "${path.module}/tasks/login_ecr.yml"

  ansible_vars = {
    replace_ecr_token_sh_path = "${path.cwd}/${path.module}/scripts/replace_ecr_token.sh"
    check_namespaces_sh_path  = "${path.cwd}/${path.module}/scripts/check_namespaces.sh"
  }
}
