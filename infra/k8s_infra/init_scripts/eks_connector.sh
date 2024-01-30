
echo "***Install helm***"
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
helm version

apt-get install -y awscli


echo "***Register EKS cluster***"
aws eks register-cluster \
     --name ${eks_name} \
     --connector-config roleArn=${connector_role_arn},provider="OTHER" \
     --region ${region} | tee eks_connector.log


echo "***Install eks-connector helm chart***"
apt-get install -y jq

export ACTIVATE_ID= `cat eks_connector.log | jq '.["cluster"]["ConnectorConfig"]["activationId"]' | tr -d '"'`
export ACTIVATE_CODE= `cat eks_connector.log | jq '.["cluster"]["ConnectorConfig"]["activationCode"]' | tr -d '"'`

echo $ACTIVATE_ID
echo $ACTIVATE_CODE

helm install eks-connector \
  --namespace eks-connector \
  oci://public.ecr.aws/eks-connector/eks-connector-chart \
  --set eks.activationCode=$ACTIVATE_ID \
  --set eks.activationId=$ACTIVATE_CODE \
  --set eks.agentRegion=${region}