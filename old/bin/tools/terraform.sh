#!/bin/bash


source $CLAH_BIN/env

COMMAND=$1
shift 1
PARAMS=$@

# clah tf apply|destroy <working directory> -t TARGET

usage()
{
    printf "\nUsage: clah tf ACTION [-s subscription] [-w WORKING DIRECTORY] [-t TERRAFORM PROJECT] [-r RESOURCE]\n";
    printf "\n"
    printf "Manage service config\n\n";
    printf "Actions:\n";
    printf "  apply\t\tPerform a terraform apply\n";
    printf "  destroy\tPerform a terraform destroy\n";
    printf "  get\t\tGet terraform info for project\n";
    printf "\n";
    printf "Parameters:\n";
    printf "  -t, --target\t\t\tSpecifies multiple external Terraform projects\n";
    printf "  -w, --working-directory\tSpecifies working directory. Default: current directory\n";
    printf "  -s, --sub\tSpecifies subscription.\n";
}

usage_apply()
{
    printf "\n";
    printf "Usage: clah tf apply [-w WORKING DIRECTORY] [-t TERRAFORM PROJECT]\n\n";
    printf "Perform a terraform apply on a terraform directory project\n";
    printf "If WORKING DIRECTORY is not provided, the current directory willl be used by default\n";
    printf "Multiple TERRAFORM_PROJECT can be used\n";
    printf "\nParameters:\n";
    printf "  -t, --target\t\t\tSpecifies multiple external Terraform projects\n";
    printf "  -w, --working-directory\tSpecifies working directory. Default: current directory\n";
    printf "  -s, --sub\t\t\tSpecifies subscription.\n";
    printf "Example:\n";
    printf "\tclah tf apply\n\t\tPerform terraform apply in current directory\n\n";
    printf "\tclah tf apply /terraform/project\n\t\tPerform terraform apply in /terraform/project directory\n\n";
    printf "\tclah tf apply /terraform/project -r resource.docker_container.my_container\n\t\tPerforms a Terraform apply passing the -target parameter\n\t\tto deploy resource.docker_container.my_container\n\n";
    printf "\tclah tf apply -s dev\n\t\tPerform terraform apply using ./sub/dev/backend.tfvars file\n";
    printf "\n";
}

tf_apply()
{
    WORKING_DIRECTORY=$1
    SUBSCRIPTION_NAME=$2

    CONFIG_TF_FILE=${WORKING_DIRECTORY}/${SUBSCRIPTION_NAME}/config-tf.json
    if [[ -z $SUBSCRIPTION_NAME ]] ; then
        CONFIG_TF_FILE=${WORKING_DIRECTORY}/config-tf.json
    fi;
    if [[ ! -f ${CONFIG_TF_FILE} ]] ; then
        printf "config-tf.json file not found\n";
        exit 1;
    fi;
    CONFIG_TF_PATH=$(dirname ${CONFIG_TF_FILE})

    BACKEND_FILE=$(cat ${CONFIG_TF_FILE} | jq -r '.["backend-file"]')

    if [[ "$BACKEND_FILE" == "null" ]] ; then
        printf "Backend file not found in ${CONFIG_TF_FILE}\n";
        exit 1;
    fi;

    REAL_BACKEND_FILE=${CONFIG_TF_PATH}/${BACKEND_FILE}
    if [[ ! -f ${REAL_BACKEND_FILE} ]] ; then
        printf "backend file not found\n";
        exit 1;
    fi;

    VARS_FILE=$(cat ${CONFIG_TF_FILE} | jq -r '.["variables-file"]')
    if [[ "$VARS_FILE" == "null" ]] ; then
        printf "Variables file not found in ${CONFIG_TF_FILE}\n";
        exit 1;
    fi;
    REAL_VARIABLES_FILE=${CONFIG_TF_PATH}/${VARS_FILE}
    if [[ ! -f ${REAL_BACKEND_FILE} ]] ; then
        printf "variables file not found\n";
        exit 1;
    fi;

    echo ${CONFIG_TF_PATH};
    echo ${CONFIG_TF_FILE};
    echo ${REAL_BACKEND_FILE};
    echo ${REAL_VARIABLES_FILE};
    echo cd ${WORKING_DIRECTORY};
    echo terraform apply bla bla
    # config json deve contenere
    # backend file => sarebbe il backend.tfvars
    # terraform_project => array di progetti 

}

