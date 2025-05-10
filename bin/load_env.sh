#!/bin/bash

# inserire nel bashrc dell'utente quanto segue
# export CLAH_HOME="/docker/clah"
#
# if [[ -f "${CLAH_HOME}/load_env.sh" ]]; then
#    source "${CLAH_HOME}/load_env.sh"
# fi

CLAH_TOOLS_PATH="${CLAH_BIN}/tools"
source ${CLAH_TOOLS_PATH}/autocomplete.sh

alias clah="${CLAH_BIN}/clah.sh $@"


