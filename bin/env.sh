#!/bin/bash

export CONSUL_HTTP_ADDR=${CONSUL_HTTP_ADDR:=localhost:16080}
export CONSUL_HTTP_SSL=${CONSUL_HTTP_SSL:=false}

create_env()
{

    if [[ -z $1 ]] ; then
        printf "Missing environment name\n";
        clah_usage_subcommand env create
        exit;
    fi;

    NAME=$1

    if environment_exists_by_name "${NAME}" ; then
        printf "Environment ${NAME} already exists!\n";
        exit;
    fi;

    DESCRIPTION=""
    if is_flag "-d" ; then
        DESCRIPTION=$(get_flag_value "-d")
    fi;

    CREATED_AT=$(generate_timestamp)
    UUID_V4=$(generate_uuid)

    PREFIX_KEY_ENV="environments/data/${UUID_V4}"

    JSON_LIST_NAME=$(get_value_service_config "environments/list-by-name")
    JSON_LIST_UUID=$(get_value_service_config "environments/list-by-uuid")

    NEW_JSON_LIST_NAME=$(echo ${JSON_LIST_NAME} | jq '. // {}' | jq --arg name "$NAME" --arg uuid "$UUID_V4" '. + {($name): {name: $name, uuid: $uuid}}')
    NEW_JSON_LIST_UUID=$(echo ${JSON_LIST_UUID} | jq '. // {}' | jq --arg name "$NAME" --arg uuid "$UUID_V4" '. + {($uuid): {name: $name, uuid: $uuid}}')
    set_value_service_config ${PREFIX_KEY_ENV}/name ${NAME};
    set_value_service_config ${PREFIX_KEY_ENV}/uuid ${UUID_V4};
    set_value_service_config ${PREFIX_KEY_ENV}/created_at "${CREATED_AT}";
    set_value_service_config ${PREFIX_KEY_ENV}/description "${DESCRIPTION}";
    set_value_service_config "environments/list-by-name" "${NEW_JSON_LIST_NAME}"
    set_value_service_config "environments/list-by-uuid" "${NEW_JSON_LIST_UUID}"
    

    printf "Environment: ${NAME}\n";
    printf "────────────────────────────────────────\n";
    printf "ID\t\t: ${UUID_V4}\n";
    printf "Created at\t: ${CREATED_AT}\n";
    printf "Description:\t: ${DESCRIPTION}\n";
    # set as default ?
}



show_env()
{
    if [[ -z $1 ]] || is_flag "-a" ; then
        for e in $(get_list_env_by_uuid) ; do
            show_single_env_by_uuid $e;
        done;
        exit;
    fi;

    show_single_env_by_name $1;
}


show_single_env_by_uuid()
{
    if [[ -z $1 ]] ; then
        exit;
    fi;
    ENV_UUID=$1
    printf "\n";
    printf "Environment: $(get_value_service_config "environments/data/$ENV_UUID/name")\n";
    printf "────────────────────────────────────────\n";
    printf "ID\t\t: $(get_value_service_config "environments/data/$ENV_UUID/uuid")\n";
    printf "Created at\t: $(get_value_service_config "environments/data/$ENV_UUID/created_at")\n";
    printf "Description:\t: $(get_value_service_config "environments/data/$ENV_UUID/description")\n";
    printf "\n";
}

show_single_env_by_name()
{
    ENV_UUID=$(get_env_uuid_by_name $1)
    show_single_env_by_uuid $ENV_UUID;
}

