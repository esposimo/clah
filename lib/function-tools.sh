#!/bin/bash

######### INDEX: general function

clah_usage()
{
    printf "Usage: clah COMMAND [help | -h | --help] [SUBCOMMAND] [OPTIONS]\n\n"
    printf "Cloud at Home - Manage your local cloud infrastructure components\n\n"
    printf "Available Commands\n";
    cat ${CLAH_MERGED_COMMAND_FILE} | jq -r 'to_entries | map(select(.value.type == "builtin")) | sort_by(.key) | .[] | select(.value.description != null) | "   \(.key)\(" " * (15 - (.key|length)))\(.value.description)"'
    printf "External Commands\n";
    cat ${CLAH_MERGED_COMMAND_FILE} | jq -r 'to_entries | map(select(.value.type == "extension")) | sort_by(.key) | .[] | select(.value.description != null) | "   \(.key)\(" " * (15 - (.key|length)))\(.value.description)"'
    printf "Global Options\n";
    printf "   -h, --help     Use for help of subcommand\n\t\t  e.g.  clah config --help\n\t\t\tclah config --help ls\n\t\t\tclah networks help set\n";
}

clah_usage_command()
{
    if [[ -z $1 ]] ; then
        clah_usage;
        exit;
    fi;
    if ! jq -e --arg cmd "$1" '.[$cmd] | type == "object"' ${CLAH_MERGED_COMMAND_FILE} >/dev/null ; then
        printf "Command $1 not found\n";
        clah_usage;
        exit;
    fi;
    printf "Usage:\n clah $1 $(get_usage_command $1)\n\n";
    printf "Cloud at Home - Manage your local cloud infrastructure components\n\n"
    printf "Available commands\n";
    cat ${CLAH_MERGED_COMMAND_FILE} | jq -r --arg cmd "$1" '.[$cmd].subcommands // [] | to_entries | sort_by(.key) | .[] | select(.value.description != null) | "   \(.key)\(" " * (15 - (.key|length)))\(.value.description)"'
    printf "\n";
    if jq -e --arg cmd "$1" '.[$cmd].flags' ${CLAH_MERGED_COMMAND_FILE} >/dev/null; then
        printf "Global Options\n";
        cat ${CLAH_MERGED_COMMAND_FILE} | jq -r --arg cmd "$1" '.[$cmd].flags | .[] |  "   -\(.short), --\(.long)\(" " * ((15 - (.long|length))))\(.description // "No description found")"'
    fi;
 
}

clah_usage_subcommand()
{
    if [[ -z $1 ]] ; then
        clah_usage;
        exit;
    fi;
    if ! jq -e --arg cmd "$1" '.[$cmd] | type == "object"' ${CLAH_MERGED_COMMAND_FILE} >/dev/null ; then
        printf "Command $1 not found\n";
        clah_usage;
        exit;
    fi;
    if ! jq -e --arg cmd "$1" --arg sub "$2" '.[$cmd].subcommands[$sub] | type == "object"' ${CLAH_MERGED_COMMAND_FILE} >/dev/null ; then
        printf "Subcommand $2 not found\n";
        clah_usage_command $1;
        exit;
    fi;

    printf "Usage:\n clah $1 $2 $(get_usage_subcommand $1 $2)\n\n"
    jq -r --arg cmd "$1" --arg sub "$2" '.[$cmd].subcommands[$sub].description' ${CLAH_MERGED_COMMAND_FILE};
    if [[ $(jq -e --arg cmd "$1" --arg sub "$2" '.[$cmd].subcommands[$sub].flags | length' ${CLAH_MERGED_COMMAND_FILE} 2>/dev/null) -gt 0 ]] ; then
        printf "\nOptions\n";
        cat ${CLAH_MERGED_COMMAND_FILE} | jq -r --arg cmd "$1" --arg sub "$2" '.[$cmd].subcommands[$sub].flags[] | "   -\(.short), --\(.long)\(" " * (20 - (.long|length)))\(.description)"'
    fi;
}

get_usage_command()
{
    COMMAND=$1
    if jq -e --arg cmd "${COMMAND}" '.[$cmd].usage' ${CLAH_MERGED_COMMAND_FILE} >/dev/null ; then
        echo $(jq -r --arg cmd "${COMMAND}" '.[$cmd].usage' ${CLAH_MERGED_COMMAND_FILE})
    fi;
}

get_usage_subcommand()
{
    COMMAND=$1
    SUB_COMMAND=$2
    if jq -e --arg cmd "${COMMAND}" --arg scmd "${SUB_COMMAND}" '.[$cmd].subcommands[$scmd].usage' ${CLAH_MERGED_COMMAND_FILE} >/dev/null ; then
        echo $(jq -r --arg cmd "${COMMAND}" --arg scmd "${SUB_COMMAND}" '.[$cmd].subcommands[$scmd].usage' ${CLAH_MERGED_COMMAND_FILE})
    fi;
}

merge_json_command()
{
    FILENAME=$1
    BUILTIN_JSON=$(jq 'with_entries(.value.type = "builtin")' ${CLAH_COMMANDS_FILE})
    EXTENSION_JSON=$(jq 'with_entries(.value.type = "extension")' ${CLAH_COMMANDS_EXTERNAL_FILE})
    echo ${BUILTIN_JSON} ${EXTENSION_JSON} | jq -s '.[1] * .[0]' > ${CLAH_MERGED_COMMAND_FILE};
}

# verifica se un path su service config esiste
is_valid_path()
{
  KEY_NAME=$1
  HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" ${CLAH_SC_ENDPOINT}/v1/kv/${KEY_NAME})
  if [[ ${HTTP_CODE} -eq 200 ]] ; then
    return 0;
  fi;
  return 1;
}

parse_endpoint() {
    local url="$1"

    # default
    local scheme host port

    # aggiungo scheme fittizio se manca
    [[ "$url" != *"://"* ]] && url="dummy://$url"

    scheme=$(echo "$url" | sed -E 's|^([a-zA-Z]+)://.*|\1|')
    host=$(echo "$url"   | sed -E 's|^[a-zA-Z]+://([^:/]+).*|\1|')
    port=$(echo "$url"   | sed -nE 's|^[a-zA-Z]+://[^:/]+:([0-9]+).*|\1|p')

    # porta di default
    if [[ -z "$port" ]]; then
        case "$scheme" in
            https) port=443 ;;
            http|dummy) port=80 ;;
        esac
    fi

    jq -n --arg scheme "$scheme" --arg host "$host" --arg port "$port" \
        '{scheme: $scheme, host: $host, port: ($port|tonumber)}'
}



is_command()
{
    COMMAND_NAME=$1
    if jq -e --arg cmd "${COMMAND_NAME}" '.[$cmd]' ${CLAH_MERGED_COMMAND_FILE} > /dev/null; then
        return 0;
    fi;
    return 1;
}

is_subcommand()
{
    if [[ -z $2 ]] ; then
        return 1;
    fi;
    COMMAND_NAME=$1
    SUB_COMMAND=$2
    if jq -e --arg cmd "${COMMAND_NAME}" --arg scmd "${SUB_COMMAND}" '.[$cmd].subcommands[$scmd]' ${CLAH_MERGED_COMMAND_FILE} > /dev/null; then
        return 0;
    fi;
    return 1;
}

has_source_command()
{
    COMMAND_NAME=$1
    if jq -e --arg cmd "${COMMAND_NAME}" '.[$cmd].source' ${CLAH_MERGED_COMMAND_FILE} > /dev/null; then
        return 0;
    fi;
    return 1;
}

exists_source_command()
{
    COMMAND_NAME=$1
    SOURCE_FILE=$(cat ${CLAH_MERGED_COMMAND_FILE} | jq -r --arg cmd "${COMMAND_NAME}" '.[$cmd].source')
    if [[ -f "${CLAH_ROOT}/${SOURCE_FILE}" ]] ; then
        return 0;
    fi;
    return 1;
}

retrieve_function_main()
{
    COMMAND=$1
    jq -r --arg cmd "${COMMAND}" '.[$cmd].main' ${CLAH_MERGED_COMMAND_FILE};
}

retrieve_function_subcommand()
{
    COMMAND=$1
    SUBCOMMAND=$2
    jq -r --arg cmd "${COMMAND}" --arg scmd "${SUB_COMMAND}" '.[$cmd].subcommands[$scmd].function' ${CLAH_MERGED_COMMAND_FILE};
}

retrieve_command_type()
{
    RETRIEVE="NO_MAIN_NO_SUBCOMMANDS"
    if jq -e --arg cmd "$1" '.[$cmd].main' ${CLAH_MERGED_COMMAND_FILE} > /dev/null ; then
        RETRIEVE="ONLY_MAIN";
        if jq -e --arg cmd "$1" '.[$cmd].subcommands | length > 0' ${CLAH_MERGED_COMMAND_FILE} > /dev/null ; then
            RETRIEVE="MAIN_AND_SUBCOMMANDS";
        fi;
    else
        if jq -e --arg cmd "$1" '.[$cmd].subcommands | length > 0' ${CLAH_MERGED_COMMAND_FILE} > /dev/null ; then
            RETRIEVE="ONLY_SUBCOMMANDS";
        fi;
    fi;
    echo $RETRIEVE;
}

make_positional_json()
{
    POSITIONAL_JSON=()
    while [[ $# -gt 0 ]]; do
        POSITIONAL_JSON+=(
            "$(jq -cn --arg v "$1" '{key:"positional",value:$v}')"
        )
        shift
        if [[ "$1" == "--" && $# -eq 1 ]] ; then
            shift;
        fi;    
    done
    echo "${POSITIONAL_JSON[@]}";
}

make_inline_json()
{
    INLINE_ARGS=()
    while [[ $# -gt 0 ]]; do
        INLINE_ARGS+=("$(jq -cn --arg v "$1" '$v')")
        shift
        if [[ "$1" == "--" && $# -eq 1 ]] ; then
            shift;
        fi;
    done
    echo "${INLINE_ARGS[@]}";
}

make_options_json()
{
    SHORT_OPTIONS=$1
    LONG_OPTIONS=$2
    shift 2
    PARSED=$(getopt -o "$SHORT_OPTIONS" -l "$LONG_OPTIONS" -n "$PARAMS" -- "$@" 2>/dev/null)
    if [[ ! $? -eq 0 ]] ; then
        echo "Parametri non validi";
        exit;
    fi;
    eval set -- "${PARSED}";
    OPTIONS_JSON=()
    while [[ $# -gt 0 ]]; do
        if [[ "$1" == "--" ]]; then
            break
        fi
        key="$1"
        shift
        if [[ $# -gt 0 && ! "$1" =~ ^- ]]; then
            value="$1"
            shift
        else
            value=true
        fi
        OPTIONS_JSON+=(
            "$(jq -cn --arg k "$key" --arg v "$value" \
            '{ key: $k, value: (if $v == "true" then true else $v end) }')"
    )
    done
    shift 1;

    INLINE=($(make_inline_json "$@"))
    POSITIONAL=($(make_positional_json "$@"))
    FINAL_JSON=$(jq -n \
        --argjson options "$(echo "${OPTIONS_JSON[*]}" | jq -s '.')" \
        --argjson positional "$(echo "${POSITIONAL[*]}" | jq -s '.')" \
        --argjson inline "$(echo "${INLINE[*]}" | jq -s '.')" \
        '{
            options: $options,
            positional: $positional,
            inline_arguments: $inline
        }')
    echo ${FINAL_JSON};
}

retrieve_main_options()
{
    COMMAND=$1
    DEFAULT_VALUE="[]";
    jq -r --arg cmd "${COMMAND}" '.[$cmd].flags // []' ${CLAH_MERGED_COMMAND_FILE};
}

retrieve_subcommands_options()
{
    COMMAND=$1
    SUB_COMMAND=$2
    DEFAULT_VALUE="[]"
    jq -r --arg cmd "${COMMAND}" --arg scmd "${SUB_COMMAND}" '.[$cmd].subcommands[$scmd].flags // []' ${CLAH_MERGED_COMMAND_FILE};
}

merge_options()
{
    local -n parts=$1

    FLAG_MAIN=$(retrieve_main_options $2)
    FLAG_SUB=$(retrieve_subcommands_options $2 $3)

    LIST_OPTIONS=$(echo ${FLAG_MAIN} ${FLAG_SUB} | jq -s 'reduce .[][] as $item ({}; .[$item.short] = $item) | .[]')

    SHORT_OPTIONS=$(echo ${LIST_OPTIONS} | jq -s -r ' . |  map(if .arg_mandatory=="true" then .short + ":" else .short end) | join(",")')
    LONG_OPTIONS=$(echo ${LIST_OPTIONS} | jq -s -r ' . | map(if .arg_mandatory=="true" then .long + ":" else .long end) | join(",")')
    parts+=(${SHORT_OPTIONS})
    parts+=(${LONG_OPTIONS});
}

# check se un opzione è presente nel prompt
is_flag()
{
    FLAG=$1
    if jq -e --arg flag "${FLAG}" 'any(.key == $flag)' <<< ${CLAH_PARSED_OPTIONS} >/dev/null; then
        return 0;
    else
        return 1;
    fi;
}

get_flag_value()
{
    FLAG=$1
    echo $(jq -r --arg flag "${FLAG}" '.[] | select(.key == $flag) | .value // empty' <<< ${CLAH_PARSED_OPTIONS})
}


generate_uuid() {
  if command -v uuidgen >/dev/null 2>&1; then
    uuidgen | tr '[:upper:]' '[:lower:]'
  else
    # fallback RFC 4122 v4
    printf '%s%s-%s-%s-%s-%s%s%s\n' \
      "$(openssl rand -hex 4)" \
      "$(openssl rand -hex 2)" \
      "$(openssl rand -hex 2)" \
      "$(printf '%x' $(( (RANDOM % 4) + 8 )) )$(openssl rand -hex 1)" \
      "$(openssl rand -hex 2)" \
      "$(openssl rand -hex 6)"
  fi
}

generate_timestamp() {
  if date +%N >/dev/null 2>&1 && [[ "$(date +%N)" != "N" ]]; then
    # GNU date (micro/nano)
    date +"%Y-%m-%d %H:%M:%S.%6N"
  else
    # fallback: millisecondi
    printf "%s.%03d\n" \
      "$(date +"%Y-%m-%d %H:%M:%S")" \
      "$((RANDOM % 1000))"
  fi
}

is_valid_uuid_v4() {
  local uuid="$1"
  [[ "$uuid" =~ ^[a-f0-9]{8}-[a-f0-9]{4}-4[a-f0-9]{3}-[89ab][a-f0-9]{3}-[a-f0-9]{12}$ ]]
}

confirm_or_exit() {
  local prompt="$@"

  read -r -p "$prompt [y/N]: " response
  case "$response" in
    [yY]) return 0 ;;
    *) 
      echo "aborted."
      exit 1
      ;;
  esac
}

remove_from_array_json()
{
    VALUE="$1"
    JSON="$2"
    NEW_ARRAY=$(jq -r --arg value "$VALUE" 'del(.[] | select(. == $value))' <<< $JSON)
    echo "$NEW_ARRAY";
}
add_in_array_json()
{
    VALUE="$1"
    JSON="$2"
    NEW_JSON=$JSON
    if jq -e --arg v "$VALUE" 'index($v) == null' <<< $JSON >/dev/null ; then
        NEW_JSON=$(jq -r --arg v "$VALUE" '. += [$v]' <<< $JSON)
    fi;
    echo "$NEW_JSON";
}


######### INDEX: service config function

# get value for a path
get_value_service_config()
{
    KEY_NAME=$1
    RETURN_VALUE=$(curl -s -w "\n%{http_code}" "${CLAH_SC_ENDPOINT}/v1/kv/${KEY_NAME}")
    BODY=$(printf "%s" "$RETURN_VALUE" | sed '$d')
    CODE=$(printf "%s" "$RETURN_VALUE" | tail -n1)
    if [[ "$CODE" == "404" ]] ; then
        printf "";
    else
        printf "${BODY}" | jq -r '.[0].Value // ""' | base64 --decode
    fi;
}

# configure a path in service config
set_value_service_config()
{
    KEY_NAME=$1
    KEY_VALUE=$2
    curl -s -X PUT ${CLAH_SC_ENDPOINT}/v1/kv/${KEY_NAME} -d "${KEY_VALUE}" >/dev/null;
}

# rm path in a service config
rm_path_service_config()
{
    KEY_NAME=$1
    curl -s -X DELETE ${CLAH_SC_ENDPOINT}/v1/kv/${KEY_NAME}?recurse >/dev/null;
}

rename_path_service_config()
{
    KEY_NAME=$1
    NEW_NAME=$2
    SAVE_VALUE=$(get_value_service_config "${KEY_NAME}")
    curl -s -X DELETE ${CLAH_SC_ENDPOINT}/v1/kv/${KEY_NAME} >/dev/null;
    curl -s -X PUT ${CLAH_SC_ENDPOINT}/v1/kv/${NEW_NAME} -d "${SAVE_VALUE}" >/dev/null;
}

service_config_add_in_array_json()
{
    SC_PATH=$1
    NEW_VALUE=$2
    if is_valid_path $SC_PATH ; then
        NEW_VALUE=$(add_in_array_json "${NEW_VALUE}" "$(get_value_service_config "${SC_PATH}")")
        set_value_service_config "${SC_PATH}" "${NEW_VALUE}"
    fi;
}
# path
# new value
service_config_rm_from_array_json()
{
    SC_PATH=$1
    RM_VALUE=$2
    if is_valid_path $SC_PATH ; then
        NEW_VALUE=$(remove_from_array_json "${RM_VALUE}" "$(get_value_service_config "${SC_PATH}")")
        set_value_service_config "${SC_PATH}" "${NEW_VALUE}"
    fi;
}



######### INDEX: environment function

# restituisce true/false se un uuid di ambiente esiste
environment_exists_by_uuid()
{
    UUID_V4=$1
    if is_valid_path "environment/data/${UUID_V4}" ; then
        return 0;
    fi;
    return 1;
}

# restituisce true/false se un env name esiste
environment_exists_by_name()
{
    NAME=$1
    if ! is_valid_path "environments/list-by-name" ; then
        printf "ERROR: NO ENVIRONMENT LIST FOUND\n";
        exit;
    fi;

    JSON_ENV=$(get_value_service_config "environments/list-by-name")
    if jq -e --arg name "${NAME}" '.[$name]' <<< ${JSON_ENV} >/dev/null ; then
        return 0;
    fi;
    return 1;
}

# restituisce un uuid di environment fornendo il nome
get_env_uuid_by_name()
{
    JSON_ENV=$(get_value_service_config "environments/list-by-name")
    if jq -e --arg name "$1" '.[$name]' <<< ${JSON_ENV} >/dev/null; then
        jq -r --arg name "$1" '.[$name].uuid' <<< ${JSON_ENV};
    fi;
}

# restituisce il name di un environment fornendo l'uuid
get_env_name_by_uuid()
{
    JSON_ENV=$(get_value_service_config "environments/list-by-uuid")
    if jq -e --arg uuid "$1" '.[$uuid]' <<< ${JSON_ENV} >/dev/null; then
        jq -r --arg uuid "$1" '.[$uuid].name' <<< ${JSON_ENV};
    fi;
}

get_use_env()
{
    RETURN_VALUE=""
    cat ${CLAH_ENV_FILE} | yq -e '.env' 2>/dev/null 1>&2
    if [[ $? -eq 0 ]] ; then
        RETURN_VALUE=$(cat ${CLAH_ENV_FILE} | yq -r '.env')
        echo ${RETURN_VALUE};
        exit;
    fi;
    echo ${RETURN_VALUE};
}

# get list map with name as root key
get_list_env_by_name()
{
    LIST_ENV=$(get_value_service_config environments/list-by-name)
    echo $(jq -r 'keys[]' <<< ${LIST_ENV});
}

# get list map with uuid as root key
get_list_env_by_uuid()
{
    LIST_ENV=$(get_value_service_config environments/list-by-uuid)
    echo $(jq -r 'keys[]' <<< ${LIST_ENV});
}


######### INDEX: networks function
# $1 UUID ENV
env_already_has_provider()
{
    if is_valid_path "indexes/networks/by-type/$1/provider" ; then
        return 0;
    fi;
    return 1;
}

# $1 env
# $2 network name
env_already_have_app_network()
{
    ENVIRONMENT=$1
    UUID_ENV=$(get_env_uuid_by_name "${ENVIRONMENT}")
    NETWORK_NAME=$2
    if is_valid_path "indexes/networks/by-name/${UUID_ENV}/${NETWORK_NAME}" ; then
        return 0;
    fi;
    return 1;
}
# $1 env name
# $2 network uuid
get_network_name_by_uuid()
{
    ENV_NAME=$1
    NETWORK_UUID=$2
    ENV_UUID=$(get_env_uuid_by_name $1)
    NETWORK_NAME=$(get_value_service_config "networks/${ENV_UUID}/${NETWORK_UUID}/name")
    echo "${NETWORK_NAME}"
}

get_network_uuid_by_name()
{
    ENV_NAME=$1
    NETWORK_NAME=$2
    ENV_UUID=$(get_env_uuid_by_name $1)
    NETWORK_UUID=$(get_value_service_config "indexes/networks/by-name/${ENV_UUID}/${NETWORK_NAME}")
    echo "${NETWORK_UUID}";
}


# env name
# networks name
show_networks_by_name()
{
    ENV=$1
    NETWORK=$2
    ENV_UUID=$(get_env_uuid_by_name $1)
    NETWORK_UUID=$(get_network_uuid_by_name $1 $2)

    printf "Environment ${ENV} - ${ENV_UUID}\n\n";
    printf "──────────────────────────────────────────────────────\n"

    PREFIX_PATH="networks/${ENV_UUID}/${NETWORK_UUID}"
    NAME=$(get_value_service_config "${PREFIX_PATH}/name")
    DESCRIPTION=$(get_value_service_config "${PREFIX_PATH}/description")
    TYPE=$(get_value_service_config "${PREFIX_PATH}/type")
    SUBNET=$(get_value_service_config "${PREFIX_PATH}/subnet")
    GATEWAY=$(get_value_service_config "${PREFIX_PATH}/gateway")
    CREATED_AT=$(get_value_service_config "${PREFIX_PATH}/created_at")
        
    printf "Name:\t\t ${NAME}\n";
    printf "Description:\t\t ${DESCRIPTION}\n";
    printf "Type:\t\t ${TYPE}\n";
    printf "Subnet:\t\t ${SUBNET}\n";
    printf "Gateway:\t ${GATEWAY}\n";
    printf "Created at:\t ${CREATED_AT}\n";
}
