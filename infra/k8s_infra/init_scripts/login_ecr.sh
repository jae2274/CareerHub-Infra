echo "***Get login ecr automatically***"
apt-get install -y awscli
aws ecr get-login-password --region ${region} | docker login --username AWS --password-stdin ${ecr_domain}

cat <<EOF | tee login_docker.sh > /dev/null
#!/bin/bash
aws ecr get-login-password --region ${region} | docker login --username AWS --password-stdin ${ecr_domain}
EOF

chmod +x login_docker.sh

mv login_docker.sh /etc/init.d/login_docker.sh
cat <<EOF | tee /etc/cron.d/cron_docker > /dev/null
*/10 * * * * root /etc/init.d/login_docker.sh
EOF