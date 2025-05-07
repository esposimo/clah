#!/bin/sh


TMP_FILE=$(mktemp)
vault operator init -tls-skip-verify -key-shares=1 -key-threshold=1 > ${TMP_FILE}
UNSEAL_KEY=$(cat ${TMP_FILE} | grep -E "Unseal Key 1:" | sed 's/Unseal Key 1: //')
ROOT_KEY=$(cat ${TMP_FILE} | grep -E "Initial Root Token:" | sed 's/Initial Root Token: //')
vault operator unseal -tls-skip-verify ${UNSEAL_KEY}
echo '{ "UNSEAL_KEY" : "'${UNSEAL_KEY}'" , "ROOT_KEY" : "'${ROOT_KEY}'"}' > /tmp/spool_x_docker.log
rm -f ${TMP_FILE}

 # prendo la seal key / # cat simone.log | grep -E -o "^Unseal Key 1: (.*)$" | sed 's/Unseal Key 1: //'
 # prendo il root token # cat simone.log | grep -E -o "^Initial Root Token: (.*)$" | sed 's/Initial Root Token: //'