#!/bin/bash



source $CLAH_HOME/env


docker container stop ${CLAH_SC_CONTAINER_NAME} >/dev/null 2>&1 || { printf "[KO] Stop and remove container\n"; exit 1; };
docker container rm ${CLAH_SC_CONTAINER_NAME} >/dev/null 2>&1 || { printf "[KO] Stop and remove container\n"; exit 1; };
printf "[OK] Stop and remove container\n";
docker image rm ${CLAH_SC_CONTAINER_IMAGE} >/dev/null 2>&1 || { printf "[KO] Remove build\n"; exit 1; };
printf "[OK] Remove build\n";
docker volume rm ${CLAH_SC_VOLUME_NAME} >/dev/null 2>&1 || { printf "[KO] Remove volume\n" ; exit 1; };
printf "[OK] Remove volume\n";