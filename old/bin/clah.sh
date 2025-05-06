#!/bin/bash

COMMAND=$1
shift 1

source "${CLAH_BIN}/env"

usage()
{
    printf "\nUsage: clah OPERATION ACTION [PARAMETERS]\n";
    printf "\n"
    printf "Manage Cloud at Home\n\n";
    printf "Operations:\n";
    printf "  init\t\tBootstrap for cloud at home\n";
    printf "  destroy\tDestroy all in the cloud!\n";
    printf "\n";
    printf "  tf\t\tManage terraform projects\n";
    printf "  sc\t\tManage service config\n";
    printf "  status\tGet status of cloud\n";
    printf "  sub\t\tManage subscription\n";
    printf "\n";
}


case "$COMMAND" in
    sc)
        $CLAH_BIN/tools/sc.sh "$@"
        ;;
    init)
        $CLAH_BIN/tools/init.sh "$@"
        ;;
    destroy)
        $CLAH_BIN/tools/destroy.sh "$@"
        ;;
    status)
        $CLAH_BIN/tools/status.sh "$@"
        ;;
    sub)
        $CLAH_BIN/tools/subscription.sh "$@"
        ;;
    tf)
        $CLAH_BIN/tools/terraform.sh "$@"
        ;;
    help)
        usage;
        ;;
    *)
        usage;
        ;;
esac

