locals {

  playbook_path = "${path.module}/register_known_hosts.yml"

}



module "play_ansible" {
  source       = "../ansible_module"
  log_dir_path = var.log_dir_path
  playing_name = "register_known_hosts_${var.group_name}"

  host_groups   = var.host_groups
  playbook_path = "${path.module}/register_known_hosts.yml"
}
