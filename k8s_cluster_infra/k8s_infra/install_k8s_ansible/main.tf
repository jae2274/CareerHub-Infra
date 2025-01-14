locals {

  playbook_path = "${path.module}/test.yml"

  log_dir_path = "${path.root}/logs"
  log_path     = "${local.log_dir_path}/${var.group_name}.log"
}

module "set_kernel_modules" {
  source       = "../../ansible"
  log_dir_path = local.log_dir_path
  playing_name = "1_set_kernel_modules"

  host_groups   = var.host_groups
  playbook_path = "${path.module}/tasks/kernel_modules.yml"
}

module "install_docker" {
  source       = "../../ansible"
  log_dir_path = local.log_dir_path
  playing_name = "2_install_docker"

  host_groups   = var.host_groups
  playbook_path = "${path.module}/tasks/install_docker.yml"
}

module "install_k8s" {
  source       = "../../ansible"
  log_dir_path = local.log_dir_path
  playing_name = "3_install_k8s"

  host_groups   = var.host_groups
  playbook_path = "${path.module}/tasks/install_k8s.yml"
}

module "install_commands" {
  source       = "../../ansible"
  log_dir_path = local.log_dir_path
  playing_name = "4_install_commands"

  host_groups   = var.host_groups
  playbook_path = "${path.module}/tasks/install_awscli.yml"
}
