#!/bin/bash

networks_get()
{

    if [[ -z $1 ]] ; then
        printf "No env provided\n";
        exit;
    fi;


    exit;

    PREFIX_KEY="infrastructure/networks/$1"

    if ! is_valid_path ${PREFIX_KEY}/name ; then
        printf "La rete non esiste\n";
        exit;
    fi;

    name=$(get_value_service_config ${PREFIX_KEY}/name)
    cidr=$(get_value_service_config ${PREFIX_KEY}/subnet)
    driver=$(get_value_service_config ${PREFIX_KEY}/driver)
    gateway=$(get_value_service_config ${PREFIX_KEY}/gateway)
    jq -n --arg name $name --arg cidr $cidr --arg driver $driver --arg gateway $gateway \
        '{ 
            name: $name,
            cidr: $cidr,
            driver: $driver,
            gateway: $gateway
        }'
}


networks_set()
{

    if [[ -z $1 ]] ; then
        printf "No name provided\n";
        exit;
    fi;
    
    DRIVER_TYPE="bridge"
    DESCRIPTION=""
    PURPOSE="app"

    # subnet
    if ! jq -e 'any(.key == "-s")' <<< ${CLAH_PARSED_OPTIONS} >/dev/null; then
        printf "No subnet provided\n";
        exit;
    else
        SUBNET=$(jq -r '.[] | select(.key == "-s") | .value // empty' <<< ${CLAH_PARSED_OPTIONS})
    fi;

    # gateway
    if ! jq -e 'any(.key == "-g")' <<< ${CLAH_PARSED_OPTIONS} >/dev/null; then
        printf "No gateway provided\n";
        exit;
    else
        GATEWAY=$(jq -r '.[] | select(.key == "-g") | .value // empty' <<< ${CLAH_PARSED_OPTIONS})
    fi;

    # driver type
    if jq -e 'any(.key == "-t")' <<< ${CLAH_PARSED_OPTIONS} >/dev/null; then
        DRIVER_TYPE=$(jq -r '.[] | select(.key == "-t") | .value // empty' <<< ${CLAH_PARSED_OPTIONS})
    fi;

    # description
    if jq -e 'any(.key == "-d")' <<< ${CLAH_PARSED_OPTIONS} >/dev/null; then
        DESCRIPTION=$(jq -r '.[] | select(.key == "-d") | .value // empty' <<< ${CLAH_PARSED_OPTIONS})
    fi;

    # purpose
    if jq -e 'any(.key == "-p")' <<< ${CLAH_PARSED_OPTIONS} >/dev/null; then
        PURPOSE=$(jq -r '.[] | select(.key == "-p") | .value // empty' <<< ${CLAH_PARSED_OPTIONS})
    fi;

    case $PURPOSE in
        provider|app)
            PURPOSE=$PURPOSE
            ;;
        *)
            printf "Invalid purpose value. Allowed values are: provider, app\n";
            exit;
            ;;
    esac


    PREFIX_KEY="infrastructure/networks"
    if is_valid_path ${PREFIX_KEY}/app/name || is_valid_path ${PREFIX_KEY}/infrastructure/name ; then
        printf "Network '$1' already exists or already exists a network in '${PURPOSE}' purpose\n";
        exit;
    fi;

    set_value_service_config ${PREFIX_KEY}/${PURPOSE}/name $1
    set_value_service_config ${PREFIX_KEY}/${PURPOSE}/subnet ${SUBNET}
    set_value_service_config ${PREFIX_KEY}/${PURPOSE}/driver ${DRIVER_TYPE}
    set_value_service_config ${PREFIX_KEY}/${PURPOSE}/gateway ${GATEWAY}
    set_value_service_config ${PREFIX_KEY}/${PURPOSE}/description ${DESCRIPTION}
 
}

