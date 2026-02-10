#!/bin/bash

apps_get_flag_value()
{
    local short_flag="$1"
    local long_flag="$2"

    if is_flag "${short_flag}" ; then
        get_flag_value "${short_flag}"
        return
    fi

    if is_flag "${long_flag}" ; then
        get_flag_value "${long_flag}"
        return
    fi

    echo ""
}

apps_resolve_env_or_exit()
{
    local env_name
    env_name="$(get_use_env)"

    local explicit_env
    explicit_env="$(apps_get_flag_value "-e" "--env")"
    if [[ -n "${explicit_env}" ]] ; then
        env_name="${explicit_env}"
    fi

    if [[ -z "${env_name}" ]] ; then
        printf "Environment non specificato. Usa -e/--env oppure configura un environment di default con 'clah env use'.\n"
        exit 1
    fi

    if ! environment_exists_by_name "${env_name}" ; then
        printf "Environment '%s' non esiste.\n" "${env_name}"
        exit 1
    fi

    echo "${env_name}"
}

apps_kv_recurse()
{
    local key_path="$1"
    curl -s "${CLAH_SC_ENDPOINT}/v1/kv/${key_path}?recurse"
}

apps_list()
{
    local env_name env_uuid raw
    env_name="$(apps_resolve_env_or_exit)"
    env_uuid="$(get_env_uuid_by_name "${env_name}")"

    raw="$(apps_kv_recurse "indexes/applications/by-apps/${env_uuid}/apps")"

    if [[ "$(jq -r 'type' <<< "${raw}" 2>/dev/null)" != "array" ]] ; then
        printf "Nessuna applicazione trovata per environment '%s'.\n" "${env_name}"
        exit 0
    fi

    printf "Environment: %s (%s)\n" "${env_name}" "${env_uuid}"
    printf "Applicazioni:\n"
    jq -r '
        map(select(.Key | test("/apps/[^/]+$")))
        | map({
            app_name: (.Key | split("/") | last),
            app_uuid: ((.Value | @base64d | fromjson | to_entries[0].value["app-uuid"]) // "")
          })
        | sort_by(.app_name)
        | .[]
        | "- \(.app_name)\t\(.app_uuid)"
    ' <<< "${raw}"
}

apps_show()
{
    local app_name env_name env_uuid app_data app_uuid container_name container_uuid

    app_name="$1"
    if [[ -z "${app_name}" ]] ; then
        printf "Missing APPNAME. Uso: clah apps show APPNAME [OPTIONS]\n"
        exit 1
    fi

    env_name="$(apps_resolve_env_or_exit)"
    env_uuid="$(get_env_uuid_by_name "${env_name}")"

    app_data="$(get_value_service_config "indexes/applications/by-apps/${env_uuid}/apps/${app_name}")"
    if [[ -z "${app_data}" ]] ; then
        printf "Applicazione '%s' non trovata nell'environment '%s'.\n" "${app_name}" "${env_name}"
        exit 1
    fi

    app_uuid="$(jq -r 'to_entries[0].value["app-uuid"] // empty' <<< "${app_data}")"

    printf "Environment: %s (%s)\n" "${env_name}" "${env_uuid}"
    printf "Application: %s (%s)\n" "${app_name}" "${app_uuid}"
    printf "Containers:\n"
    jq -r 'to_entries[] | "- \(.key)\t\(.value.uuid)"' <<< "${app_data}"

    container_name="$(apps_get_flag_value "-c" "--container")"
    if [[ -z "${container_name}" ]] ; then
        return
    fi

    if ! jq -e --arg cname "${container_name}" '.[$cname]' <<< "${app_data}" >/dev/null ; then
        printf "Container '%s' non trovato nell'applicazione '%s'.\n" "${container_name}" "${app_name}"
        exit 1
    fi

    container_uuid="$(jq -r --arg cname "${container_name}" '.[$cname].uuid' <<< "${app_data}")"

    local container_root details name image
    container_root="applications/${env_uuid}/${app_uuid}/${container_uuid}"
    details="$(apps_kv_recurse "${container_root}")"

    name="$(get_value_service_config "${container_root}/name")"
    image="$(get_value_service_config "${container_root}/image")"

    printf "\nContainer details:\n"
    printf "Environment: %s (%s)\n" "${env_name}" "${env_uuid}"
    printf "Application: %s (%s)\n" "${app_name}" "${app_uuid}"
    printf "Container: %s (%s)\n" "${name}" "${container_uuid}"
    printf "Images: %s\n" "${image}"

    printf "Volumes:\n"
    jq -r 'map(select(.Key | test("/volumes/"))) | if length == 0 then "- none" else .[] | "- \(.Key | split("/") | last): \(.Value | @base64d)" end' <<< "${details}"

    printf "Ports:\n"
    jq -r '
        map(select(.Key | test("/networks/.*/port-map$")))
        | if length == 0 then "- none" else
            map((.Value | @base64d | fromjson))
            | flatten
            | unique_by(.container, .host, .protocol)
            | .[]
            | "- container=\(.container) host=\(.host) protocol=\(.protocol)"
          end
    ' <<< "${details}"

    printf "Devices:\n"
    jq -r 'map(select(.Key | test("/devices/"))) | if length == 0 then "- none" else .[] | "- \(.Key | split("/") | last): \(.Value | @base64d)" end' <<< "${details}"

    printf "Networks:\n"
    jq -r '
        [
          .[]
          | select(.Key | test("/networks/.*/ip$") or test("/networks/.*/port-map$"))
          | {
              network_uuid: (.Key | split("/") | .[-2]),
              field: (if (.Key | endswith("/ip")) then "ip" else "port-map" end),
              value: (.Value | @base64d)
            }
        ]
        | group_by(.network_uuid)
        | if length == 0 then "- none" else
            .[]
            | "- " + .[0].network_uuid
            + " ip=" + ((map(select(.field == "ip") | .value) | first) // "")
            + " portmap=" + ((map(select(.field == "port-map") | .value) | first) // "[]")
          end
    ' <<< "${details}"
}
