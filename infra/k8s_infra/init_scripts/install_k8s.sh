#!/bin/bash

# Disable firewall
ufw disable

#Setting general configuration
cat <<EOF | tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

modprobe overlay
modprobe br_netfilter

cat <<EOF | tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

# Apply sysctl params without reboot
sysctl --system #someting wrong with this command


# check if the params are applied
# sysctl net.bridge.bridge-nf-call-iptables net.bridge.bridge-nf-call-ip6tables net.ipv4.ip_forward



## Install Dockerapt-get update
apt-get update
apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release
apt -y install net-tools

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo "deb [arch=arm64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update

apt-get install -y docker-ce docker-ce-cli containerd.io
docker version
docker info

cat <<EOF | tee /etc/docker/daemon.json
{
    "data-root":"/data/docker"
}
EOF

systemctl daemon-reload
systemctl restart docker

## Install k8s

# If the folder `/etc/apt/keyrings` does not exist, it should be created before the curl command, read the note below.
mkdir -p -m 755 /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

# This overwrites any existing configuration in /etc/apt/sources.list.d/kubernetes.list
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /' | tee /etc/apt/sources.list.d/kubernetes.list
apt-get update

apt-get install -y kubelet kubeadm kubectl
# apt-mark hold kubelet kubeadm kubectl

rm /etc/containerd/config.toml
systemctl restart containerd