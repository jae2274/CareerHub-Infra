resource "aws_instance" "workers" {
  for_each = var.workers

  ami                  = var.ami
  instance_type        = var.instance_type
  iam_instance_profile = aws_iam_instance_profile.iam_instance_profile.name

  subnet_id = each.value.subnet_id
  key_name  = var.key_name

  vpc_security_group_ids = [var.common_cluster_sg_id, aws_security_group.k8s_worker_sg.id]

  tags = {
    Name = "${var.cluster_name}-worker-${each.key}"
  }

  root_block_device {
    volume_size = var.volume_gb_size
  }
}

resource "null_resource" "wait_for_workers" {
  for_each = aws_instance.workers

  provisioner "local-exec" { command = "aws ec2 wait instance-status-ok --region ${var.region} --instance-ids ${each.value.id}" }
}

module "register_known_hosts" {
  source = "../ansible/common/register_known_hosts"

  group_name = var.node_group_name

  host_groups = {
    "worker_nodes" = [
      for _, worker in aws_instance.workers : {
        name                         = worker.public_ip
        ansible_user                 = "ubuntu"
        ansible_ssh_private_key_file = var.ssh_private_key_path
      }
    ]
  }

  log_dir_path = var.log_dir_path
  depends_on   = [null_resource.wait_for_workers]
}

module "install_k8s_ansible" {
  source = "../ansible/common/install_k8s"

  group_name = var.node_group_name

  host_groups = {
    "worker_nodes" = [
      for _, worker in aws_instance.workers : {
        name                         = worker.public_ip
        ansible_user                 = "ubuntu"
        ansible_ssh_private_key_file = var.ssh_private_key_path
      }
    ]
  }

  log_dir_path = var.log_dir_path
  depends_on   = [module.register_known_hosts]
}

module "join_k8s" {
  source     = "../ansible/worker/join_k8s"
  group_name = var.node_group_name

  host_groups = {
    "master" = [
      {
        name                         = var.master_ip
        ansible_user                 = "ubuntu"
        ansible_ssh_private_key_file = var.ssh_private_key_path
      }
    ]
    "worker_nodes" = [
      for _, worker in aws_instance.workers : {
        name                         = worker.public_ip
        ansible_user                 = "ubuntu"
        ansible_ssh_private_key_file = var.ssh_private_key_path
      }
    ]
  }

  log_dir_path = var.log_dir_path
  depends_on   = [module.install_k8s_ansible]
}

module "set_taints_labels" {
  source     = "../ansible/worker/set_taints_labels"
  group_name = var.node_group_name

  host_groups = {
    "master" = [
      {
        name                         = var.master_ip
        ansible_user                 = "ubuntu"
        ansible_ssh_private_key_file = var.ssh_private_key_path
      }
    ]
    "worker_nodes" = [
      for _, worker in aws_instance.workers : {
        name                         = worker.public_ip
        ansible_user                 = "ubuntu"
        ansible_ssh_private_key_file = var.ssh_private_key_path
      }
    ]
  }

  labels = var.labels
  taints = var.taints

  log_dir_path = var.log_dir_path
  depends_on   = [module.join_k8s]
}

output "worker_public_ips" {
  value = [for _, worker in aws_instance.workers : worker.public_ip]
}

# output "inventory_content" {
#   value = module.install_k8s_ansible.inventory_content
# }
