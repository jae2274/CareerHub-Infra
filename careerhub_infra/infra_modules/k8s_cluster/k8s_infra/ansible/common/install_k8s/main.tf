locals {

  playbook_path = "${path.module}/test.yml"

}



module "set_kernel_modules" {
  source       = "../../ansible_module"
  log_dir_path = var.log_dir_path
  group_name   = var.group_name
  playing_name = "set_kernel_modules"

  host_groups   = var.host_groups
  playbook_path = "${path.module}/tasks/kernel_modules.yml"
}

module "install_docker" {
  source       = "../../ansible_module"
  log_dir_path = var.log_dir_path
  group_name   = var.group_name
  playing_name = "install_docker"

  host_groups   = var.host_groups
  playbook_path = "${path.module}/tasks/install_docker.yml"

  depends_on = [module.set_kernel_modules]
}

module "install_k8s" {
  source       = "../../ansible_module"
  log_dir_path = var.log_dir_path
  group_name   = var.group_name
  playing_name = "install_k8s"

  host_groups   = var.host_groups
  playbook_path = "${path.module}/tasks/install_k8s.yml"

  depends_on = [module.install_docker]
}

module "install_commands" {
  source       = "../../ansible_module"
  log_dir_path = var.log_dir_path
  group_name   = var.group_name
  playing_name = "install_commands"

  host_groups   = var.host_groups
  playbook_path = "${path.module}/tasks/install_awscli.yml"

  depends_on = [module.install_k8s]
}
