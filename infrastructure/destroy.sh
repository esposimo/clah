#!/bin/bash


cd ./vault
terraform init -reconfigure -backend-config="./config/backend.tfvars"
terraform destroy -auto-approve -var-file="./config/variables.tfvars"
cd ..
cd ./network/
terraform init -reconfigure -backend-config="./config/backend.tfvars"
terraform destroy -auto-approve -var-file="./config/variables.tfvars"
cd ..