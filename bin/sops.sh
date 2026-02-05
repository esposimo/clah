#!/bin/bash

export CONSUL_HTTP_ADDR=${CONSUL_HTTP_ADDR:=localhost:16080}
export CONSUL_HTTP_SSL=${CONSUL_HTTP_SSL:=false}

export VAULT_TOKEN=$(get_value_service_config "infrastructure/vault/app/root-key")
export VAULT_ADDR=$(get_value_service_config "infrastructure/vault/app/internal-endpoint")
export VAULT_SKIP_VERIFY=true
export EDITOR=vi

sops_usage_error()
{
    printf "%s\n" "$1"
    clah_usage_command sops
    exit 1
}

sops_require_file()
{
    if [[ -z "$1" ]] ; then
        sops_usage_error "Missing file name"
    fi
}

sops_require_command()
{
    if ! command -v sops >/dev/null 2>&1 ; then
        printf "sops command not found in PATH\n"
        exit 1
    fi
}

sops_transit_uri()
{
    local vault_addr="$VAULT_ADDR"
    local transit_engine="$1"
    local transit_key="$2"

    if [[ -z "$vault_addr" ]] ; then
        printf "VAULT_ADDR is required for this action\n"
        exit 1
    fi

    echo "${vault_addr%/}/v1/${transit_engine}/keys/${transit_key}"
}

sops_action_new()
{
    sops_require_command
    sops_require_file "$1"

    local file_name="$1"
    local transit_engine=""
    local transit_key=""

    if is_flag "-t" ; then
        transit_engine=$(get_flag_value "-t")
    elif is_flag "--transit-key" ; then
        transit_engine=$(get_flag_value "--transit-key")
    fi

    if is_flag "-k" ; then
        transit_key=$(get_flag_value "-k")
    elif is_flag "--key" ; then
        transit_key=$(get_flag_value "--key")
    fi

    if [[ -z "$transit_engine" || -z "$transit_key" ]] ; then
        sops_usage_error "-t/--transit-key and -k/--key are mandatory for 'new'"
    fi

    if [[ -f "$file_name" ]] ; then
        printf "File '%s' already exists\n" "$file_name"
        exit 1
    fi

    printf "{}\n" > "$file_name"

    local transit_uri
    transit_uri=$(sops_transit_uri "$transit_engine" "$transit_key")

    sops encrypt -i --hc-vault-transit "$transit_uri" "$file_name"
    sops edit "$file_name"
}

sops_action_edit()
{
    sops_require_command
    sops_require_file "$1"
    sops edit "$1"
}

sops_action_encrypt()
{
    sops_require_command
    sops_require_file "$1"

    local file_name="$1"

    if is_flag "-o" || is_flag "--overwrite" ; then
        sops encrypt -i "$file_name"
    else
        sops encrypt "$file_name"
    fi
}

sops_action_decrypt()
{
    sops_require_command
    sops_require_file "$1"

    local file_name="$1"

    if is_flag "-o" || is_flag "--overwrite" ; then
        sops decrypt -i "$file_name"
    else
        sops decrypt "$file_name"
    fi
}

