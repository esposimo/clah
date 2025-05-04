#!/bin/bash


source $CLAH_HOME/env

if [[ -z "${CLAH_SC_CONTAINER_NAME}" || -z "${CLAH_SC_CONTAINER_IMAGE}" || -z "${CLAH_SC_VOLUME_NAME}" || -z "${CLAH_SC_CONTAINER_PORT}" ]] ; then
  printf "Una o più variabili d'ambiente nel file ./env non è stata valorizzata\n";
  exit 1;
fi;

docker volume create ${CLAH_SC_VOLUME_NAME} >/dev/null 2>&1 || { printf "Creazione volume fallita\n" ; exit 1; };
printf "[OK] Create Volume\n";

docker build -f ./build-sc/Dockerfile -t ${CLAH_SC_CONTAINER_IMAGE} ./build-sc >/dev/null 2>&1 || { printf "Creazione build fallita\n" ; exit 1; }
printf "[OK] Create build\n";

docker run -d \
    --name=${CLAH_SC_CONTAINER_NAME} \
    -p ${CLAH_SC_CONTAINER_PORT}:8500 \
    -v ${CLAH_SC_VOLUME_NAME}:/consul/data \
    ${CLAH_SC_CONTAINER_IMAGE} >/dev/null 2>&1 || { printf "Avvio del container fallito\n" ; exit 1; }
printf "[OK] Start container\n";

printf "Endpoint: ${CLAH_SC_ENDPOINT}\n";


