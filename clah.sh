#!/bin/bash

# se il primo valore è help o -h o --help mostro l'help generale (fatto)
# se il primo valore è version o -v o --version mostro la versione (fatto)
#
# se il primo valore non esiste, mando l'help generale (fatto)
# se il primo valore esiste, controllo se esiste il comando
#   se non esiste, mando l'help generale + l'errore di comando non trovato
#   se esiste, controllo che tipo di comando è, ovvero
#     comando con subcomandi obbligatori
#     comando con subcomandi opzionali
#     comando senza subcomandi
#     comando con subcomandi opzionali e funzione main
#     in base a questo, procedo a fare il parsing dei parametri
# 
#.    le opzioni globali di un comando vengono sovrascritte dalle opzioni del subcomando, se uguali
#
#.    ogni comando, se ha un -h o --help o help come secondo parametro, mostra l'help del comando
#.    ogni sottocomand, se ha un -h o --help mostra l'help del sottocomando

# i primi due parametri sono sempre comando e sottocomando!

export CLAH_VERSION=0.1.0
export CLAH_ROOT=$(cd "$(dirname $0)" && pwd)
export CLAH_EXTENSION_ROOT="${CLAH_ROOT}/extensions"
export CLAH_CONFIG_PATH="${CLAH_ROOT}/.clah"
export CLAH_ENV_FILE="${CLAH_CONFIG_PATH}/env"

if [[ ! -d ${CLAH_CONFIG_PATH} ]] ; then
    mkdir -p ${CLAH_CONFIG_PATH};
fi;

if [[ ! -f ${CLAH_ENV_FILE} ]] ; then
    touch ${CLAH_ENV_FILE};
fi;

export CLAH_COMMANDS_FILE="${CLAH_ROOT}/command.json"
export CLAH_COMMANDS_EXTERNAL_FILE="${CLAH_EXTENSION_ROOT}/command_external.json"

export BUFFER_COMMAND_FILE=$(cat ${CLAH_ROOT}/command.json)
export BUFFER_COMMAND_EXTERNAL_FILE=$(cat ${CLAH_EXTENSION_ROOT}/command_external.json)

export CLAH_MERGED_COMMAND_FILE=$(mktemp)
trap 'rm -f "$CLAH_MERGED_COMMAND_FILE"' EXIT;

export DOCKER_HOST_IP=$(ip route get 8.8.8.8 | grep -oP 'src \K\S+')
export CLAH_SC_ENDPOINT="${CLAH_SC_ENDPOINT:=http://${DOCKER_HOST_IP}:16080}"

source "${CLAH_ROOT}/lib/function-tools.sh"
#jq -s '.[1] * .[0]' ${CLAH_COMMANDS_FILE} ${CLAH_COMMANDS_EXTERNAL_FILE} > ${CLAH_MERGED_COMMAND_FILE};
merge_json_command

if [[ -z $1 || $1 == "-h" || $1 == "--help" || $1 == "help" ]] ; then
    clah_usage;
    exit;
fi;

if [[ $1 == "-v" || $1 == "--version" || $1 == "version" ]] ; then
    echo "clah version ${CLAH_VERSION}";
    exit;
fi;

if ! is_command $1 ; then
    echo "Command '${1}' not found.";
    exit 1;
fi;

if ! has_source_command $1 ; then
    echo "Command '${1}' has no source file defined.";
    exit 1;
fi;

if ! exists_source_command $1 ; then
    echo "Source file for '$1' not found";
    exit 1;
fi;

COMMAND=$1
RETRIEVE_LOGIC=$(retrieve_command_type $1);

if [[ $2 == "help" || $2 == "-h" || $2 == "--help" ]] ; then
    if [[ -z $3 ]] ; then
        clah_usage_command $1;
    else
        clah_usage_subcommand $1 $3;
    fi;
    exit;
fi;


if [[ "${RETRIEVE_LOGIC}" == "NO_MAIN_NO_SUBCOMMANDS" ]] ; then
    echo "Command '${COMMAND}' requires no main function and no subcommands, nothing to do.";
