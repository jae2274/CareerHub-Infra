export UBUNTU_HOME=/home/ubuntu
export USER=root
export HOME=/root

echo  "***Initialize k8s cluster***"
# CRI v1 runtime API is not implemented: ~~~~ 문구가 나오면 아래 명령어 실행
# rm /etc/containerd/config.toml
# systemctl restart containerd
kubeadm init --pod-network-cidr=192.168.0.0/16 --apiserver-cert-extra-sans=${public_ip}


echo "***Setting up kubectl config***"
mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chmod 644 $HOME/.kube/config


mkdir -p $UBUNTU_HOME/.kube
cp -i /etc/kubernetes/admin.conf $UBUNTU_HOME/.kube/config
chmod 644 $UBUNTU_HOME/.kube/config


echo "***Install network plugin***"
kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml