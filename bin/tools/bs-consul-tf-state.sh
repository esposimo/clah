#!/bin/bash

RED="\033[31m"
GREEN="\033[32m"
RESET="\033[0m"
REDB="\033[31m"
GREENB="\033[1;32m"
BOLD="\033[1m"

usage()
{
  printf "\nUsage: clah init|destroy sc\n\n"
}

error_msg()
{
  printf "${REDB}[ERROR]${RESET} $*\n"
}

put_kv()
{
  printf "Configure kv ${BOLD}$1 ${RESET}\n";
  docker exec -it ${SC_CONTAINER_NAME} consul kv put $1 $2 > /dev/null || { error_msg "Failed to write data to the key-value store"; exit 1; }
}

if [[ -z $1 ]] ; then
	usage;
	exit;
fi;

DOCKER_HOST_IP=$(ip route get 8.8.8.8 | grep -oP 'src \K\S+')
SC_BASE_IMAGE="${SC_BASE_IMAGE:=hashicorp/consul:1.20}"
SC_CONTAINER_NAME="${SC_CONTAINER_NAME:=service-config-container}"
SC_CONTAINER_IMAGE="${SC_CONTAINER_IMAGE:=service-config-image}"
SC_VOLUME_NAME="${SC_VOLUME_NAME=service-config-volume}"
SC_HOST_PORT="${SC_HOST_PORT=15080}"
SC_ENDPOINT=""

create_service_config()
{
  printf "Creating volume ${SC_VOLUME_NAME}"
  docker volume create ${SC_VOLUME_NAME} || { error_msg "Volume creation failed" ; exit 1; };
  docker build -f ${CLAH_BIN}/tools/service-config-build/Dockerfile -t ${SC_CONTAINER_IMAGE} ${CLAH_BIN}/tools/service-config-build || { error_msg "Image build failed" ; exit 1; }

  docker run -d \
    --name=${SC_CONTAINER_NAME} \
    -p ${SC_HOST_PORT}:8500 \
    -v ${SC_VOLUME_NAME}:/consul/data \
    ${SC_CONTAINER_IMAGE} || { error_msg "Container startup failed" ; exit 1; }


  CONTAINER_STATUS=$(docker inspect --format '{{ .State.Status }}' ${SC_CONTAINER_NAME})
  CONTAINER_START=$(docker inspect --format '{{ .State.StartedAt }}' ${SC_CONTAINER_NAME})
  IP_ADDRESS_INTERNAL=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' ${SC_CONTAINER_NAME})
  printf "${GREENB}Consul Storage for Terraform State started${RESET}\n";
  printf "\t${BOLD}Started At:${RESET}\t ${CONTAINER_START}\n";
  printf "\t${BOLD}Status:${RESET}\t\t ${CONTAINER_STATUS}\n";
  printf "\t${BOLD}IP Container:${RESET}\t ${IP_ADDRESS_INTERNAL}\n";
  printf "\t${BOLD}IP External:${RESET}\t ${DOCKER_HOST_IP}\n";
  printf "\t${BOLD}Endpoint:${RESET}\t http://${DOCKER_HOST_IP}:${SC_HOST_PORT}/\n";
  put_kv "infrastructure/consul-tf-service/endpoint/fqdn" "http://${DOCKER_HOST_IP}:${SC_HOST_PORT}"
  put_kv "infrastructure/consul-tf-service/endpoint/docker-host" "${DOCKER_HOST_IP}"
  put_kv "infrastructure/consul-tf-service/endpoint/docker-port" "${SC_HOST_PORT}"
  put_kv "infrastructure/consul-tf-service/container/host" "${IP_ADDRESS_INTERNAL}"
  put_kv "infrastructure/consul-tf-service/container/port" "${SC_HOST_PORT}"
  put_kv "infrastructure/consul-tf-service/container/name" "${SC_CONTAINER_NAME}"
  put_kv "infrastructure/consul-tf-service/container/image" "${SC_CONTAINER_IMAGE}" 
  put_kv "infrastructure/consul-tf-service/container/consul_image" "hashicorp/consul:1.20" 
  put_kv "infrastructure/consul-tf-service/container/volume-data" "${SC_VOLUME_NAME}"
}

destroy_service_config()
{
  printf "\n${BOLD}If you destroy the storage, Terraform will no longer be able to retrieve the state of the resources${RESET}\n";
  printf "${BOLD}Do you confirm? [y/n] :${RESET} "
  read -p "" confirm
  if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
    printf "Stopping container ${SC_CONTAINER_NAME}\n";
    docker container stop ${SC_CONTAINER_NAME} > /dev/null || { error_msg "Unable to stop container ${CONSULT_CONTAINER_NAME}" ; exit 1; }
    printf "emoving container ${SC_CONTAINER_NAME}\n";
    docker container rm ${SC_CONTAINER_NAME} > /dev/null || { error_msg "Unable to remove container ${CONSULT_CONTAINER_NAME}" ; exit 1; }
    printf "Removing volume ${SC_VOLUME_NAME}\n";
    docker volume rm ${SC_VOLUME_NAME} > /dev/null || { error_msg "Unable to remove volume ${SC_VOLUME_NAME}" ; exit 1; }
    printf "Removing image ${SC_CONTAINER_IMAGE}\n";
    docker image rm --force ${SC_CONTAINER_IMAGE} > /dev/null || { error_msg "Unable to remove image ${SC_CONTAINER_IMAGE}" ; exit 1; }
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