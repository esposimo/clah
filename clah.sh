#!/bin/bash



COMMAND=$1
shift 1

source "${CLAH_HOME}/env"

case "$COMMAND" in
    sc)
        $CLAH_HOME/tools/sc.sh $*
        ;;
    init)
        $CLAH_HOME/tools/init.sh $*
        ;;
    destroy)
        $CLAH_HOME/tools/destroy.sh $*
        ;;
    *)
        usage;
        ;;
esac