remove_env()
{
    if [[ -z $1 ]] ; then
        printf "No env name provided\n";
        exit;
    fi;

    if ! environment_exists_by_name $1 ; then
        printf "Environment $1 doesn't exists\n";
        exit;
    fi;

    NAME=$1
    UUID=$(get_env_uuid_by_name ${NAME})

    if ! is_flag "-f" ; then
        printf "WARNING: Environment removal is not cascading\n\n";
        printf "You are about to remove the environment '${NAME}'.\n";
        printf "Only the environment metadata will be deleted.\n";
        printf "\n";
        printf "Resources that reference this environment (services, networks,\n";
        printf. "storage, Terraform state, or external integrations) will NOT be\n";
        printf "removed automatically and may become orphaned.\n\n";
        printf "Make sure to review and clean up any related resources manually\n";
        printf "to avoid inconsistencies in the infrastructure lifecycle.\n";

        confirm_or_exit "Are you sure to delete?"
    fi;

    LIST_JSON_NAME=$(get_value_service_config "environments/list-by-name")
    LIST_JSON_UUID=$(get_value_service_config "environments/list-by-uuid")

    NEW_LIST_JSON_NAME=$(jq -r --arg name "${NAME}" 'del(.[$name])' <<< ${LIST_JSON_NAME})
    NEW_LIST_JSON_UUID=$(jq -r --arg uuid "${UUID}" 'del(.[$uuid])' <<< ${LIST_JSON_UUID})


    rm_path_service_config "environments/data/${UUID}"
    set_value_service_config "environments/list-by-name" "${NEW_LIST_JSON_NAME}";
    set_value_service_config "environments/list-by-uuid" "${NEW_LIST_JSON_UUID}";

}


edit_env()
{
    NEWNAME=""
    DESCRIPTION=""
    EDITED=false

    if [[ -z $1 ]] ; then
        printf "No env provided\n";
        exit;
    fi;

    if ! environment_exists_by_name "$1" ; then
        printf "Environment '$1' does not exists\n";
        exit;
    fi;


    if is_flag "-n" ; then
        if environment_exists_by_name $(get_flag_value "-n") ; then
            printf "Environment '$(get_flag_value "-n")' already exists!\n";
            exit;
        fi;
        NEWNAME=$(get_flag_value "-n")
    fi;

    if [[ ! -z $NEWNAME ]] ; then
        EDITED=true
        NAME=$1
        UUID=$(get_env_uuid_by_name "${NAME}")

        LIST_JSON_NAME=$(get_value_service_config "environments/list-by-name")
        LIST_JSON_UUID=$(get_value_service_config "environments/list-by-uuid")

        NEW_LIST_JSON_NAME=$(jq -r --arg name "${NAME}" --arg newname "${NEWNAME}" '. + {($newname): .[$name]} | .[$newname].name = ($newname) | del(.[$name])' <<< ${LIST_JSON_NAME})
        NEW_LIST_JSON_UUID=$(jq -r --arg uuid "${UUID}" --arg newname "${NEWNAME}" '.[$uuid].name = ($newname)' <<< ${LIST_JSON_UUID})

        set_value_service_config "environments/list-by-name" "${NEW_LIST_JSON_NAME}";
        set_value_service_config "environments/list-by-uuid" "${NEW_LIST_JSON_UUID}";
        set_value_service_config "environments/data/${UUID}/name" "${NEWNAME}"
    fi;

    if is_flag "-d" ; then
        set_value_service_config "environments/data/${UUID}/description" "$(get_flag_value "-d")"
        EDITED=true
    fi;

    if [[ "${EDITED}" == "false" ]] ; then
        printf "No information edited\n";
        exit;
    fi;

}

use_env()
{
    if [[ -z $1 ]] ; then
        printf "No environment provided\n";
        exit;
    fi;

    if ! environment_exists_by_name $1 ; then
        printf "Environment name does not exists\n";
        exit;
    fi;

    ENVNAME=$1
    ENVUUID=$(get_env_uuid_by_name $1)

    yq -i ".env = \"${ENVNAME}\" | .uuid = \"${ENVUUID}\"" ${CLAH_ENV_FILE}
    
}



################

# get local env in use






#jq '. + {stage: .uat} | del(.uat)' file.json
#jq 'del(.uat)' file.json
