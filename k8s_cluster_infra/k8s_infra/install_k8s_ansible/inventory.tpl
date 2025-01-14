%{ for group_name, group_value in groups ~}
[${group_name}]
%{ for host in group_value.hosts ~}
${host.name} ansible_user=${host.ansible_user} ansible_ssh_private_key_file=${host.ansible_ssh_private_key_file}
%{ endfor ~}
%{ endfor ~}
