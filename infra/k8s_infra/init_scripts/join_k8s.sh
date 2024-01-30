${install_k8s_sh}

export USER=root
export HOME=/root

echo "***Setting up ssh key for master node***"
cat <<EOF | tee $HOME/.ssh/id_rsa > /dev/null
${master_private_key}
EOF
chmod 600 $HOME/.ssh/id_rsa

echo "***Waiting for master node to be ready***"
ssh -o  "StrictHostKeychecking=no" ubuntu@${master_ip} "cloud-init status --wait"

echo "***Getting join command from master node***"
ssh -o  "StrictHostKeychecking=no" ubuntu@${master_ip} "kubeadm token create --print-join-command" > k8s_join.sh
chmod +x k8s_join.sh


echo "***Joining k8s cluster***"
./k8s_join.sh

mv k8s_join.sh /etc/init.d/k8s_join.sh


echo "***Get login ecr automatically***"
apt-get install -y awscli
aws ecr get-login-password --region ${region} | docker login --username AWS --password-stdin ${ecr_domain}

cat <<EOF | tee login_docker.sh > /dev/null
#!/bin/bash
aws ecr get-login-password --region ${region} | docker login --username AWS --password-stdin ${ecr_domain}
EOF

chmod +x login_docker.sh

mv login_docker.sh /etc/init.d/login_docker.sh
cat <<EOF | tee /etc/cron.d/cron_docker > /dev/null
*/10 * * * * root /etc/init.d/login_docker.sh
EOF