#!/bin/bash


cd ./network/
terraform init -reconfigure -backend-config="./config/backend.tfvars"
terraform apply -auto-approve -var-file="./config/variables.tfvars"
cd ..
cd ./vault
terraform init -reconfigure -backend-config="./config/backend.tfvars"
terraform apply -auto-approve -var-file="./config/variables.tfvars"
cd ..
