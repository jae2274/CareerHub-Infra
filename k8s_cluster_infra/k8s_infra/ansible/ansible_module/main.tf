
locals {
  intentory_temp_path = "${path.module}/inventory.tpl"
  inventory_path      = "${path.module}/inventory.ini"

  inventory_content = templatefile(local.intentory_temp_path, {
    groups = var.host_groups
  })
}

resource "null_resource" "pve_maintenance_playbook" {
  triggers = {
    # SHA256 hash of the file to detect changes
    inventory_hash = sha256(local.inventory_content)
    playbook_hash  = filesha256(var.playbook_path)
  }

  provisioner "local-exec" {
    command = <<EOT
    
cat <<EOF | tee ${local.inventory_path} > /dev/null
${local.inventory_content}
EOF

mkdir -p ${var.log_dir_path}
ansible-playbook -i ${local.inventory_path} ${var.playbook_path} > ${var.log_dir_path}/${replace(var.playing_name, " ", "_")}.log 2>&1

rm -f ${local.inventory_path}
    EOT
  }
}

output "inventory_content" {
  value = local.inventory_content
}
