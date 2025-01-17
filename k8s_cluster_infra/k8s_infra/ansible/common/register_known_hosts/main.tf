locals {

  playbook_path = "${path.module}/register_known_hosts.yml"

}



module "play_ansible" {
  source       = "../../ansible_module"
  log_dir_path = var.log_dir_path
  group_name   = var.group_name
  playing_name = "register_known_hosts"

  host_groups   = var.host_groups
  playbook_path = "${path.module}/register_known_hosts.yml"
}
