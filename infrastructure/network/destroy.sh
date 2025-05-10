#!/bin/bash


terraform init -reconfigure -backend-config="./config/backend.tfvars"
terraform destroy -var-file="./config/variables.tfvars"

