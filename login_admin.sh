#!/bin/bash

# MFA 토큰 코드를 입력 인수로 받기
token_code="$1"
mfa_device="arn:aws:iam::986069063944:mfa/mac_device_for_admin"

# MFA 인증을 통해 임시 자격 증명을 가져오기 (텍스트 형식으로 출력)
creds_text=$(aws sts get-session-token --serial-number $mfa_device --token-code "$token_code" --profile admin --output text)

# 자격 증명 정보를 추출하여 환경 변수로 설정하기
IFS=$'\t' read -ra creds <<< "$creds_text"

AWS_ACCESS_KEY_ID="${creds[1]}"
AWS_SECRET_ACCESS_KEY="${creds[3]}"
AWS_SESSION_TOKEN="${creds[4]}"
EXPIRATION="${creds[2]}"

aws configure set aws_access_key_id "${creds[1]}"
aws configure set aws_secret_access_key "${creds[3]}"
aws configure set aws_session_token "${creds[4]}"

# 자격 증명 정보 출력 (선택 사항)
echo "AWS_ACCESS_KEY_ID: $AWS_ACCESS_KEY_ID"
echo "AWS_SECRET_ACCESS_KEY: $AWS_SECRET_ACCESS_KEY"
echo "AWS_SESSION_TOKEN: $AWS_SESSION_TOKEN"
echo "EXPIRATION: $EXPIRATION"

# 임시 자격 증명을 사용하여 AWS CLI를 사용할 수 있습니다.
# 예: aws s3 ls

# 스크립트 실행 시, 임시 자격 증명을 사용하도록 환경 변수를 설정하게 됩니다.

