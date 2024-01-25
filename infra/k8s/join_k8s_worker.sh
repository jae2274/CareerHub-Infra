#!/bin/bash

## Join k8s cluster
sudo kubeadm join 10.0.1.154:6443 --token dfm9uc.yhf1vd2iqxgsotc1 \
        --discovery-token-ca-cert-hash sha256:7009a3d1b7bbb2d80b1f0cf2864396d3ead2cd6619ec936e161059961032a07a 