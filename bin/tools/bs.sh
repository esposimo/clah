#!/bin/bash

usage()
{
    printf "Usage:\n  clah init|destroy <service>\n\n";
    printf "Cloud at Home - Initialize or Destroy base Services for CLAH\n\n";
    printf "Available Service:\n"
    printf "  sc\t\tService Config for storage infrastructure metadata\n";
    printf "  network\tNetwork layer for Clah services\n";
    printf "  vault\t\tVault Services for key vault, secrets, certificateS\n";
    printf "\n";
    printf "Options:\n";
    printf "  -h, --help\tShow this help message and exit\n";
    printf "  -v, --version\tPrint the version of clah\n";
    printf "\n";
    printf "Examples:\n";
    printf "  clah sc init\n";
    printf "\n";
    printf "Use \"clah help <command>\" for more information about a command\n";
}



show_version()
{
    printf "clah version ${CLAH_VERSION}\n";
}

COMMAND=$1
ACTION=$2

case "$ACTION" in
    all)
        $CLAH_BIN/tools/bs-all.sh $COMMAND
        ;;
    sc)
        $CLAH_BIN/tools/bs-consul-tf-state.sh $COMMAND
        ;;
    network)
        $CLAH_BIN/tools/bs-infra-network.sh $COMMAND
        ;;
    vault)
        $CLAH_BIN/tools/bs-infra-vault.sh $COMMAND
        ;;
    help|-h|--help)
        usage;
        exit;
        ;;
    version|-v|--version)
        show_version;
        exit;
        ;;
    *)
        usage;
        ;;
esac