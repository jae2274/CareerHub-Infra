module "remove_node" {
  source       = "../../ansible_when_destroy"
  log_dir_path = var.log_dir_path
  group_name   = var.group_name
  playing_name = "drain_and_remove_node"

  host_groups = {
    master      = [var.master]
    target_node = [var.target_node]
  }

  playbook_path = "${path.module}/remove_node.yml"
}
