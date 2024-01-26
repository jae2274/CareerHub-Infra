#!/bin/bash

cat <<EOF | sudo tee $HOME/.ssh/id_rsa
${master_private_key}
EOF
chmod 600 $HOME/.ssh/id_rsa

ssh ubuntu@${master_ip} "kubeadm token create --print-join-command" > k8s_join.sh
chmod +x k8s_join.sh

## Join k8s cluster
sudo ./k8s_join.sh