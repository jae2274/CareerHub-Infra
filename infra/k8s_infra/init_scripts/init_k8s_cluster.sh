${install_k8s_sh}

#!/bin/bash
echo $USER > /tmp/user.txt
echo $HOME > /tmp/home.txt
pwd > /tmp/pwd.txt

printenv > /tmp/printenv.txt

export UBUNTU_HOME=/home/ubuntu
export USER=root
export HOME=/root

## Initialize k8s cluster
# CRI v1 runtime API is not implemented: ~~~~ 문구가 나오면 아래 명령어 실행
kubeadm init --pod-network-cidr=192.168.0.0/16

mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chmod 644 $HOME/.kube/config


mkdir -p $UBUNTU_HOME/.kube
cp -i /etc/kubernetes/admin.conf $UBUNTU_HOME/.kube/config
chmod 644 $UBUNTU_HOME/.kube/config


## Install network plugin
curl -LO https://github.com/cilium/cilium-cli/releases/latest/download/cilium-linux-arm64.tar.gz
tar xzvfC cilium-linux-arm64.tar.gz /usr/local/bin
cilium install