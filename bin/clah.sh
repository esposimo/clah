#!/bin/bash

COMMAND=$1
shift 1
CLAH_VERSION="0.1.0"


usage()
{
    printf "Usage:\n  clah <command> <options>\n\n";
    printf "Cloud at Home - Manage your local cloud infrastracture components\n\n";
    printf "Available Commands:\n"
    printf "  sc\t\tInitialize Service Config\n";
    printf "  sops\t\tManage secrets using SOPS\n";
    printf "  vault\t\tInteract with HashiCorp Vault\n"
    printf "  users\t\tManage users\n";
    printf "  help\t\tShow help for a specific command\n";
    printf "\n";
    printf "Options:\n";
    printf "  -h, --help\tShow this help message and exit\n";
    printf "  -v, --version\tPrint the version of clah\n";
    printf "\n";
    printf "Examples:\n";
    printf "  clah sc get infrastructure/vault-external-ip\n";
    printf "  clah sops encrypt secrets.json\n";
    printf "  clah vault get mysql-kv/password\n";
    printf "\n";
    printf "Use \"clah help <command>\" for more information about a command\n";
}


show_version()
{
    printf "clah version ${CLAH_VERSION}\n";
}

case "$COMMAND" in
    sc)
        $CLAH_HOME/scripts/consul-tf-state.sh "$@"
        ;;
    sops)
        $CLAH_BIN/tools/sops.sh "$@"
        ;;
    help|-h|--help)
        if [[ -z $1 ]] ; then
            usage;
            exit;
        fi;
        if [[ "$1" == "sops" ]] ; then
            $CLAH_BIN/tools/sops.sh help;
            exit;
        fi;
        usage;
        ;;
    version|-v|--version)
        show_version;
        exit;
        ;;
    *)
        usage;
        ;;
esac