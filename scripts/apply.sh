#!/bin/bash


## ./apply -y (auto approve)

source ${CLAH_BIN}/env

if [[ "$1" == "-y" ]] ; then
    terraform init -reconfigure -backend-config="./config/backend.tfvars"
    terraform apply -auto-approve -var-file="./config/variables.tfvars" 
else
    terraform init -reconfigure -backend-config="./config/backend.tfvars"
    terraform apply -var-file="./config/variables.tfvars"
fi;