networks_rm()
{
    NAME=$1
    ENV=$(get_use_env)
    if is_flag "-e" ; then
        ENV=$(get_flag_value "-e")
    fi;

    if ! env_already_have_app_network $ENV $NAME ; then
        printf "Environment '$ENV' does not have '$NAME' network\n";
        exit;
    fi;

    printf "WARNING: Network removal is not cascading\n\n";
    printf "You are about to remove the network '${NAME}'.\n";
    printf "Only the network metadata will be deleted.\n";
    printf "\n";
    printf "Resources that reference this network (services, app,\n";
    printf. "storage, Terraform state, or external integrations) will NOT be\n";
    printf "removed automatically and may become orphaned.\n\n";
    printf "Make sure to review and clean up any related resources manually\n";
    printf "to avoid inconsistencies in the infrastructure lifecycle.\n";

    confirm_or_exit "Are you sure to delete?"


    ENV_UUID=$(get_env_uuid_by_name $ENV)
    NETWORK_UUID=$(get_network_uuid_by_name $ENV $1)

#    printf "Env: $ENV\n";
#    printf "Env UUID: $ENV_UUID\n";
#    printf "Network: $1\n";
#    printf "Network UUID: $NETWORK_UUID\n";
#    exit;

    TYPE_NETWORK=$(get_value_service_config "networks/${ENV_UUID}/${NETWORK_UUID}/type")
    if [[ "$TYPE_NETWORK" == "provider" ]] ; then
        rm_path_service_config "indexes/networks/by-type/${ENV_UUID}/provider"
    else
        service_config_rm_from_array_json "indexes/networks/by-type/${ENV_UUID}/app" "${NETWORK_UUID}"
    fi;

    rm_path_service_config "networks/${ENV_UUID}/${NETWORK_UUID}"
    rm_path_service_config "indexes/networks/by-name/${ENV_UUID}/${NAME}"

    

}

networks_show()
{
    PREFIX_KEY="infrastructure/networks"
    printf "Show networks\n";
    curl ${CLAH_SC_ENDPOINT}/v1/kv/${PREFIX_KEY}?keys 2>/dev/null | jq -r 'map(split("/") | .[-2]) | unique | .[]'
}


#######
# 1. networks name
networks_get()
{
    ENV=$(get_use_env)
    if is_flag "-e" ; then
        ENV=$(get_flag_value "-e")
        if ! environment_exists_by_name $ENV ; then
            printf "Environment '$ENV' does not exists\n";
            exit;
        fi;
    fi;

    if [[ -z $1 ]] ; then
        printf "No network name provide\n";
        exit;
    fi;

    show_networks_by_name $ENV $1

}

