
cd backend/backend_local_config/

echo "start local file init"
terraform init
echo "end local file init"

echo "start local file apply"
terraform apply --auto-approve
echo "end local file apply"

cd ../../infra
echo  "start backend config"
terraform init -reconfigure
echo  "end backend config"
