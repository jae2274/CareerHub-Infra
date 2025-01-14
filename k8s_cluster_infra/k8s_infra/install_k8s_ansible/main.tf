locals {

  intentory_temp_path = "${path.module}/inventory.tpl"
  inventory_path      = "${path.module}/inventory.ini"
  playbook_path       = "${path.module}/test.yml"

  inventory_content = templatefile(local.intentory_temp_path, {
    groups = var.host_groups
  })
}


resource "null_resource" "pve_maintenance_playbook" {
  triggers = {
    # SHA256 hash of the file to detect changes
    playbook_hash = sha256(local.inventory_content)
  }

  provisioner "local-exec" {
    command = <<EOT
    
cat <<EOF | tee ${local.inventory_path} > /dev/null
${local.inventory_content}
EOF

ansible-playbook -i ${local.inventory_path} ${local.playbook_path}

rm -f ${local.inventory_path}
    EOT
  }
}

output "inventory_content" {
  value = local.inventory_content
}
