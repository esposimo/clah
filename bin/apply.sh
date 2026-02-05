#!/bin/bash
PARSE_HOST=$(parse_endpoint ${CLAH_SC_ENDPOINT});
CLAH_SC_HOST=$(echo ${PARSE_HOST} | jq -r '.host');
CLAH_SC_PORT=$(echo ${PARSE_HOST} | jq -r '.port');
CLAH_SC_SCHEME=$(echo ${PARSE_HOST} | jq -r '.scheme');
CONFIG_PATH=$2
export CONSUL_HTTP_ADDR=${CONSUL_HTTP_ADDR:=localhost:16080}
export CONSUL_HTTP_SSL=${CONSUL_HTTP_SSL:=false}
#export DOCKER_HOST=${DOCKER_HOST:=unix:///var/run/docker.sock}
#export VAULT_TOKEN=$(get_kv "infrastructure/vault/app/root-key")
#export VAULT_ADDR=$(get_kv "infrastructure/vault/app/internal-endpoint")
#export VAULT_SKIP_VERIFY=true

# metto $2 perchè nel clah.sh c'è uno shift prima di chiamare la funzione apply_terraform

# $1 is second parameter of clah command
apply_terraform()
{
    if [[ -z $1 ]] ; then
        clah_usage_command apply
        exit;
    fi;

    DEFAULT_BACKEND_FILE="backend.tfvars"
    DEFAULT_VARIABLES_FILE="variables.tfvars"
    ENV_NAME=$1
    ENV_PATH="./cfg/${ENV_NAME}"

    if [[ ! -d ${ENV_PATH} ]] ; then
        echo "${ENV_NAME} environment doesn't exists";
        exit;
    fi;

    AUTO_APPROVE=""
    if is_flag "-y" ; then
        AUTO_APPROVE="-auto-approve"
    fi;
    shift 1; # remove ENV NAME argument from input then you can inject any terraform parameters

    terraform init -reconfigure \
       -backend-config="address=${CLAH_SC_HOST}:${CLAH_SC_PORT}" \
       -backend-config="scheme=${CLAH_SC_SCHEME}" \
       -backend-config="${ENV_PATH}/${DEFAULT_BACKEND_FILE}"

    terraform apply ${AUTO_APPROVE} \
            -var-file="${ENV_PATH}/${DEFAULT_VARIABLES_FILE}" \
            $@
}

destroy_terraform()
{
    if [[ -z $1 ]] ; then
        clah_usage_command destroy
        exit;
    fi;


    DEFAULT_BACKEND_FILE="backend.tfvars"
    DEFAULT_VARIABLES_FILE="variables.tfvars"
    ENV_NAME=$1
    ENV_PATH="./cfg/${ENV_NAME}"

    if [[ ! -d ${ENV_PATH} ]] ; then
        echo "${ENV_NAME} environment doesn't exists";
        exit;
    fi;

    AUTO_APPROVE=""
    if is_flag "-y" ; then
        AUTO_APPROVE="-auto-approve"
    fi;
    shift 1; # remove ENV NAME argument from input then you can inject any terraform parameters

    terraform init -reconfigure \
       -backend-config="address=${CLAH_SC_HOST}:${CLAH_SC_PORT}" \
       -backend-config="scheme=${CLAH_SC_SCHEME}" \
       -backend-config="${ENV_PATH}/${DEFAULT_BACKEND_FILE}"

    terraform apply -destroy ${AUTO_APPROVE} \
            -var-file="${ENV_PATH}/${DEFAULT_VARIABLES_FILE}" \
            $@
}