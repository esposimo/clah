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

COMMAND=$1

case "$COMMAND" in
    init)
        $CLAH_BIN/tools/bs-consul-tf-state.sh $COMMAND
        cd $CLAH_HOME/infrastructure/network/
        bash apply.sh -y
        cd $CLAH_HOME/infrastructure/vault/
        bash apply.sh -y
        ;;
    destroy)
        cd $CLAH_HOME/infrastructure/vault/
        bash destroy.sh -y
        cd $CLAH_HOME/infrastructure/network/
        bash destroy.sh -y
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