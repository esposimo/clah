#!/bin/bash

service_config_ls()
{

    SHOW_VALUE=false
    if jq -e 'any(.key == "-v")' <<< ${CLAH_PARSED_OPTIONS} >/dev/null; then
        SHOW_VALUE=true;
    fi;

    if [[ $# -gt 2 ]] ; then
        printf "too many values\n";
        exit;
    fi;

    KEY_NAME=$1

    if ${SHOW_VALUE}; then
        curl ${CLAH_SC_ENDPOINT}/v1/kv/${KEY_NAME}?recurse 2>/dev/null | jq -r '.[] | "\(.Key) \(.Value | @base64d)"' || { printf "Error in get ${KEY_NAME}\n"; exit 1; };
    else
        curl ${CLAH_SC_ENDPOINT}/v1/kv/${KEY_NAME}?keys 2>/dev/null | jq -r '.[]' || { printf "Error in get ${KEY_NAME}\n"; exit 1; };
    fi;
}

service_config_set()
{
    LOAD_FILE=false
    if jq -e 'any(.key == "-f")' <<< ${CLAH_PARSED_OPTIONS} >/dev/null; then
        LOAD_FILE=true;
        FILENAME=$(jq -r '.[] | select(.key == "-f") | .value // empty' <<< ${CLAH_PARSED_OPTIONS})
        if [[ ! -f ${FILENAME} ]] ; then
            printf "Filename ${FILENAME} doesn't exists!\n";
            exit;
        fi;
    fi;

    if [[ "${LOAD_FILE}" == "true" ]] ; then
        jq -r 'to_entries[] | "\(.key)\t\(.value)"' ${FILENAME} | while IFS=$'\t' read -r KEY VAL; do 
             curl -X PUT ${CLAH_SC_ENDPOINT}/v1/kv/${KEY} -d "${VAL}";
        done
    else
        if [[ ! $# -eq 2 ]] ; then
            printf "Wrong argument numbers!\n";
            exit;
        else
            KEY_NAME=$1
            KEY_VALUE=$2
            CURL_TEMP_FILE=$(mktemp)
            printf "%s" "$KEY_VALUE" > ${CURL_TEMP_FILE};
            curl --request PUT \
            --data @${CURL_TEMP_FILE} \
            ${CLAH_SC_ENDPOINT}/v1/kv/${KEY_NAME} 2>/dev/null 1>&2 || { printf "Error on insert ${KEY_NAME}\n"; exit 1;};
            rm -f ${CURL_TEMP_FILE};
        fi;
    fi;
}

service_config_rm()
{
    if [[ -z $1 ]] ; then
        printf "No key provided\n";
        exit;
    fi;

    if ! jq -e 'any(.key == "-f")' <<< ${CLAH_PARSED_OPTIONS} >/dev/null; then
        read -rp "Are you sure to remove key? [y/N]: " CONFIRM
        case "$CONFIRM" in
            y|Y|yes|YES|Yes)
            ;;
        *)
            printf "Operation aborted\n";
            exit 1
            ;;
        esac
    fi;

    KEY_NAME=$1
    curl -X DELETE ${CLAH_SC_ENDPOINT}/v1/kv/${KEY_NAME}?recurse 2>/dev/null 1>&2 || { printf "Error while removing ${KEY_NAME}\n"; exit 1; };
}


service_config_get()
{
    if [[ -z $1 ]] ; then
        printf "No key provided\n";
        exit;
    fi;

    KEY_NAME=$1
    RETURN_VALUE=$(curl ${CLAH_SC_ENDPOINT}/v1/kv/${KEY_NAME} 2>/dev/null | jq -r '.[0].Value' | base64 --decode)
    printf "${RETURN_VALUE}\n";

}