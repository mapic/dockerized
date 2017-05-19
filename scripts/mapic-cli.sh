#!/bin/bash
usage () {
    echo "Usage: mapic [COMMAND]"
    exit 1
}
enter_usage () {
    echo "Usage: mapic enter [filter]"
    exit 1
}
enter_usage_missing_container () {
    echo "No container matched filter: $2" 
    exit 1
}
env_not_set () {
    echo "You need to set MAPIC_ROOT_FOLDER and MAPIC_DOMAIN enviroment variable before you can use this script."
    exit 1
}

# mapic-cli functions
mapic_ps () {
    docker ps 
    exit 0
}
mapic_start () {
    cd $MAPIC_ROOT_FOLDER
    ./restart-mapic.sh
}
mapic_stop () {
    cd $MAPIC_ROOT_FOLDER
    ./stop-mapic.sh
}
mapic_logs () {
    cd $MAPIC_ROOT_FOLDER
    ./show-logs.sh
}
mapic_enter () {
    [ -z "$1" ] && enter_usage
    CONTAINER=$(docker ps -q --filter name=$2)
    [ -z "$CONTAINER" ] && enter_usage_missing_container "$@"
    docker exec -it $CONTAINER bash
}
mapic_help () {
    echo ""
    echo "Usage: mapic COMMAND"
    echo ""
    echo "A CLI for Mapic"
    echo ""
    echo "Commands:"
    echo "  start         Start Mapic server"
    echo "  stop          Stop Mapic server"
    echo "  enter         Enter running container. Takes 'grep' argument for finding Docker container."
    echo "  logs          Show logs of running Mapic server"
    echo "  ps            Show running containers"
    echo ""
}

# check vars
[ -z "$1" ] && usage
[ -z "$MAPIC_ROOT_FOLDER" ] && env_not_set 
[ -z "$MAPIC_DOMAIN" ] && env_not_set 



# api
case "$1" in

start)  mapic_start;;
stop)   mapic_stop;;
enter)  mapic_enter "$@";;
logs)   mapic_logs;;
help)   mapic_help;;
ps)     mapic_ps;;
*)      usage;;
esac

