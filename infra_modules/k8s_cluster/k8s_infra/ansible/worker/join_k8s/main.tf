locals {

  playbook_path = "${path.module}/join_k8s.yml"

}



module "join_k8s" {
  source       = "../../ansible_module"
  log_dir_path = var.log_dir_path
  group_name   = var.group_name
  playing_name = "join_k8s"

  host_groups   = var.host_groups
  playbook_path = "${path.module}/join_k8s.yml"
}
