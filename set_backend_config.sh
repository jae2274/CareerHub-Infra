cd backend_local_config/
terraform init
terraform apply --auto-approve
cd ../
terraform init -reconfigure
