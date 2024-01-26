${install_k8s_sh}

#!/bin/bash
echo $USER > /tmp/user.txt
echo $HOME > /tmp/home.txt
pwd > /tmp/pwd.txt

export USER=root
export HOME=/root

cat <<EOF | tee $HOME/.ssh/id_rsa > /dev/null
${master_private_key}
EOF
chmod 644 $HOME/.ssh/id_rsa

ssh -o "StrictHostKeychecking=no" ubuntu@${master_ip} "kubeadm token create --print-join-command" > k8s_join.sh
chmod +x k8s_join.sh

## Join k8s cluster
./k8s_join.sh