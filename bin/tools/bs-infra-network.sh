#!/bin/bash

usage()
{
  printf "\nUsage: clah init|destroy network\n\n"
}

show_version()
{
    printf "clah version ${CLAH_VERSION}\n";
}


if [[ -z $1 ]] ; then
	usage;
	exit;
fi;

COMMAND=$1

case "$COMMAND" in
    init)
        cd $CLAH_HOME/infrastructure/network/
        $CLAH_BIN/tools/tf.sh apply
        ;;
    destroy)
        cd $CLAH_HOME/infrastructure/network/
        $CLAH_BIN/tools/tf.sh destroy
        ;;
    help|-h|--help)
        if [[ -z $1 ]] ; then
            usage;
            exit;
        fi;
        ;;
    version|-v|--version)
        show_version;
        exit;
        ;;
    *)
        usage;
        ;;
esac