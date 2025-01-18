#!/bin/bash

if [[ ! -e old_namespace.txt ]]; then
    touch old_namespace.txt
fi

kubectl get namespaces | awk '{if (NR>1) print $1}' > new_namespace.txt

CATCH_DIFF=$(diff old_namespace.txt new_namespace.txt)

if [ -z "$CATCH_DIFF" ]; then
  echo "Namespaces are the same"
else
  echo "Namespaces are different"
  /etc/init.d/replace_ecr_token.sh
  mv new_namespace.txt old_namespace.txt
fi