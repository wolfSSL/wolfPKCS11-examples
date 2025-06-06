#!/bin/bash

if [ "$#" -lt 1 ]; then
    echo "Usage: $0 <url>"
    exit 1
fi

docker build -t nss-curl-wolfpkcs11 .

mkdir -p ./logs
chmod 777 ./logs

docker run --rm -v "$(pwd)/logs:/logs" nss-curl-wolfpkcs11 sh -c "curl -o /dev/null -D - -s $1 || echo 'Curl exited with error code $?'"

echo "Calls that used wolfPKCS11"
grep -oP 'CKM_.+?\b' logs/nss.log | sort | uniq

