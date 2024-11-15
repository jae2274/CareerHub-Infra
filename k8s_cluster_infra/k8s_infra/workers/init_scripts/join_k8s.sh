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


echo "***Setting node labels***"
%{ for key,value in labels ~}
ssh -o "StrictHostKeychecking=no" ubuntu@${master_ip} "kubectl label nodes $HOSTNAME ${key}=${value}"
%{ endfor ~}

echo "***Setting tainted nodes***"
%{ for taint in taints ~}
ssh -o "StrictHostKeychecking=no" ubuntu@${master_ip} "kubectl taint nodes $HOSTNAME ${taint.key}=${taint.value}:${taint.effect}"
%{ endfor ~}