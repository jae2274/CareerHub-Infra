echo "***Update secrets manager***"
# KUBE_CONFIG=`cat /etc/kubernetes/admin.conf |  yq eval '.clusters[] |= select(.name == "kubernetes") |= .cluster.server = "https://KUBERNETES_SERVER:6443"'`
KUBE_CONFIG=`cat /etc/kubernetes/admin.conf |  yq eval '.clusters[] |= select(.name == "kubernetes") |= .cluster.server = "https://${master_ip}:6443"'`

aws secretsmanager put-secret-value \
      --secret-id ${secret_id} \
      --secret-string "$KUBE_CONFIG"