#!/bin/bash
#!/bin/bash

usage()
{
  printf "\nUsage: clah <init|destroy> all\n\n"
}

show_version()
{
    printf "clah version ${CLAH_VERSION}\n";
}


if [[ -z $1 ]] ; then
	usage;
	exit;
fi;

init_all()
{
    printf "Install Service Config container "
    $CLAH_BIN/tools/bs-consul-tf-state.sh init >/dev/null 2>/dev/null || { printf "ERROR\n"; exit 1; };
    printf "\n";
    cd $CLAH_HOME/infrastructure/network/
    printf "Creating infrastructure network ";
    bash apply.sh -y >/dev/null || { printf "ERROR\n"; exit 1; };
    cd $CLAH_HOME/infrastructure/vault/
    printf "\n";
    printf "Create vault service ";
    bash apply.sh -y >/dev/null || { printf "ERROR\n"; exit 1; };
    printf "\n";
}

COMMAND=$1

case "$COMMAND" in
    init)
        $CLAH_BIN/tools/bs-consul-tf-state.sh $COMMAND
        cd $CLAH_HOME/infrastructure/network/
        $CLAH_BIN/tools/tf.sh apply -y
        cd $CLAH_HOME/infrastructure/vault/
        $CLAH_BIN/tools/tf.sh apply -y
        ;;
    destroy)
        cd $CLAH_HOME/infrastructure/vault/
        $CLAH_BIN/tools/tf.sh destroy -y
        cd $CLAH_HOME/infrastructure/network/
        $CLAH_BIN/tools/tf.sh destroy -y
        $CLAH_BIN/tools/bs-consul-tf-state.sh $COMMAND
        ;;
    help|-h|--help)
        usage;
        ;;
    version|-v|--version)
        show_version;
        exit;
        ;;
    *)
        usage;
        ;;
esac