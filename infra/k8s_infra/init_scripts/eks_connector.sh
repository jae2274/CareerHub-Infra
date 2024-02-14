
echo "***Install helm***"
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh

echo "***Register EKS cluster***"
aws eks register-cluster \
     --name ${eks_name} \
     --connector-config roleArn=${connector_role_arn},provider="EC2" \
     --region ${region} | tee eks_connector.log


echo "***Install eks-connector helm chart***"

export EKS_ACTIVATION_ID=`cat eks_connector.log | jq '.["cluster"]["connectorConfig"]["activationId"]' | tr -d '"'`
export EKS_ACTIVATION_CODE=`cat eks_connector.log | jq '.["cluster"]["connectorConfig"]["activationCode"]' | tr -d '"'`

echo $EKS_ACTIVATION_ID
echo $EKS_ACTIVATION_CODE

helm install eks-connector \
  --namespace eks-connector \
  oci://public.ecr.aws/eks-connector/eks-connector-chart \
  --set eks.activationId=$EKS_ACTIVATION_ID \
  --set eks.activationCode=$EKS_ACTIVATION_CODE \
  --set eks.agentRegion=${region} --create-namespace

curl -O https://s3.us-west-2.amazonaws.com/amazon-eks/eks-connector/manifests/eks-connector-console-roles/eks-connector-clusterrole.yaml
curl -O https://s3.us-west-2.amazonaws.com/amazon-eks/eks-connector/manifests/eks-connector-console-roles/eks-connector-console-dashboard-full-access-group.yaml

USER_ARN_ESCAPED=$(echo "${user_arn}" | sed 's/\//\\\//g')
sed "s/%IAM_ARN%/$USER_ARN_ESCAPED/g" eks-connector-clusterrole.yaml > temp.txt
mv temp.txt eks-connector-clusterrole.yaml
sed "s/%IAM_ARN%/$USER_ARN_ESCAPED/g" eks-connector-console-dashboard-full-access-group.yaml > temp.txt
mv temp.txt eks-connector-console-dashboard-full-access-group.yaml

kubectl apply -f eks-connector-clusterrole.yaml
kubectl apply -f eks-connector-console-dashboard-full-access-group.yaml

helm upgrade eks-connector oci://public.ecr.aws/eks-connector/eks-connector-chart \
    --reuse-values \
    --set 'authentication.allowedUserARNs={${user_arn}}' --namespace eks-connector