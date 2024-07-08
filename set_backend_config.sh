
cd backend/backend_local_config/

echo "start local file init"
terraform init
echo "end local file init"

echo "start local file apply"
terraform apply --auto-approve
echo "end local file apply"

cd ../../infra
echo  "start core infra backend config"
terraform init -reconfigure
echo  "end core infra backend config"

cd ../k8s_cluster_infra
echo  "start k8s cluster infra backend config"
terraform init -reconfigure
echo  "end k8s cluster infra backend config"

cd ../helm_infra
echo  "start helm infra backend config"
terraform init -reconfigure
echo  "end helm infra backend config"
