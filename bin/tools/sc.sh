#!/bin/bash


source $CLAH_BIN/env

COMMAND=$1
shift 1
PARAMS=$*


usage()
{
    printf "\nUsage: clah config ACTION PATH VALUE\n";
    printf "\n"
    printf "Manage service config\n\n";
    printf "Actions:\n";
    printf "  put\tWrite a value in key\n";
    printf "  get\tGet value of path\n";
    printf "  ls\tList all keys in path\n";
    printf "  rm\tRemove a key or entire path\n";
    printf "  lget\tShow all keys and values in a path\n";
    printf "\n";
}


usage_put()
{
    printf "\n";
    printf "Write a value in a key indicated by PATH\n";
    printf "If PATH already exists, value will be overwritten\n";
    printf "\nUsage: clah config put PATH VALUE\n\n";
    printf "Example: ";
    printf "clah config put custom_app/endpoint http://localhost:8080\tPut value http://localhost:8080 in key custom_app/endpoint\n";
    printf "\n";
}

usage_get()
{
    printf "\n";
    printf "Show value of key indicated in PATH\n";
    printf "If PATH is a container for other keys, return error\n";
    printf "\nUsage: clah sc get PATH\n\n";
    printf "Example: ";
    printf "clah config get custom_app/endpoint\t Show value in the path custom_app/endpoint\n";
    printf "\n";
}

usage_ls()
{
    printf "\n";
    printf "Show keys in a PATH of service config\n";
    printf "If PATH is not specified, all keys will be displayed\n";
    printf "\nUsage: clah sc ls PATH\n\n";
    printf "Example: ";
    printf "clah config ls custom_app\t Show all keys in the path custom_app\n";
    printf "         clah config ls\t\t Show all keys in the service config\n";
    printf "\n";
}

usage_rm()
{
    printf "\n";
    printf "Remove a PATH from service config\n";
    printf "\nUsage: clah config rm PATH\n\n";
    printf "Example: ";
    printf "clah config rm custom_app\t\t Remove path custom_app and its subkeys from service config\n";
    printf "\n";
}

usage_lget()
{
    printf "\n";
    printf "Show all keys and values in PATH in form of key:value\n";
    printf "If PATH is not specified, all keys and values will be displayed\n\n";
    printf "Usage: clah sc lget PATH\n\n";
    printf "Example: ";
    printf "clah config lget custom_app\t Show all keys and values in path custom_app\n";
    printf "         clah config lget\t\t\t Show all keys and values in service config\n";
    printf "\n";
}

case "$COMMAND" in
    put)
        KEY_NAME=$1
        if [[ -z $KEY_NAME ]] ; then
            usage_put;
            exit;
        fi;
        shift 1;
        KEY_VALUE=$*
        get_sc_docker $KEY_NAME $KEY_VALUE
        exit;
        ;;
    get)
        KEY_NAME=$1
        if [[ -z $KEY_NAME ]] ; then
            usage_get;
            exit;
        fi;
        get_sc_docker $KEY_NAME
        exit;
        ;;
    ls)
        KEY_NAME=$1
        ls_sc_curl $KEY_NAME
        exit;
        ;;
    rm)
        KEY_NAME=$1
        if [[ -z $KEY_NAME ]] ; then
            usage_rm;
            exit;
        fi;
        rm_sc_docker $KEY_NAME
        exit;
        ;;
    lget)
        KEY_NAME=$1
        lget_sc_docker $KEY_NAME
        exit;
        ;;
    help)
        KEY_NAME=$1
        if [[ -z $KEY_NAME ]] ; then
            usage;
            exit 1;
        fi;
        if [[ "${KEY_NAME}" == "put" ]] ; then
            usage_put;
            exit;
        fi;
        if [[ "${KEY_NAME}" == "ls" ]] ; then
            usage_ls;
            exit;
        fi;
        if [[ "${KEY_NAME}" == "get" ]] ; then
            usage_get;
            exit;
        fi;
        if [[ "${KEY_NAME}" == "rm" ]] ; then
            usage_rm;
            exit;
        fi;
        if [[ "${KEY_NAME}" == "lget" ]] ; then
            usage_lget;
            exit;
        fi;
        ;;
    *)
        usage;
        exit 1;
        ;;
esac