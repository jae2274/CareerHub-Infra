#!/bin/bash

SHELL=/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
HOME=/root

echo "$ECRS_JSON" | jq -c '.[]' | while read -r ecr; do
    REGION=$(echo "$ecr" | jq -r '.region')
    DOMAIN=$(echo "$ecr" | jq -r '.domain')

    aws ecr get-login-password --region "$REGION" | docker login --username AWS --password-stdin "$DOMAIN"
done

mkdir -p /home/ubuntu/.docker
cp $HOME/.docker/config.json /home/ubuntu/.docker/config.json

SECRET_YAML=$(kubectl create secret generic ecr-auth --from-file=.dockerconfigjson=$HOME/.docker/config.json --type=kubernetes.io/dockerconfigjson -o yaml --dry-run=client)
NAMESPACES=$(kubectl get namespaces | awk '{if (NR>1) print $1}')

echo "$NAMESPACES" | while read namespace; do 
    echo "$SECRET_YAML" | kubectl apply -n $namespace -f  -;
    echo "$SECRET_YAML" | kubectl replace -n $namespace -f -;
    kubectl patch serviceaccount default -n $namespace -p '{"imagePullSecrets": [{"name": "ecr-auth"}]}';
done