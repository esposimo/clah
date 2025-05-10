#!/bin/bash


terraform init -reconfigure -backend-config="./config/backend.tfvars"
terraform apply -var-file="./config/variables.tfvars"

