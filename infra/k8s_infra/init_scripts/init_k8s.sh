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

kubectl create serviceaccount default

echo "***Get login ecr automatically***"

%{ for ecr in ecrs ~}
aws ecr get-login-password --region ${ecr.region} | docker login --username AWS --password-stdin ${ecr.domain}
%{ endfor ~}

mkdir $UBUNTU_HOME/.docker
cp $HOME/.docker/config.json $UBUNTU_HOME/.docker/config.json

kubectl create secret generic ecr-auth --from-file=.dockerconfigjson=$HOME/.docker/config.json --type=kubernetes.io/dockerconfigjson

kubectl patch serviceaccount default -p '{"imagePullSecrets": [{"name": "ecr-auth"}]}'

cat <<EOF | tee replace_ecr_token.sh > /dev/null
#!/bin/bash
%{ for ecr in ecrs ~}
aws ecr get-login-password --region ${ecr.region} | docker login --username AWS --password-stdin ${ecr.domain}
%{ endfor ~}
cp /root/.docker/config.json /home/ubuntu/.docker/config.json

kubectl create secret generic ecr-auth --from-file=.dockerconfigjson=$HOME/.docker/config.json --type=kubernetes.io/dockerconfigjson -o yaml --dry-run=client | kubectl replace -f -
EOF

chmod +x replace_ecr_token.sh

mv replace_ecr_token.sh /etc/init.d/replace_ecr_token.sh
cat <<EOF | tee /etc/cron.d/cron_docker > /dev/null
*/10 * * * * root /etc/init.d/replace_ecr_token.sh
EOF

echo "***Install helm***"
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh

echo "***Install metrics-server***"
helm install metrics-server metrics-server/metrics-server --set args="{--kubelet-insecure-tls}" --namespace kube-metrics --create-namespace