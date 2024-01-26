#!/bin/bash

## Initialize k8s cluster
# CRI v1 runtime API is not implemented: ~~~~ 문구가 나오면 아래 명령어 실행
sudo kubeadm init --pod-network-cidr=192.168.0.0/16

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config


## Install network plugin
curl -LO https://github.com/cilium/cilium-cli/releases/latest/download/cilium-linux-arm64.tar.gz
sudo tar xzvfC cilium-linux-arm64.tar.gz /usr/local/bin
rm cilium-linux-arm64.tar.gz
cilium install