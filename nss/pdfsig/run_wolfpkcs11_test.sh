#!/bin/bash

docker build -t wolfpkcs11-nss-pdf .
docker run -t wolfpkcs11-nss-pdf .

