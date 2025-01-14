%{ for group_name, hosts in groups ~}
[${group_name}]
%{ for host in hosts ~}
${host.name} ansible_user=${host.ansible_user} ansible_ssh_private_key_file=${host.ansible_ssh_private_key_file}
%{ endfor ~}
%{ endfor ~}