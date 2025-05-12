#!/bin/bash
#!/bin/bash

usage()
{
  printf "\nUsage: clah <init|destroy>\n\n"
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
        cd $CLAH_HOME/infrastructure/vault/
        sh apply.sh "$@"
        ;;
    destroy)
        cd $CLAH_HOME/infrastructure/vault/
        sh destroy.sh "$@"
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