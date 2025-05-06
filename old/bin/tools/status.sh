#!/bin/bash


source $CLAH_BIN/env

COMMAND=$1
shift 1
PARAMS=$*

status()
{
    INSPECT=$(docker container inspect ${CLAH_SC_CONTAINER_NAME} 2>/dev/null)
    if [[ "$?" == "1" ]] ; then
        printf "Impossibile ricavare informazioni sul container sc\n";
        exit 1;
    fi;

    printf "Docker Host\t${CLAH_DOCKER_HOST_IP}\n";
    printf "SC Service\n";
    printf "Endpoint: ${CLAH_SC_ENDPOINT}\n";
    printf "Status: $(echo $INSPECT | jq -r .'[0].State.Status')\n";

    #echo $INSPECT | jq
}




case "$COMMAND" in
    *)
        status;
        exit;
        ;;
esac