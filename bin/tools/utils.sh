#!/bin/bash

# output
print_ok()
{
    printf "[OK] $*";
}

print_ko()
{
    printf "[KO] $*";
}

print_msg()
{
    printf $*;
}

nl() {
  local count="$1"
  if [[ -z $count ]] ; then
    count=1
  fi;
  for ((i=0; i<count; i++)); do
    printf "\n"
  done
}

# manage sc data
put_sc_curl()
{
  KEY_NAME=$1
  shift 1;
  KEY_VALUE=$*
  CURL_TEMP_FILE=$(mktemp)
  printf "%s" "$KEY_VALUE" > ${CURL_TEMP_FILE};
  curl --request PUT \
   --data @${CURL_TEMP_FILE} \
   ${CLAH_SC_ENDPOINT}/v1/kv/${KEY_NAME} 2>/dev/null 1>&2 || { print_ko "Error on insert ${KEY_NAME}"; exit 1;};
  rm -f ${CURL_TEMP_FILE};
  print_ok "inserted ${KEY_NAME}\n";
}

put_sc_docker()
{
  KEY_NAME=$1
  shift 1;
  KEY_VALUE=$*
  CURL_TEMP_FILE=$(mktemp)
  BASE_TMP=$(basename ${CURL_TEMP_FILE})
  printf "%s" "$KEY_VALUE" > ${CURL_TEMP_FILE};
  docker cp ${CURL_TEMP_FILE} ${CLAH_SC_CONTAINER_NAME}:${CURL_TEMP_FILE} 2>/dev/null 1>&2
  docker exec -it ${CLAH_SC_CONTAINER_NAME} consul kv put ${KEY_NAME} @${CURL_TEMP_FILE} 2>/dev/null 1>&2 || { print_ko "Error on insert ${KEY_NAME}"; exit 1; }
  docker exec -it ${CLAH_SC_CONTAINER_NAME} rm ${CURL_TEMP_FILE};  
  rm -f ${CURL_TEMP_FILE}
  print_ok "inserted ${KEY_NAME}\n";
}

get_sc_curl()
{
  KEY_NAME=$1
  RETURN_VALUE=$(curl ${CLAH_SC_ENDPOINT}/v1/kv/${KEY_NAME} 2>/dev/null | jq -r '.[0].Value' | base64 --decode)
  printf "${RETURN_VALUE}";
}

get_sc_docker()
{
  KEY_NAME=$1
  docker exec -it ${CLAH_SC_CONTAINER_NAME} consul kv get ${KEY_NAME} || { print_ko "Error on insert ${KEY_NAME}"; exit 1; }
}

ls_sc_curl()
{
  KEY_NAME=$1
  if [[ -z $KEY_NAME ]] ; then
    curl ${CLAH_SC_ENDPOINT}/v1/kv/?keys 2>/dev/null | jq -r '.[]' || { print_ko "Error in ls ${KEY_NAME}"; exit 1; };
    exit;
  fi;
  curl ${CLAH_SC_ENDPOINT}/v1/kv/${KEY_NAME}/?keys 2>/dev/null | jq -r '.[]' || { print_ko "Error in get ${KEY_NAME}"; exit 1; };
}

ls_sc_docker()
{
  KEY_NAME=$1
  if [[ -z $KEY_NAME ]] ; then
    docker exec -it ${CLAH_SC_CONTAINER_NAME} consul kv get -recurse -keys || { print_ko "Error in get ${KEY_NAME}"; exit 1; };
    exit;
  fi;
  docker exec -it ${CLAH_SC_CONTAINER_NAME} consul kv get -recurse -keys ${KEY_NAME} || { print_ko "Error in get ${KEY_NAME}"; exit 1; };
}

rm_sc_curl()
{
  KEY_NAME=$1
  curl -X DELETE ${CLAH_SC_ENDPOINT}/v1/kv/${KEY_NAME} 2>/dev/null 1>&2 || { print_ko "Error while removing ${KEY_NAME}"; exit 1; };
  print_ok "deleted ${KEY_NAME}\n";
}

lget_sc_docker()
{
  KEY_NAME=$1
  docker exec -it ${CLAH_SC_CONTAINER_NAME} consul kv get -recurse ${KEY_NAME} | grep -v '^[[:space:]]*$' || { print_ko "Error in get ${KEY_NAME}"; exit 1; };
}

lget_sc_curl()
{
  KEY_NAME=$1
  curl -s ${CLAH_SC_ENDPOINT}/v1/kv/${KEY_NAME}/?recurse  | jq -r '.[] | "\(.Key): \(.Value)"' | while IFS=':' read -r key val; do printf "${key}:$(echo ${val} | base64 --decode)\n\n"; done
}

rm_sc_docker()
{
  KEY_NAME=$1
  docker exec -it ${CLAH_SC_CONTAINER_NAME} consul kv delete ${KEY_NAME} 2>/dev/null 1>&2 || { print_ko "Error while removing ${KEY_NAME}"; exit 1; };
  print_ok "deleted ${KEY_NAME}\n";
}