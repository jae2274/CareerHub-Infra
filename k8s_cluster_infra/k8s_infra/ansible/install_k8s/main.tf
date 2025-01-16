locals {

  playbook_path = "${path.module}/test.yml"

}



module "set_kernel_modules" {
  source       = "../ansible_module"
  log_dir_path = var.log_dir_path
  playing_name = "1_set_kernel_modules_${var.group_name}"

  host_groups   = var.host_groups
  playbook_path = "${path.module}/tasks/kernel_modules.yml"
}

module "install_docker" {
  source       = "../ansible_module"
  log_dir_path = var.log_dir_path
  playing_name = "2_install_docker_${var.group_name}"

  host_groups   = var.host_groups
  playbook_path = "${path.module}/tasks/install_docker.yml"

  depends_on = [module.set_kernel_modules]
}

module "install_k8s" {
  source       = "../ansible_module"
  log_dir_path = var.log_dir_path
  playing_name = "3_install_k8s_${var.group_name}"

  host_groups   = var.host_groups
  playbook_path = "${path.module}/tasks/install_k8s.yml"

  depends_on = [module.install_docker]
}

module "install_commands" {
  source       = "../ansible_module"
  log_dir_path = var.log_dir_path
  playing_name = "4_install_commands_${var.group_name}"

  host_groups   = var.host_groups
  playbook_path = "${path.module}/tasks/install_awscli.yml"

  depends_on = [module.install_k8s]
}
