locals {
  intentory_temp_path = "${path.module}/inventory.tpl"

  inventory_content = templatefile(local.intentory_temp_path, {
    groups = var.host_groups
  })
  vars_content = yamlencode(var.ansible_vars)

  log_dir_path = "${var.log_dir_path}/${var.group_name}"
}

resource "random_string" "for_logfile" {
  length  = 8
  special = false
}

resource "terraform_data" "execute_ansible_playbook_when_destroy" {
  input = {
    inventory_path    = "${path.module}/${random_string.for_logfile.result}_inventory.ini"
    inventory_content = local.inventory_content

    vars_path    = "${path.module}/${random_string.for_logfile.result}_vars.yaml"
    vars_content = local.vars_content

    playbook_path = var.playbook_path

    log_dir_path = local.log_dir_path
    log_file     = "${replace(var.playing_name, " ", "_")}.log"

    stop_if_failed = var.stop_if_failed
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
    ansible-playbook -i ${self.input.inventory_path} --extra-vars "@${self.input.vars_path}" --ssh-extra-args="-o StrictHostKeyChecking=no" ${self.input.playbook_path} > ${self.input.log_dir_path}/$(date +"%Y%m%d_%H%M%S")_${self.input.log_file} 2>&1
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
