#!/bin/bash



source $CLAH_BIN/env


destroy_sc()
{
    docker container stop ${CLAH_SC_CONTAINER_NAME} >/dev/null 2>&1 || { print_ko "Stop container not possible\n"; exit 1; };
    docker container rm ${CLAH_SC_CONTAINER_NAME} >/dev/null 2>&1 || { print_ko "Remove container not possible\n"; exit 1; };
    print_ok "Stop and remove container\n";
    docker image rm ${CLAH_SC_CONTAINER_IMAGE} >/dev/null 2>&1 || { print_ko "Remove build\n"; exit 1; };
    print_ok "Remove build\n";
    docker volume rm ${CLAH_SC_VOLUME_NAME} >/dev/null 2>&1 || { print_ko "Remove volume\n" ; exit 1; };
    print_ok "Remove volume\n";
}

destroy_network()
{
 docker network rm ${CLAH_DOCKER_NETWORK_NAME} >/dev/null 2>&1 || { print_ko "Removing network failed\n"; exit 1; };
 print_ok "Network removed\n";
}


destroy_elastic()
{
    docker container stop elastic_master;
    docker container rm elastic_master;
    rm -rf ${CLAH_ELASTIC_MASTER_DATA_PATH};
    rm -rf ${CLAH_ELASTIC_COLD_DATA_PATH};
}

COMMAND=$1
case "$COMMAND" in
  sc)
    destroy_sc;
    ;;
  network)
    destroy_network;
    ;;
  all)
    destroy_elastic;
    destroy_sc;
    destroy_network;
    ;;
  *)
    printf "Cosa devo distruggere?\n";
    exit 1;
    ;;
esac