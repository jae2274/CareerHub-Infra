module "init_kubeadm" {
  source       = "../../ansible_module"
  log_dir_path = var.log_dir_path
  group_name   = var.group_name
  playing_name = "init_kubeadm"

  host_groups   = var.host_groups
  playbook_path = "${path.module}/tasks/init_kubeadm.yml"
}

module "install_network_plugin" {
  source       = "../../ansible_module"
  log_dir_path = var.log_dir_path
  group_name   = var.group_name
  playing_name = "install_network_plugin"

  host_groups   = var.host_groups
  playbook_path = "${path.module}/tasks/install_network_plugin.yml"

  depends_on = [module.init_kubeadm]
}

module "install_helm" {
  source       = "../../ansible_module"
  log_dir_path = var.log_dir_path
  group_name   = var.group_name
  playing_name = "install_helm"

  host_groups   = var.host_groups
  playbook_path = "${path.module}/tasks/install_helm.yml"

  depends_on = [module.install_network_plugin]
}


module "install_metrics_server" {
  source       = "../../ansible_module"
  log_dir_path = var.log_dir_path
  group_name   = var.group_name
  playing_name = "install_metrics_server"

  host_groups   = var.host_groups
  playbook_path = "${path.module}/tasks/install_metrics_server.yml"

  depends_on = [module.install_helm]
}
