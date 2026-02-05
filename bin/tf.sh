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

    if [[ ! -d "./cfg/${CONFIG_PATH}" ]] ; then
        echo "Config $1 not found in cfg path";
        exit 1;
    fi;

    shift 1;

    ls ./cfg/${CONFIG_PATH}/backend.tfvars 

    terraform init -reconfigure \
        -backend-config="address=${CLAH_SC_HOST}:${CLAH_SC_PORT}" \
        -backend-config="scheme=${CLAH_SC_SCHEME}" \
        -backend-config="./cfg/${CONFIG_PATH}/backend.tfvars"

 terraform apply \
        -var-file="./cfg/${CONFIG_PATH}/variables.tfvars" \
        $@
}