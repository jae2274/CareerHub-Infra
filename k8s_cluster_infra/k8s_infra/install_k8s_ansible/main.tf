locals {

  intentory_temp_path = "${path.module}/inventory.tpl"
  inventory_path      = "${path.module}/inventory.ini"
  playbook_path       = "${path.module}/test.yml"

  log_dir_path = "${path.root}/logs"
  log_path     = "${local.log_dir_path}/${var.group_name}.log"

  inventory_content = templatefile(local.intentory_temp_path, {
    groups = var.host_groups
  })
}


resource "null_resource" "pve_maintenance_playbook" {
  triggers = {
    # SHA256 hash of the file to detect changes
    inventory_hash = sha256(local.inventory_content)
    playbook_hash  = filesha256(local.playbook_path)
    test           = "10"
  }

  provisioner "local-exec" {
    command = <<EOT
    
cat <<EOF | tee ${local.inventory_path} > /dev/null
${local.inventory_content}
EOF

mkdir -p ${local.log_dir_path}
ansible-playbook -i ${local.inventory_path} ${local.playbook_path} > ${local.log_path} 2>&1

rm -f ${local.inventory_path}
    EOT
  }
}

output "inventory_content" {
  value = local.inventory_content
}
