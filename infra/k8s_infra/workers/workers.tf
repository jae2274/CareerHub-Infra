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



output "worker_public_ips" {
  value = [for worker in aws_instance.workers : worker.public_ip]
}
