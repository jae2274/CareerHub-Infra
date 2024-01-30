${install_k8s_sh}

#!/bin/bash

export UBUNTU_HOME=/home/ubuntu
export USER=root
export HOME=/root

echo  "***Initialize k8s cluster***"
# CRI v1 runtime API is not implemented: ~~~~ 문구가 나오면 아래 명령어 실행
# rm /etc/containerd/config.toml
# systemctl restart containerd
kubeadm init --pod-network-cidr=192.168.0.0/16


echo "***Setting up kubectl config***"
mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chmod 644 $HOME/.kube/config


mkdir -p $UBUNTU_HOME/.kube
cp -i /etc/kubernetes/admin.conf $UBUNTU_HOME/.kube/config
chmod 644 $UBUNTU_HOME/.kube/config


echo "***Install network plugin***"
kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml


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