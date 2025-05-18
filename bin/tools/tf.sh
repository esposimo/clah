#!/bin/bash


## ./apply -y (auto approve)

source ${CLAH_BIN}/env


usage()
{
    printf "Usage:\n  clah tf apply|destroy [-y]\n\n";
    printf "Cloud at Home - Initialize or Destroy terraform project\n\n";
    printf "Available Command:\n"
    printf "  apply\t\tApply a terraform project\n";
    printf "  destroy\tDestroy a terraform project\n";
    printf "\n";
    printf "Options:\n";
    printf "  -y, --auto-approve\tAuto approve terraform request\n";
    printf "  -h, --help\t\tShow this help message and exit\n";
    printf "  -v, --version\t\tPrint the version of clah\n";
    printf "\n";
    printf "Examples:\n";
    printf "  clah tf apply -y\n";
    printf "  clah tf destroy\n";
    printf "\n";
    printf "Use \"clah help <command>\" for more information about a command\n";
}

env | grep CLAH

if [[ -z $1 ]] ; then
    usage;
    exit;
fi;

if [[ "$1" == "help" ]] ; then
    usage;
    exit;
fi;

if [[ "$1" == "apply" ]] ; then
    if [[ "$2" == "-y" ]] ; then
        terraform init -reconfigure -backend-config="address=127.0.0.1:${CLAH_SC_HOST_PORT}" -backend-config="./config/backend.tfvars"
        terraform apply -auto-approve -var-file="./config/variables.tfvars" -var="SC_ENDPOINT=127.0.0.1:${CLAH_SC_HOST_PORT}"
    else
        terraform init -reconfigure -backend-config="address=127.0.0.1:${CLAH_SC_HOST_PORT}" -backend-config="./config/backend.tfvars"
        terraform apply -var-file="./config/variables.tfvars" -var="SC_ENDPOINT=127.0.0.1:${CLAH_SC_HOST_PORT}"
    fi;
fi;

if [[ "$1" == "destroy" ]] ; then
    if [[ "$2" == "-y" ]] ; then
        terraform init -reconfigure -backend-config="address=127.0.0.1:${CLAH_SC_HOST_PORT}" -backend-config="./config/backend.tfvars"
        terraform destroy -auto-approve -var-file="./config/variables.tfvars" -var="SC_ENDPOINT=127.0.0.1:${CLAH_SC_HOST_PORT}"
    else
        terraform init -reconfigure -backend-config="address=127.0.0.1:${CLAH_SC_HOST_PORT}" -backend-config="./config/backend.tfvars"
        terraform destroy -var-file="./config/variables.tfvars" -var="SC_ENDPOINT=127.0.0.1:${CLAH_SC_HOST_PORT}"
    fi;
fi;