networks_create()
{
    # 1 parameters => NAME

    if [[ -z $1 ]] ; then
        printf "No name provided\n";
        exit;
    fi;

    NETWORK_NAME=$1
    DESCRIPTION=""
    TYPE_NETWORK="app"



#    set -x
    
    ENV_TO_USE="$(get_use_env)"

    if is_flag "-e" ; then
        ENV_TO_USE="$(get_flag_value "-e")"
        if ! environment_exists_by_name $ENV_TO_USE ; then
            printf "Error: env '$ENV_TO_USE' does not exists\n";
            exit;
        fi;
    fi;

    if is_flag "-l" ; then
        DESCRIPTION="$(get_flag_value "-l")"
    fi;

    if is_flag "-t" ; then
        TYPE_NETWORK="$(get_flag_value "-t")"
        if ! [[ "$TYPE_NETWORK" =~ ^(app|provider)$ ]]; then
            echo "Errore: Valore '$TYPE_NETWORK' non consentito."
            exit 1
        fi
    fi

    UUID_ENV=$(get_env_uuid_by_name $ENV_TO_USE)    

    if [[ ${TYPE_NETWORK} == "provider" ]] ; then
        if env_already_has_provider ${UUID_ENV} ; then
            printf "Environment '${ENV_TO_USE}' already have provider network\n";
            exit;
        fi;
    fi;


    # check se rete esiste

    if env_already_have_app_network "${ENV_TO_USE}" "$1" ; then
        printf "Environment '${ENV_TO_USE}' already have app network named '$1'\n";
        exit;
    fi;

    # check rete esiste
    # check se è una provider, se già ne esiste una

    DOMAIN_NAME=""
    SUBNET=$(get_flag_value "-s")
    GATEWAY=$(get_flag_value "-g")
    UUID_v4=$(generate_uuid)
    CREATED_AT=$(generate_timestamp)



    #printf "Name: $1\n";
    #printf "Subnet: ${SUBNET}\n";
    #printf "Gateway: ${GATEWAY}\n";
    #printf "Description ${DESCRIPTION}\n";
    #printf "UUID network: ${UUID_v4}\n";
    #printf "UUID env: ${UUID_ENV}\n";
    #printf "Created at: ${CREATED_AT}\n";
    #printf "Type: ${TYPE_NETWORK}\n";
    #printf "Env name: ${ENV_TO_USE}\n";

    # come creare una network
    # inserisci la rete in networks/uuid-env/uuid-network/<properties>
    # inserisci la rete in indexes/networks/by-name/uuid-env/name uuid-network
    # inserisci la rete in indexes/networks/by-type/uuid-env/provider -> uuid
    # inserisci la rete in indexes/networks/by-type/uuid-env/app -> lista uuid

    set_value_service_config "networks/${UUID_ENV}/${UUID_v4}/name" "$1"
    set_value_service_config "networks/${UUID_ENV}/${UUID_v4}/subnet" "${SUBNET}";
    set_value_service_config "networks/${UUID_ENV}/${UUID_v4}/gateway" "${GATEWAY}";
    set_value_service_config "networks/${UUID_ENV}/${UUID_v4}/description" "${DESCRIPTION}";
    set_value_service_config "networks/${UUID_ENV}/${UUID_v4}/created_at" "${CREATED_AT}";
    set_value_service_config "networks/${UUID_ENV}/${UUID_v4}/type" "${TYPE_NETWORK}";

    # inserisci la rete in indexes/networks/by-name/uuid-env/name uuid-network
    set_value_service_config "indexes/networks/by-name/${UUID_ENV}/$1" "${UUID_v4}";

    # inserisci la rete in indexes/networks/by-type/uuid-env/provider -> uuid
    if [[ "${TYPE_NETWORK}" == "provider" ]] ; then
        set_value_service_config "indexes/networks/by-type/${UUID_ENV}/provider" "${UUID_v4}";      
    else 
        LIST_APP_NETWORK=$(get_value_service_config "indexes/networks/by-type/${UUID_ENV}/app")
        if [[ "$LIST_APP_NETWORK" == "" ]] ; then
            LIST_APP_NETWORK="[]"
        fi;
        NEW_ARRAY=$(add_in_array_json "${UUID_v4}" "${LIST_APP_NETWORK}")
        set_value_service_config "indexes/networks/by-type/${UUID_ENV}/app" "${NEW_ARRAY}";
    fi;

    #remove_from_array_json "simone" "[ \"simone\", \"valentina\"]"
    #add_in_array_json "simone" "[ \"simone\", \"valentina\"]"

}

# jq 'del(.[] | select(. == "b"))' file.json
# jq '. += ["d"]' file.json


networks_ls()
{
    ENV=$(get_use_env)
    if is_flag "-e" ; then
        ENV=$(get_flag_value "-e")
    fi;

    ENV_UUID=$(get_env_uuid_by_name ${ENV})

    PROVIDER_NETWORK_UUID=$(get_value_service_config "indexes/networks/by-type/${ENV_UUID}/provider")

    if is_valid_path "networks/${ENV_UUID}/${PROVIDER_NETWORK_UUID}/name" ; then
        printf "Environment ${ENV} - ${ENV_UUID}\n\n";
        printf "Provider network\n";
        printf "──────────────────────────────────────────────────────\n"

        PREFIX_PATH="networks/${ENV_UUID}/${PROVIDER_NETWORK_UUID}"
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
    else
        printf "No provider network exist for '$ENV' environment\n";
    fi;


    if is_valid_path "indexes/networks/by-type/${ENV_UUID}/app" ; then
        LIST_APP_NETWORK=$(get_value_service_config indexes/networks/by-type/${ENV_UUID}/app)
        printf "\nApp network(s)\n";
        printf "──────────────────────────────────────────────────────\n"
        jq -r '.[]' <<< "${LIST_APP_NETWORK}" | while read -r UUID_APP; do
            PREFIX_PATH="networks/${ENV_UUID}/${UUID_APP}"
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
            printf "──────────────────────────────────────────────────────\n"      
        done
    else
        pritnf "No app network(s) exists for '$ENV' environment\n";
    fi;

}