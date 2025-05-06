#!/bin/bash


source $CLAH_BIN/env

COMMAND=$1
shift 1
PARAMS="${@}"


usage()
{
    printf "\nUsage: clah sub ACTION [PARAMETERS]\n";
    printf "\n"
    printf "Manage subscription\n\n";
    printf "Actions:\n";
    printf "  add\tAdd a subscription\n";
    printf "  ls\tList subscription\n";
    printf "  get\tGet info subscription\n";
    printf "  rm\tRemove subscripion\n";
    printf "\n";
    printf "Parameters: (only for for add action)\n";
    printf "  -s, --short-name\tShort name for subscription\n";
    printf "  -d, --description\tDescription for subscription\n";
}

usage_add()
{
    printf "\nUsage: clah sub add NAME [PARAMETERS]\n";
    printf "\n"
    printf "Parameters:\n";
    printf "  -s, --short-name\tShort name for subscription\n";
    printf "  -d, --description\tDescription for subscription\n";
}

usage_rm()
{
    printf "\nUsage: clah sub rm NAME\n";
    printf "\n"
}

usage_ls()
{
    printf "\nUsage: clah sub ls\n";
    printf "\n"
}

usage_get()
{
    printf "\nUsage clah sub get NAME\n";
    printf "\n";
}

SHORT_NAME=""
DESCRIPTION=""


add_subscription()
{
    SUB_NAME=$1
    SHORT_NAME=$2
    DESCRIPTION="${@:3}"
    EXISTS_SUB=$(ls_kv_docker infrastructure/subscription/${SUB_NAME} | wc -l)
    if [[ $EXISTS_SUB -gt 0 ]] ; then
        printf "Subscription \"${SUB_NAME}\" already exists\n";
        exit;
    fi;
    put_kv_docker "infrastructure/subscription/${SUB_NAME}/name" ${SUB_NAME} >/dev/null
    if [[ ! -z ${SHORT_NAME} ]] ; then
        put_kv_docker "infrastructure/subscription/${SUB_NAME}/short-name" ${SHORT_NAME} >/dev/null;
    fi;
    if [[ ! -z ${DESCRIPTION} ]] ; then
        put_kv_docker "infrastructure/subscription/${SUB_NAME}/description" ${DESCRIPTION} >/dev/null;
    fi;
    print_ok "Subscription \"${SUB_NAME}\" created\n";
}

case "$COMMAND" in
    add)
        SUB_NAME=$1
        if [[ -z $PARAMS ]] ; then
            usage_add;
            exit;
        fi;
        shift 1;
        PARSED=$(getopt -o s:d: -l short-name:,description: -n "$PARAMS" -- "$@")
        eval set -- "$PARSED"
        while true; do
            case "$1" in
                -s|--short-name)
                    SHORT_NAME="$2"
                    shift 2;
                    ;;
                -d|--description)
                    DESCRIPTION="$2"
                    shift 2;
                    ;;
                --)
                    shift;
                    break;
                    ;;
                *)
                    printf "Opzione non riconosciuta: $1"
                    exit 1;
                    ;;
            esac;
        done;
        add_subscription ${SUB_NAME} ${SHORT_NAME} ${DESCRIPTION};
        exit;
        ;;
    ls)
        COUNT_SUB=$(ls_kv_curl infrastructure/subscription | cut -f3 -d"/" | sort -u | wc -l)
        printf "Subscription founded: ${COUNT_SUB}\n";
        for s in $(ls_kv_curl infrastructure/subscription | cut -f3 -d"/" | sort -u) ; do
            O_SUB_NAME=$(get_kv_curl infrastructure/subscription/${s}/name)
            O_SHORT_NAME=$(get_kv_curl infrastructure/subscription/${s}/short-name)
            O_DESCRIPTION=$(get_kv_curl infrastructure/subscription/${s}/description)
            printf "${O_SUB_NAME} (short: ${O_SHORT_NAME}, description: ${O_DESCRIPTION})\n";
        done;
        exit;
        ;;
    get)
        SUB_NAME=$1
        if [[ -z $SUB_NAME ]] ; then
            usage;
            exit 1;
        fi;
        EXISTS_SUB=$(ls_kv_docker infrastructure/subscription/${SUB_NAME} | wc -l)
        if [[ $EXISTS_SUB -eq 0 ]] ; then
            printf "Subscription \"${SUB_NAME}\" doesn't exists\n";
            exit;
        fi;
        O_SUB_NAME=$(get_kv_curl infrastructure/subscription/${SUB_NAME}/name)
        O_SHORT_NAME=$(get_kv_curl infrastructure/subscription/${SUB_NAME}/short-name)
        O_DESCRIPTION=$(get_kv_curl infrastructure/subscription/${SUB_NAME}/description)
        printf "${O_SUB_NAME} (short: ${O_SHORT_NAME}, description: ${O_DESCRIPTION})\n";
        ;;
    rm)
        SUB_NAME=$1
        if [[ -z $SUB_NAME ]] ; then
            usage;
            exit 1;
        fi;
        EXISTS_SUB=$(ls_kv_docker infrastructure/subscription/${SUB_NAME} | wc -l)
        if [[ $EXISTS_SUB -eq 0 ]] ; then
            printf "Subscription \"${SUB_NAME}\" doesn't exists\n";
            exit;
        fi;
        rm_kv_curl infrastructure/subscription/${SUB_NAME};
        ;;
    help)
        SUB_NAME=$1
        if [[ -z $SUB_NAME ]] ; then
            usage;
            exit 1;
        fi;
        if [[ "${SUB_NAME}" == "add" ]] ; then
            usage_add;
            exit 1;
        fi;
        if [[ "${SUB_NAME}" == "rm" ]] ; then
            usage_rm;
            exit 1;
        fi;
        if [[ "${SUB_NAME}" == "ls" ]] ; then
            usage_ls;
            exit 1;
        fi;
        if [[ "${SUB_NAME}" == "get" ]] ; then
            usage_get;
            exit 1;
        fi;
        ;;
    *)
        usage;
        exit 1;
        ;;
esac