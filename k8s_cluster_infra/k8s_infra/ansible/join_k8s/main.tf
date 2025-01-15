locals {

  playbook_path = "${path.module}/join_k8s.yml"

  log_dir_path = "${path.root}/logs"
}



module "join_k8s" {
  source       = "../ansible_module"
  log_dir_path = local.log_dir_path
  playing_name = "join_k8s_${var.group_name}"

  host_groups   = var.host_groups
  playbook_path = "${path.module}/join_k8s.yml"
}
