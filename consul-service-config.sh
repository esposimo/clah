#!/bin/bash

RED="\033[31m"
GREEN="\033[32m"
RESET="\033[0m"
REDB="\033[31m"
GREENB="\033[1;32m"
BOLD="\033[1m"

usage()
{
  printf "\nUsage: $0 init|destroy sc\n\n"
}

error_msg()
{
  printf "${REDB}[ERROR]${RESET} $*\n"
}

set_value()
{
  KEY_NAME=$1
  shift 1;
  KEY_VALUE=$*
  CURL_TEMP_FILE=$(mktemp)
  printf "%s" "$KEY_VALUE" > ${CURL_TEMP_FILE};
  curl --request PUT \
   --data @${CURL_TEMP_FILE} \
   ${CLAH_SC_ENDPOINT}/v1/kv/${KEY_NAME} 2>/dev/null 1>&2 || { error_msg "Error on insert ${KEY_NAME}"; exit 1;};
  rm -f ${CURL_TEMP_FILE};
}

if [[ -z $1 ]] ; then
	usage;
	exit;
fi;

DOCKER_HOST_IP=$(ip route get 8.8.8.8 | grep -oP 'src \K\S+')
CLAH_SC_BASE_IMAGE="${CLAH_SC_BASE_IMAGE:=hashicorp/consul:1.20}"
CLAH_SC_CONTAINER_NAME="${CLAH_SC_CONTAINER_NAME:=tf-data-container}"
CLAH_SC_CONTAINER_IMAGE="${CLAH_SC_CONTAINER_IMAGE:=tf-data-image}"
CLAH_SC_VOLUME_NAME="${CLAH_SC_VOLUME_NAME=tf-data-volume}"
CLAH_SC_HOST_PORT="${CLAH_SC_HOST_PORT=16080}"
CLAH_SC_ENDPOINT="http://${DOCKER_HOST_IP}:${CLAH_SC_HOST_PORT}"
RUN_DIR=$(cd "$(dirname $0)" && pwd)

create_service_config()
{
  printf "Creating volume ${CLAH_SC_VOLUME_NAME}"
  docker volume create ${CLAH_SC_VOLUME_NAME} || { error_msg "Volume creation failed" ; exit 1; };
  docker build -f ${RUN_DIR}/service-config/Dockerfile -t ${CLAH_SC_CONTAINER_IMAGE} ${RUN_DIR}/service-config || { error_msg "Image build failed" ; exit 1; }

  docker run -d \
    --name=${CLAH_SC_CONTAINER_NAME} \
    -p ${CLAH_SC_HOST_PORT}:8500 \
    -v ${CLAH_SC_VOLUME_NAME}:/consul/data \
    ${CLAH_SC_CONTAINER_IMAGE} || { error_msg "Container startup failed" ; exit 1; }


  CONTAINER_STATUS=$(docker inspect --format '{{ .State.Status }}' ${CLAH_SC_CONTAINER_NAME})
  CONTAINER_START=$(docker inspect --format '{{ .State.StartedAt }}' ${CLAH_SC_CONTAINER_NAME})
  IP_ADDRESS_INTERNAL=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' ${CLAH_SC_CONTAINER_NAME})
  printf "${GREENB}Consul Storage for Terraform State started${RESET}\n";
  printf "\t${BOLD}Started At:${RESET}\t ${CONTAINER_START}\n";
  printf "\t${BOLD}Status:${RESET}\t\t ${CONTAINER_STATUS}\n";
  printf "\t${BOLD}IP Container:${RESET}\t ${IP_ADDRESS_INTERNAL}\n";
  printf "\t${BOLD}IP External:${RESET}\t ${DOCKER_HOST_IP}\n";
  printf "\t${BOLD}Endpoint:${RESET}\t http://${DOCKER_HOST_IP}:${CLAH_SC_HOST_PORT}/\n";
  sleep 1;
  set_value "infrastructure/compute/docker/host" "${DOCKER_HOST_IP}"
  set_value "infrastructure/compute/docker/socketfile" "unix:///var/run/docker.sock"
  set_value "infrastructure/compute/docker/endpoint" ""
  set_value "infrastructure/service-config/container/name" "${CLAH_SC_CONTAINER_NAME}"
  set_value "infrastructure/service-config/container/image" "${CLAH_SC_BASE_IMAGE}"
  set_value "infrastructure/service-config/container/consul-image" "${CLAH_SC_CONTAINER_IMAGE}"
  set_value "infrastructure/service-config/container/volume-data" "${CLAH_SC_VOLUME_NAME}"
  set_value "environments/list-by-name" "{}";
  set_value "environments/list-by-uuid" "{}";
}

destroy_service_config()
{
  printf "\n${BOLD}If you destroy the storage, Terraform will no longer be able to retrieve the state of the resources${RESET}\n";
  printf "${BOLD}Do you confirm? [y/n] :${RESET} "
  read -p "" confirm
  if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
    printf "Stopping container ${CLAH_SC_CONTAINER_NAME}\n";
    docker container stop ${CLAH_SC_CONTAINER_NAME} > /dev/null || { error_msg "Unable to stop container ${CLAH_SC_CONTAINER_NAME}" ; exit 1; }
    printf "removing container ${CLAH_SC_CONTAINER_NAME}\n";
    docker container rm ${CLAH_SC_CONTAINER_NAME} > /dev/null || { error_msg "Unable to remove container ${CLAH_SC_CONTAINER_NAME}" ; exit 1; }
    printf "Removing volume ${CLAH_SC_VOLUME_NAME}\n";
    docker volume rm ${CLAH_SC_VOLUME_NAME} > /dev/null || { error_msg "Unable to remove volume ${CLAH_SC_VOLUME_NAME}" ; exit 1; }
    printf "Removing image ${CLAH_SC_CONTAINER_IMAGE}\n";
    docker image rm --force ${CLAH_SC_CONTAINER_IMAGE} > /dev/null || { error_msg "Unable to remove image ${CLAH_SC_CONTAINER_IMAGE}" ; exit 1; }
  fi;
}

case "$1" in 
  "init")
  create_service_config;
  ;;
  "destroy")
  destroy_service_config;
  ;;
  *)
  usage;
  exit 1;
  ;;
esac
