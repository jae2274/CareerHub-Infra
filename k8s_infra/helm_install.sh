#/bin/bash!

set -e


ACCOUNT_ID=$(aws sts get-caller-identity | jq -r '.Account')
aws ecr get-login-password --region $1 | helm registry login --username AWS --password-stdin $ACCOUNT_ID.dkr.ecr.$1.amazonaws.com

# AWS Secrets Manager에서 SecretString을 가져옴
SECRET_VALUE=$(aws secretsmanager get-secret-value --region $1 --secret-id $2)

# SecretString에서 username과 password를 추출하여 변수에 할당
DB_USERNAME=$(echo "$SECRET_VALUE" | jq -r '.SecretString | fromjson | .username')
DB_PASSWORD=$(echo "$SECRET_VALUE" | jq -r '.SecretString | fromjson | .password')

helm install $3 oci://$4 --set dbUsername=$DB_USERNAME --set dbPassword=$DB_PASSWORD
