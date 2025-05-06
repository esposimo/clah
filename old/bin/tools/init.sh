#!/bin/bash


source $CLAH_BIN/env

init_sc()
{
  docker volume create ${CLAH_SC_VOLUME_NAME} >/dev/null 2>&1 || { print_ko "Create volume failed\n" ; exit 1; };
  print_ok "Create Volume\n";

  docker build -f ${CLAH_BIN}/tools/build-sc/Dockerfile -t ${CLAH_SC_CONTAINER_IMAGE} ${CLAH_BIN}/tools/build-sc >/dev/null 2>&1 || { print_ko "Build image failed\n" ; exit 1; }
  print_ok "Create build\n";

  docker run -d \
      --name=${CLAH_SC_CONTAINER_NAME} \
      -p ${CLAH_SC_CONTAINER_PORT}:8500 \
      -v ${CLAH_SC_VOLUME_NAME}:/consul/data \
      -v /etc/timezone:/etc/timezone:ro \
      -v /etc/localtime:/etc/localtime:ro \
      --network ${CLAH_DOCKER_NETWORK_NAME} \
      ${CLAH_SC_CONTAINER_IMAGE} >/dev/null 2>&1 || { printf "Failed to start container\n" ; exit 1; }
  print_ok "Start container\n";

  print_ok "Endpoint: ${CLAH_SC_ENDPOINT}\n";
  nl;
  IP_ADDRESS_INTERNAL=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' ${CLAH_SC_CONTAINER_NAME})
  put_kv_docker "infrastructure/sc/endpoint/fqdn" "http://${CLAH_DOCKER_HOST_IP}:${CLAH_SC_CONTAINER_PORT}"
  put_kv_docker "infrastructure/sc/endpoint/docker-host" "${CLAH_DOCKER_HOST_IP}"
  put_kv_docker "infrastructure/sc/endpoint/docker-port" "${CLAH_SC_CONTAINER_PORT}"
  put_kv_docker "infrastructure/sc/container/host" "${IP_ADDRESS_INTERNAL}"
  put_kv_docker "infrastructure/sc/container/port" "${CLAH_SC_CONTAINER_PORT}"
  put_kv_docker "infrastructure/sc/container/name" "${CLAH_SC_CONTAINER_NAME}"
  put_kv_docker "infrastructure/sc/container/image" "${CLAH_SC_CONTAINER_IMAGE}" 
  put_kv_docker "infrastructure/sc/container/consul_image" "hashicorp/consul:1.20" 
  put_kv_docker "infrastructure/sc/container/volume-data" "${CLAH_SC_VOLUME_NAME}"
  put_kv_docker "infrastructure/network/name" "${CLAH_DOCKER_NETWORK_NAME}"
  put_kv_docker "infrastructure/network/gateway" "${CLAH_DOCKER_NETWORK_GATEWAY}"
  put_kv_docker "infrastructure/network/subnet" "${CLAH_DOCKER_NETWORK_SUBNET}"
}


init_network()
{
  docker network create --subnet=${CLAH_DOCKER_NETWORK_SUBNET} --gateway=${CLAH_DOCKER_NETWORK_GATEWAY} ${CLAH_DOCKER_NETWORK_NAME} >/dev/null 2>&1 || { print_ko "Create nerwork failed\n"; exit 1; };
  #docker network create --subnet=${CLAH_DOCKER_NETWORK_SUBNET} --gateway=${CLAH_DOCKER_NETWORK_GATEWAY} ${CLAH_DOCKER_NETWORK_NAME}
  print_ok "Infrastructure network created: ${CLAH_DOCKER_NETWORK_NAME} (gateway: ${CLAH_DOCKER_NETWORK_GATEWAY}, subnet: ${CLAH_DOCKER_NETWORK_SUBNET})\n";
}

init_elastic()
{
  CERT_FILE=$(mktemp -u)
  KEY_FILE=$(mktemp -u)
  mkdir -p ${CLAH_ELASTIC_MASTER_DATA_PATH} 2>/dev/null || { print_ko "Create data path for elastic hot failed\n"; exit 1; };
  mkdir -p ${CLAH_ELASTIC_COLD_DATA_PATH} 2>/dev/null || { print_ko "Create data path for elastic cold failed\n"; exit 1; };
  chown -R 1000:0 ${CLAH_ELASTIC_MASTER_DATA_PATH};
  #chown -R 1000:0 ${CLAH_ELASTIC_MASTER_DATA_PATH} 2>/dev/null || { print_ko "Setting permission for path of elastic hot failed\n"; exit 1; };
  #chown -R 1000:0 ${CLAH_ELASTIC_COLD_DATA_PATH} 2>/dev/null || { print_ko "Setting permission for path of elastic cold failed\n"; exit 1; };
  print_ok "Create directories for elastic hot and cold\n";
  print_ok "Setting up owner for directories of elastic hot and cold\n";
  #openssl req -x509 -newkey rsa:4096 -keyout ${KEY_FILE} -out ${CERT_FILE} -sha256 -days 3650 -nodes -sub "/C=IT/ST=Italy/L=Italy/O=CLAH/OU=CLAH-IT/CN=${CLAH_DOCKER_HOST_IP}" 2>/dev/null || { print_ko "Error on creating self-signed certificate for kibana\n"; exit 1; };

  docker run -d \
      --name=elastic_master \
      -v /etc/timezone:/etc/timezone:ro \
      -v /etc/localtime:/etc/localtime:ro \
      -v ${CLAH_ELASTIC_MASTER_DATA_PATH}:/usr/share/elasticsearch/data \
      -e node.name="elastic_content" \
      -e cluster_name="cluster_elastic" \
      -e node.roles="master, data_content, data_hot" \
      -e "ES_JAVA_OPTS=-Xms1g -Xmx1g" \
      docker.elastic.co/elasticsearch/elasticsearch:8.10.2 2>/dev/null || { print_ko "Unable to start elastic master node\n"; exit 1; };

  OK_ELASTIC=2
  printf "\nTry to generate elastic root password ";
    while [ ${OK_ELASTIC} != 0 ] ; do
	    ELASTIC_PASSWORD=$(docker exec -it elastic_master /usr/share/elasticsearch/bin/elasticsearch-reset-password -u elastic -b -s)
	    OK_ELASTIC=$?
      if [[ "${OK_ELASTIC}" == "1" ]] ; then
        exit 1;
      fi;
	  printf ".";
  done;
  echo $ELASTIC_PASSWORD;
}


COMMAND=$1
case "$COMMAND" in
  sc)
    init_sc;
    ;;
  network)
    init_network;
    ;;
  all)
    init_network;
    init_sc;
    init_elastic;
    ;;
  *)
    printf "Cosa devo iniziare?\n";
    exit 1;
    ;;
esac




