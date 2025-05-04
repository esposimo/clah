#!/bin/bash


source $CLAH_HOME/env

if [[ -z "${CLAH_SC_CONTAINER_NAME}" || -z "${CLAH_SC_CONTAINER_IMAGE}" || -z "${CLAH_SC_VOLUME_NAME}" || -z "${CLAH_SC_CONTAINER_PORT}" ]] ; then
  printf "Una o più variabili d'ambiente nel file ./env non è stata valorizzata\n";
  exit 1;
fi;



COMMAND=$1
shift 1
PARAMS=$*

put_kv()
{
    CURL_TEMP_FILE=$(mktemp)
    echo $KEY_VALUE > ${CURL_TEMP_FILE};
    curl --request PUT \
     --data @${CURL_TEMP_FILE} \
     ${CLAH_SC_ENDPOINT}/v1/kv/${KEY_NAME} || { printf "Errore nell'inserimento della chiave sul SC\n"; };
     rm ${CURL_TEMP_FILE};
}

get_kv()
{
    RETURN_VALUE=$(curl ${CLAH_SC_ENDPOINT}/v1/kv/${KEY_NAME} 2>/dev/null | jq -r '.[0].Value' | base64 --decode)
    printf "${RETURN_VALUE}\n";
}

ls_kv()
{
    curl ${CLAH_SC_ENDPOINT}/v1/kv/${KEY_NAME}/?keys 2>/dev/null
    printf "\n";
}


case "$COMMAND" in
    put)
        KEY_NAME=$1
        shift 1;
        KEY_VALUE=$*
        put_kv $KEY_NAME $KEY_VALUE
        exit;
        ;;
    get)
        KEY_NAME=$1
        get_kv $KEY_NAME
        exit;
        ;;
    ls)
        KEY_NAME=$1
        ls_kv $KEY_NAME
        exit;
        ;;
    *)
        exit 1;
        ;;
esac