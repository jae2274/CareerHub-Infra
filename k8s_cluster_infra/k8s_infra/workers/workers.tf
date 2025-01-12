resource "aws_instance" "workers" {
  for_each = var.workers

  ami                  = var.ami
  instance_type        = var.instance_type
  iam_instance_profile = aws_iam_instance_profile.iam_instance_profile.name

  subnet_id = each.value.subnet_id
  key_name  = var.key_name

  user_data              = <<EOT
#!/bin/bash

${local.install_k8s_sh}

${local.join_k8s_sh}
  EOT
  vpc_security_group_ids = [var.common_cluster_sg_id, aws_security_group.k8s_worker_sg.id]

  tags = {
    Name = "${var.cluster_name}-worker-${each.key}"
  }

  root_block_device {
    volume_size = var.volume_gb_size
  }
}

terraform {
  required_providers {

    ansible = {
      source  = "ansible/ansible"
      version = "1.3.0"
    }
  }
}
provider "ansible" {
}

# resource "ansible_host" "worker_nodes" {
#   for_each = aws_instance.workers

#   name   = each.value.public_ip
#   groups = ["worker_nodes"]

#   variables = {
#     ansible_ssh_private_key_file = var.ssh_private_key_path
#   }
# }

# resource "ansible_playbook" "playbook" {
#   playbook = "${path.module}/../install_k8s_ansible/test.yml"
#   name     = "worker_nodes"
#   groups   = ["worker_nodes"]
# }
output "worker_public_ips" {
  value = [for _, worker in aws_instance.workers : worker.public_ip]
}

# output "ansible_playbook_stdout" {
#   value = ansible_playbook.playbook.ansible_playbook_stdout
# }
