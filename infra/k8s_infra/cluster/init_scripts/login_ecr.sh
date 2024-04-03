
echo "***Get login ecr automatically***"

cat <<EOF | tee replace_ecr_token.sh > /dev/null
#!/bin/bash

SHELL=/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
HOME=/root

%{ for ecr in ecrs ~}
aws ecr get-login-password --region ${ecr.region} | docker login --username AWS --password-stdin ${ecr.domain}
%{ endfor ~}
cp \$HOME/.docker/config.json /home/ubuntu/.docker/config.json

SECRET_YAML=\$(kubectl create secret generic ecr-auth --from-file=.dockerconfigjson=\$HOME/.docker/config.json --type=kubernetes.io/dockerconfigjson -o yaml --dry-run=client)
NAMESPACES=\$(kubectl get namespaces | awk '{if (NR>1) print \$1}')

echo "\$NAMESPACES" | while read namespace; do 
    echo "\$SECRET_YAML" | kubectl apply -n \$namespace -f  -;
    echo "\$SECRET_YAML" | kubectl replace -n \$namespace -f -;
    kubectl patch serviceaccount default -n \$namespace -p '{"imagePullSecrets": [{"name": "ecr-auth"}]}';
done
EOF

chmod +x replace_ecr_token.sh



echo "***Check namespaces automatically***"
cat <<EOF | tee check_namespaces.sh > /dev/null
#!/bin/bash

if [[ ! -e old_namespace.txt ]]; then
    touch old_namespace.txt
fi

kubectl get namespaces | awk '{if (NR>1) print \$1}' > new_namespace.txt

CATCH_DIFF=\$(diff old_namespace.txt new_namespace.txt)

if [ -z "\$CATCH_DIFF" ]; then
  echo "Namespaces are the same"
else
  echo "Namespaces are different"
  /etc/init.d/replace_ecr_token.sh
  mv new_namespace.txt old_namespace.txt
fi
EOF

chmod +x check_namespaces.sh
./check_namespaces.sh

echo "***Add crontab for replace_ecr_token.sh and check_namespaces***"
mv replace_ecr_token.sh /etc/init.d/replace_ecr_token.sh
mv check_namespaces.sh /etc/init.d/check_namespaces.sh

cat <<EOF | tee /etc/cron.d/cron_docker > /dev/null
* 0 * * * root /etc/init.d/replace_ecr_token.sh
* * * * * root /etc/init.d/check_namespaces.sh
EOF