tf_apply()
{
    WORKING_DIRECTORY=$1
    SUBSCRIPTION_NAME=$2

    CONFIG_TF_FILE=${WORKING_DIRECTORY}/${SUBSCRIPTION_NAME}/config-tf.json
    if [[ -z $SUBSCRIPTION_NAME ]] ; then
        CONFIG_TF_FILE=${WORKING_DIRECTORY}/config-tf.json
    fi;
    if [[ ! -f ${CONFIG_TF_FILE} ]] ; then
        printf "config-tf.json file not found\n";
        exit 1;
    fi;
    CONFIG_TF_PATH=$(dirname ${CONFIG_TF_FILE})

    BACKEND_FILE=$(cat ${CONFIG_TF_FILE} | jq -r '.["backend-file"]')

    if [[ "$BACKEND_FILE" == "null" ]] ; then
        printf "Backend file not found in ${CONFIG_TF_FILE}\n";
        exit 1;
    fi;

    REAL_BACKEND_FILE=${CONFIG_TF_PATH}/${BACKEND_FILE}
    if [[ ! -f ${REAL_BACKEND_FILE} ]] ; then
        printf "backend file not found\n";
        exit 1;
    fi;

    VARS_FILE=$(cat ${CONFIG_TF_FILE} | jq -r '.["variables-file"]')
    if [[ "$VARS_FILE" == "null" ]] ; then
        printf "Variables file not found in ${CONFIG_TF_FILE}\n";
        exit 1;
    fi;
    REAL_VARIABLES_FILE=${CONFIG_TF_PATH}/${VARS_FILE}
    if [[ ! -f ${REAL_BACKEND_FILE} ]] ; then
        printf "variables file not found\n";
        exit 1;
    fi;

    echo ${CONFIG_TF_PATH};
    echo ${CONFIG_TF_FILE};
    echo ${REAL_BACKEND_FILE};
    echo ${REAL_VARIABLES_FILE};
    echo cd ${WORKING_DIRECTORY};
    echo terraform destroy bla bla
    # config json deve contenere
    # backend file => sarebbe il backend.tfvars
    # terraform_project => array di progetti 

}

case "$COMMAND" in
    help)
        ACTION_TF=$1
        if [[ -z $ACTION_TF ]] ; then
            usage;
            exit;
        fi;
        if [[ "$ACTION_TF" == "apply" ]] ; then
            usage_apply;
            exit;
        fi;
        ;;
    apply)
        ACTION_TF=$1
        PARSED=$(getopt -o w:s: -l working-directory:sub: -n "$PARAMS" -- "$@")
        WORKING_DIRECTORY="."
        SUBSCRIPTION_NAME=""
        eval set -- "$PARSED"
        while true; do
            case "$1" in
                -w|--working-directory)
                    if [[ "$WORKING_DIRECTORY" != "." ]] ; then
                        printf "Too much working directory provided\n";
                        exit 1;
                    fi;
                    WORKING_DIRECTORY="$2"
                    shift 2;
                    ;;
                -s|--sub)
                    if [[ "$SUBSCRIPTION_NAME" != "" ]] ; then
                        printf "Too much subscription provided\n";
                        exit 1;
                    fi;
                    SUBSCRIPTION_NAME="$2"
                    shift 2;
                    ;;
                --)
                    shift;
                    break;
                    ;;
                *)
                    printf "Opzione non riconosciuta: $1"
                    exit 1;
                    ;;
            esac;
        done;
        tf_apply "$WORKING_DIRECTORY" "$SUBSCRIPTION_NAME"
        ;;
    destroy)
        ACTION_TF=$1
        PARSED=$(getopt -o w:s: -l working-directory:sub: -n "$PARAMS" -- "$@")
        WORKING_DIRECTORY="."
        SUBSCRIPTION_NAME=""
        eval set -- "$PARSED"
        while true; do
            case "$1" in
                -w|--working-directory)
                    if [[ "$WORKING_DIRECTORY" != "." ]] ; then
                        printf "Too much working directory provided\n";
                        exit 1;
                    fi;
                    WORKING_DIRECTORY="$2"
                    shift 2;
                    ;;
                -s|--sub)
                    if [[ "$SUBSCRIPTION_NAME" != "" ]] ; then
                        printf "Too much subscription provided\n";
                        exit 1;
                    fi;
                    SUBSCRIPTION_NAME="$2"
                    shift 2;
                    ;;
                --)
                    shift;
                    break;
                    ;;
                *)
                    printf "Opzione non riconosciuta: $1"
                    exit 1;
                    ;;
            esac;
        done;
        tf_destroy "$WORKING_DIRECTORY" "$SUBSCRIPTION_NAME"
        ;;
    *)
        usage;
        exit 1;
        ;;
esac

