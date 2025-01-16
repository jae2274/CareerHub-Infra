
locals {
  intentory_temp_path = "${path.module}/inventory.tpl"
  inventory_path      = "${path.module}/inventory.ini"
  vars_path           = "${path.module}/vars.yaml"

  inventory_content = templatefile(local.intentory_temp_path, {
    groups = var.host_groups
  })
  vars_content = yamlencode(var.ansible_vars)

  log_dir_path = "${var.log_dir_path}/${var.group_name}"
}

resource "null_resource" "pve_maintenance_playbook" {
  triggers = {
    # SHA256 hash of the file to detect changes
    inventory_hash = sha256(local.inventory_content)
    playbook_hash  = filesha256(var.playbook_path)
    vars_hash      = sha256(local.vars_content)
  }

  provisioner "local-exec" {
    command = <<EOT
cat <<EOF | tee ${local.inventory_path} > /dev/null
${local.inventory_content}
EOF

cat <<EOF | tee ${local.vars_path} > /dev/null
--- 
${local.vars_content}
EOF

mkdir -p ${local.log_dir_path}
    EOT
  }

  provisioner "local-exec" {
    command    = "ansible-playbook -i ${local.inventory_path} --extra-vars \"@${local.vars_path}\" ${var.playbook_path} > ${local.log_dir_path}/${replace(var.playing_name, " ", "_")}.log 2>&1"
    on_failure = continue
  }

  provisioner "local-exec" {
    command = <<EOT
rm -f ${local.inventory_path}
rm -f ${local.vars_path}
    EOT
  }
}

output "inventory_content" {
  value = local.inventory_content
}
