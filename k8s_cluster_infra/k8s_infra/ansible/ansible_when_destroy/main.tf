
locals {
  uuid                = uuid()
  intentory_temp_path = "${path.module}/inventory.tpl"
  inventory_path      = "${path.module}/${local.uuid}_inventory.ini"
  vars_path           = "${path.module}/${local.uuid}_vars.yaml"

  inventory_content = templatefile(local.intentory_temp_path, {
    groups = var.host_groups
  })
  vars_content = yamlencode(var.ansible_vars)

  log_dir_path = "${var.log_dir_path}/${var.group_name}"
}

resource "terraform_data" "pve_maintenance_playbook" {
  input = {
    inventory_path    = local.inventory_path
    inventory_content = local.inventory_content

    vars_path    = local.vars_path
    vars_content = local.vars_content

    playbook_path = var.playbook_path

    log_dir_path   = local.log_dir_path
    log_path       = "${local.log_dir_path}/${timestamp()}_${replace(var.playing_name, " ", "_")}.log"
    stop_if_failed = var.stop_if_failed
    log_dir_path   = local.log_dir_path
  }

  provisioner "local-exec" {
    command = <<EOT
cat <<EOF | tee ${self.input.inventory_path} > /dev/null
${self.input.inventory_content}
EOF

cat <<EOF | tee ${self.input.vars_path} > /dev/null
--- 
${self.input.vars_content}
EOF

mkdir -p ${self.input.log_dir_path}
    EOT

    when = destroy
  }

  provisioner "local-exec" {
    command = <<EOT
    ansible-playbook -i ${self.input.inventory_path} --extra-vars "@${self.input.vars_path}" --ssh-extra-args="-o StrictHostKeyChecking=no" ${self.input.playbook_path} > ${self.input.log_path} 2>&1
    ANSIBLE_EXIT_CODE=$?

    rm -f ${self.input.inventory_path}
    rm -f ${self.input.vars_path}

    if [ ${self.input.stop_if_failed} = true ] && [ $ANSIBLE_EXIT_CODE -ne 0 ]; then
        exit $ANSIBLE_EXIT_CODE
    fi
    EOT

    when = destroy
  }
}

output "inventory_content" {
  value = local.inventory_content
}
