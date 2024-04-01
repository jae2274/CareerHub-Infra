echo "***Get login ecr automatically***"
mkdir /home/ubuntu/.docker



cat <<EOF | tee login_docker.sh > /dev/null
#!/bin/bash
%{ for ecr in ecrs ~}
aws ecr get-login-password --region ${ecr.region} | docker login --username AWS --password-stdin ${ecr.domain}
cp /root/.docker/config.json /home/ubuntu/.docker/config.json
%{ endfor ~}
EOF

chmod +x login_docker.sh
./login_docker.sh

mv login_docker.sh /etc/init.d/login_docker.sh
cat <<EOF | tee /etc/cron.d/cron_docker > /dev/null
*/10 * * * * root /etc/init.d/login_docker.sh
EOF