#!/bin/bash



source $CLAH_BIN/env



export VAULT_TOKEN=$(get_sc_curl "infrastructure/vault/root-key")
export VAULT_ADDR=$(get_sc_curl "infrastructure/vault/external-endpoint")
export VAULT_SKIP_VERIFY=true
export EDITOR=vi
SOPS_VERSION="0.1.0"



usage()
{
    printf "\nUsage: clah sops <command> [options] FILENAME\n";
    printf "\n"
    printf "Manage secrets using SOPS and Vault's transit backend.\n";
    printf "Use this script to securely create, edit, encrypt, or decrypt secret files.\n";
    printf "\n";
    printf "Available Commands:\n";
    printf "  new\t\tCreate a new file ready for encryption\n";
    printf "  edit\t\tOpen the default editor to modify an encrypted file\n";
    printf "  encrypt\tEncrypt the file and print the result to stdout\n";
    printf "  decrypt\tDecrypt the file and print the result to stdout\n";
    printf "\n";
    printf "Parameters:\n";
    printf "  -t, --transit\t\tSpecify the Vault transit engine to use (default: sops-kv)\n";
    printf "  -k, --key\t\tSpecify the key name within the transit engine (default: sops-key-infrastructure)\n";
    printf "  -o, --overwrite\tWrite the result back to FILENAME instead of stdout\n";
    printf "\n";
    printf "Global Flags:\n";
    printf "  -h, --help\t\tShow this help\n";
    printf "  -v, --version\t\tPrint the version of sops\n";
    printf "\n";
    printf "Examples:\n";
    printf "  clah sops new secrets.yaml\n";
    printf "  clah sops encrypt secrets.yaml -t transit-engine -k my-key\n";
    printf "  clah sops decrypt secrets.yaml > secrets.dec.yaml\n";
    printf "  clah sops edit secrets.yaml\n";
}

show_version()
{
    printf "sops version ${SOPS_VERSION}\n";
}


encrypt()
{
    if [[ "$OVERWRITE" == "true" ]] ; then
        TMPFILE=$(mktemp)
        sops encrypt -i --hc-vault-transit ${VAULT_ADDR}/v1/${TRANSIT_STORE}/keys/${KEY_NAME} ${FILENAME}
    else
        sops encrypt --hc-vault-transit ${VAULT_ADDR}/v1/${TRANSIT_STORE}/keys/${KEY_NAME} ${FILENAME}
    fi;
}

decrypt()
{
    if [[ "$OVERWRITE" == "true" ]] ; then
        sops decrypt -i ${FILENAME}
    else
        sops decrypt ${FILENAME}
    fi;
}

newfile()
{
    if [[ -f ${FILENAME} ]] ; then
        printf "File già esistente\n";
        exit 1;
    fi;
    jq -n --arg value "value" '{key: $value}' > ${FILENAME};
    sops encrypt -i --hc-vault-transit ${VAULT_ADDR}/v1/${TRANSIT_STORE}/keys/${KEY_NAME} ${FILENAME}
    sops edit ${FILENAME}
}

editfile()
{
    if [[ ! -f ${FILENAME} ]] ; then
        printf "File inesistente\n";
        exit 1;
    fi;
    sops edit ${FILENAME};
}

if [[ -z $1 ]] ; then
    usage;
    exit 1;
fi;

ACTION=$1
shift 1;
PARAMS="${@}"


TRANSIT_STORE="sops-kv"
KEY_NAME="sops-key-infrastructure"
OVERWRITE=false

PARSED=$(getopt -o t:k:o -l transit:,key:overwrite -n "$PARAMS" -- "$@")
eval set -- "$PARSED"

while true; do
    case "$1" in
        -t|--transit)
            TRANSIT_STORE=$2
            shift 2;
            ;;
        -k|--key)
            KEY_NAME=$2
            shift 2;
            ;;
        -o|--overwrite)
            OVERWRITE=true
            shift 1;
            ;;
        --)
            shift;
            break;
            ;;
        *)
            printf "Opzione non riconosciuta: $1"
            exit 1;
            ;;
    esac
done

FILENAME=$1

case "$ACTION" in
    encrypt)
        encrypt;
        exit;
        ;;
    decrypt)
        decrypt;
        exit;
        ;;
    new)
        newfile
        exit;
        ;;
    edit)
        editfile;
        exit;
        ;;
    help|-h|--help)
        usage;
        exit;
        ;;
    -v|--version)
        show_version;
        exit;
        ;;
    --)
        shift;
        break;
        ;;
    *)
        printf "Operazione non riconosciuta\n";
        exit 1;
        ;;
esac