fi;




declare -a array_options
merge_options array_options $1 $2;

SHORT_PARAMS="${array_options[0]}"
LONG_PARAMS="${array_options[1]}"


SOURCE_FILE=$(cat ${CLAH_MERGED_COMMAND_FILE} | jq -r --arg cmd "${COMMAND}" '.[$cmd].source')

################## MAIN_AND_SUBCOMMANDS ##################
if [[ "${RETRIEVE_LOGIC}" == "MAIN_AND_SUBCOMMANDS" ]] ; then
# check if $2 is subcommands is valid, else use $2 as parts of input for $1
    if is_subcommand "${COMMAND}" $2 ; then
        FUNCTION_CALL=$(retrieve_function_subcommand "${COMMAND}" $2)
        shift 2;
    else
        FUNCTION_CALL=$(retrieve_function_main "${COMMAND}")
        shift 1;
    fi;
    FINAL_JSON=$(make_options_json "${SHORT_PARAMS}" "${LONG_PARAMS}" "$@")

fi;

################## ONLY_SUBCOMMANDS ##################
if [[ "${RETRIEVE_LOGIC}" == "ONLY_SUBCOMMANDS" ]] ; then

    if [[ -z $2 ]] ; then
        clah_usage_command $1;
        exit;
    fi;

    if ! is_subcommand "${COMMAND}" $2; then
        printf "Subcommand $2 not exists for ${COMMAND}\n";
        exit;
    fi;


    FUNCTION_CALL=$(retrieve_function_subcommand "${COMMAND}" $2)
    shift 2;
#    make_options_json ${SHORT_PARAMS} ${LONG_PARAMS} "$@"
    FINAL_JSON=$(make_options_json "${SHORT_PARAMS}" "${LONG_PARAMS}" "$@")
    #echo "${FINAL_JSON}"; exit;

fi;



# clah test_only_subcommands_1 -> mostra help
# clah test_only_subcommands_1 test1 -> pronto a lanciare il subcommand  test1
# clah test_only_subcommands_1 test -> mostra errore di sottocomando non esistente
# clah test_only_subcommands_1 -t -> -t è un parametro del main, va in errore 
# clah test_only_subcommands_1 test1 -t ppp -> pronto a lanciare la function del subcomomand
#
# clah test_main_subcommands -> pronto a lanciare il main
# clah test_main_subcommands test -> test noon esiste, quindi lancia il main con parametro posizionale
# clah test_main_subcommands test1 -> pronto a lanciare test1
#
# 
# clah test_only_main_1 pippo -v -f file -> pronto a lanciare correttamente
# clah test_only_main_1 pippo -> pronto a lanciare correttamente
# clah test_only_main_1 -> pronto a lanciare correttamente
#

################## ONLY_MAIN ##################
if [[ "${RETRIEVE_LOGIC}" == "ONLY_MAIN" ]] ; then

    FUNCTION_CALL=$(retrieve_function_main "${COMMAND}")
    shift 1;
    FINAL_JSON=$(make_options_json "${SHORT_PARAMS}" "${LONG_PARAMS}" "$@")

fi;

#echo "Logic: ${RETRIEVE_LOGIC}";
#echo "Source: ${SOURCE_FILE}";
#echo "Func: ${FUNCTION_CALL}";
#echo "Params: $(echo ${FINAL_JSON} | jq)";
export FINAL_JSON;
export CLAH_PARSED_POSITIONAL_ARGUMENT=$(echo "${FINAL_JSON}" | jq -e '.positional')
export CLAH_PARSED_OPTIONS=$(echo "${FINAL_JSON}" | jq -e '.options')
mapfile -t CLAH_PARSED_INLINE_ARGUMENT < <(echo "${FINAL_JSON}" | jq -e '.inline_arguments | .[]'); 
eval set -- "${CLAH_PARSED_INLINE_ARGUMENT[@]}"
source ${CLAH_ROOT}/${SOURCE_FILE};
${FUNCTION_CALL} "$@";
