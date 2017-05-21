#!/bin/bash
#   _________  ____  / /______(_) /_  __  __/ /_(_)___  ____ _
#  / ___/ __ \/ __ \/ __/ ___/ / __ \/ / / / __/ / __ \/ __ `/
# / /__/ /_/ / / / / /_/ /  / / /_/ / /_/ / /_/ / / / / /_/ / 
# \___/\____/_/ /_/\__/_/  /_/_.___/\__,_/\__/_/_/ /_/\__, /  
#                                                    /____/   
#
#   To whomever is using this script, feel free to add more scripts and wrappers. 
#   Just glean the other wrappers below, and follow these steps:
# 
#   How to add more scripts/commands:
#       1. add entry in mapic_help
#       2. add entry in mapic_cli
#       3. add your script in your own command (see other examples)
#       4. put script-file.sh in /cli/ or relevant subfolder (install, config, etc)
#       5. commit and push as branch/PR
#       
#       (For "cool" ascii art text, see: http://patorjk.com/software/taag/#p=display&f=Slant&t=mapic)
#       (Tracking issue: https://github.com/mapic/mapic/issues/27)


#   / /_____  ____/ /___ 
#  / __/ __ \/ __  / __ \
# / /_/ /_/ / /_/ / /_/ /
# \__/\____/\__,_/\____/ 
#
# 1. Create an ENV.sh file to source each time mapic-cli is run. 
#    That way we don't have to worry about globals, just our own env file.
#    Need to clean up this ENV across Mapic
# 2. Prompt and contiune on missing $MAPIC_DOMAIN 
# 3. Install flow, work seamlessly with `mapic install [OPTIONS]`. Also for travis (`mapic install --travis [OPTIONS]`)
# 4. Create own repo for mapic-cli (?)


#   _____/ (_)
#  / ___/ / / 
# / /__/ / /  
# \___/_/_/      
mapic_help () {
    echo ""
    echo "Usage: mapic COMMAND"
    echo ""
    echo "A CLI for Mapic"
    echo ""
    echo "Commands:"
    echo "  start               Start Mapic stack"
    echo "  restart             Stop, flush and start Mapic stack"
    echo "  stop                Stop Mapic stack"
    echo "  status              Display status on running Mapic stack"
    echo "  logs                Show logs of running Mapic server"
    echo "  logs dump           Dump logs of running Mapic server to disk"
    echo "  enter [filter]      Enter running container (with [filter] in grep format for finding Docker container)"
    echo "  run [filter] [cmd]  Run command inside a container"
    echo "  user                Show user information"
    echo "  ps                  Show running containers"
    echo "  dns                 Create or check DNS entries for Mapic"
    echo "  ssl                 Create or scan SSL certificates for Mapic"
    echo "  install             Install Mapic"
    echo "  config              Configure Mapic"
    echo "  test                Run Mapic tests"
    echo "  help                This screen"
    echo ""
    exit 0
}
mapic_cli () {

    # source n check
    source_env "$@"
    check "$@"

    # api
    case "$1" in
        install)    mapic_install "$@";;
        start)      mapic_start;;
        restart)    mapic_start;;
        stop)       mapic_stop;;
        status)     mapic_status "$@";;
        logs)       mapic_logs "$@";;
        enter)      mapic_enter "$@";;
        run)        mapic_run "$@";;
        user)       mapic_user "$@";;
        ps)         mapic_ps;;
        dns)        mapic_dns "$@";;
        ssl)        mapic_ssl "$@";;
        test)       mapic_test "$@";;
        home)       mapic_home "$@";;
        config)     mapic_config "$@";;
        help)       mapic_help;;
        --help)     mapic_help;;
        -h)         mapic_help;;
        *)          mapic_wild "$@";;
    esac
}

#    _______________(_)___  / /_   __  __/ /_(_) /____
#   / ___/ ___/ ___/ / __ \/ __/  / / / / __/ / / ___/
#  (__  ) /__/ /  / / /_/ / /_   / /_/ / /_/ / (__  ) 
# /____/\___/_/  /_/ .___/\__/   \__,_/\__/_/_/____/  
#                 /_/                                  
check () {
    test -z "$MAPIC_ROOT_FOLDER" && env_usage # check MAPIC_ROOT_FOLDER is set
    test -z "$MAPIC_DOMAIN" && env_usage # check MAPIC_DOMAIN is set
    test ! -f /usr/bin/mapic && symlink_usage # create symlink for global mapic
    test -z "$1" && mapic_help # check for command line arguments
}
source_env () {
    # get absolute path of mapic-cli.sh
    D="$(readlink -f "$0")"
    MAPIC_CLI_FOLDER=${D%/*}

    # source env file
    set -o allexport
    source $MAPIC_CLI_FOLDER/env-cli.sh
}
usage () {
    echo "Usage: mapic [COMMAND]"
    exit 1
}
failed () {
    echo "Something went wrong: $1"
    exit 1
}
env_usage () {
    echo "You need to set MAPIC_DOMAIN environment variable before you can use this script."
    # todo: prompt and continue
    exit 1
}
symlink_usage () {
    ln -s $MAPIC_ROOT_FOLDER/scripts/cli/mapic-cli.sh /usr/bin/mapic
    echo "Self-registered as global command (/usr/bin/mapic)"
    mapic_help;
}
               
#    / __ \/ ___/
#   / /_/ (__  ) 
#  / .___/____/  
# /_/            
mapic_ps () {
    docker ps 
    exit 0
}

#    _____/ /_____ ______/ /_
#   / ___/ __/ __ `/ ___/ __/
#  (__  ) /_/ /_/ / /  / /_  
# /____/\__/\__,_/_/   \__/  
mapic_start () {
    cd $MAPIC_ROOT_FOLDER
    ./restart-mapic.sh
}

#    _____/ /_____  ____ 
#   / ___/ __/ __ \/ __ \
#  (__  ) /_/ /_/ / /_/ /
# /____/\__/\____/ .___/ 
#               /_/      
mapic_stop () {
    cd $MAPIC_ROOT_FOLDER
    ./stop-mapic.sh
}

#    / /___  ____ ______
#   / / __ \/ __ `/ ___/
#  / / /_/ / /_/ (__  ) 
# /_/\____/\__, /____/  
#         /____/        
mapic_logs () {
    if [ "$2" == "dump" ]; then
        # dump logs to disk
        cd $MAPIC_ROOT_FOLDER/scripts/log
        bash dump-logs.sh
        exit 0
    else
        # print logs to console
        cd $MAPIC_ROOT_FOLDER/scripts/log
        bash show-logs.sh
    fi
}
                     
#  _      __(_) /___/ /
# | | /| / / / / __  / 
# | |/ |/ / / / /_/ /  
# |__/|__/_/_/\__,_/   
mapic_wild () {
    echo "\"$@\" is not a Mapic command. See 'mapic help' for available commands."
    exit 1
}

#   ___  ____  / /____  _____
#  / _ \/ __ \/ __/ _ \/ ___/
# /  __/ / / / /_/  __/ /    
# \___/_/ /_/\__/\___/_/     
mapic_enter () {
    [ -z "$1" ] && mapic_enter_usage
    C=$(docker ps -q --filter name=$2)
    [ -z "$C" ] && mapic_enter_usage_missing_container "$@"
    docker exec -it $C bash
}
mapic_enter_usage () {
    echo "Usage: mapic enter [filter]"
    exit 1
}
mapic_enter_usage_missing_container () {
    echo "No container matched filter: $2" 
    exit 1
}

#    (_)___  _____/ /_____ _/ / /
#   / / __ \/ ___/ __/ __ `/ / / 
#  / / / / (__  ) /_/ /_/ / / /  
# /_/_/ /_/____/\__/\__,_/_/_/   
mapic_install_usage () {
    echo "Usage: mapic install [domain] (or set \$MAPIC_DOMAIN env variable)"
    exit 1
}
mapic_install () {
    # ensure either $MAPIC_DOMAIN is set, or arg for domain is passed
    # todo: better sanity checks for domain, maybe confirm
    if [ "$2" = "" ]
    then
        if [ "$MAPIC_DOMAIN" = "" ]
        then
            mapic_install_usage
        else 
            mapic_run_install
        fi
    else 
        export MAPIC_DOMAIN=$2
        mapic_run_install
    fi

}
mapic_run_install () {
    echo "Installing Mapic to $MAPIC_DOMAIN"
    echo ""
    echo "Press Ctrl-C in next 5 seconds to cancel."
    sleep 5
    cd $MAPIC_ROOT_FOLDER/scripts/install
    bash install-to-localhost.sh
}
                       
#  / / / / ___/ _ \/ ___/
# / /_/ (__  )  __/ /    
# \__,_/____/\___/_/     
mapic_user_usage () {
    echo ""
    echo "Usage: mapic user [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  list        List registered users"
    echo "  create      Create user"
    echo "  super       Promote user to superadmin"
    echo ""
    exit 1
}
mapic_user () {
    [ -z "$2" ] && mapic_user_usage

    # api
    case "$2" in
        list)       mapic_user_list;;
        create)     mapic_user_create;;
        super)      mapic_user_super;;
        *)          mapic_user_usage;
    esac 
}
mapic_user_list () {
    echo "List users!"
}
mapic_user_create () {
    echo "'mapic user create' not yet supported."
}
mapic_user_super () {
    echo "'mapic user super' not yet supported."
}
                   
#   / ___/ / / / __ \
#  / /  / /_/ / / / /
# /_/   \__,_/_/ /_/ 
mapic_run_usage () {
    echo ""
    echo "Usage: mapic run [filter] [commands]"
    echo ""
    echo "Example: mapic run engine bash"
    exit 1
}
mapic_run () {
    test -z "$2" && mapic_run_usage
    test -z "$3" && mapic_run_usage
    C=$(docker ps -q --filter name=$2)
    test -z "$C" && enter_usage_missing_container "$@"
    docker exec $C ${@:3}
}

#    __________/ /
#   / ___/ ___/ / 
#  (__  |__  ) /  
# /____/____/_/   
mapic_ssl_usage () {
    echo ""
    echo "Usage: mapic ssl [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  create      Create SSL certificates for your domain"
    echo "  scan        Run security scan on your domain and SSL"
    echo ""
    exit 1   
}
mapic_ssl () {
    test -z "$2" && mapic_ssl_usage
    case "$2" in
        create)     mapic_ssl_create;;
        scan)       mapic_ssl_scan;;
        *)          mapic_ssl_usage;
    esac 
}
mapic_ssl_create () {
    cd $MAPIC_CLI_FOLDER
    bash create-ssl-certs.sh
}
mapic_ssl_scan () {
    cd $MAPIC_CLI_FOLDER
    bash ssllabs-scan.sh "https://$MAPIC_DOMAIN"
}

#   ____/ /___  _____
#  / __  / __ \/ ___/
# / /_/ / / / (__  ) 
# \__,_/_/ /_/____/  
mapic_dns_usage () {
    echo ""
    echo "Usage: mapic dns [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  create       Create DNS entries on Amazon Route 53 for your domain"
    echo ""
    exit 1   
}
mapic_dns () {
    test -z "$2" && mapic_dns_usage
    case "$2" in
        create)     mapic_dns_set;;
        *)          mapic_dns_usage;
    esac 
}
mapic_dns_set () {
    cd $MAPIC_CLI_FOLDER
    bash create-dns-entries-route-53.sh
}

#    _____/ /_____ _/ /___  _______
#   / ___/ __/ __ `/ __/ / / / ___/
#  (__  ) /_/ /_/ / /_/ /_/ (__  ) 
# /____/\__/\__,_/\__/\__,_/____/  
mapic_status () {
    cd $MAPIC_CLI_FOLDER
    bash mapic-status.sh
    exit 1
}

#   / /____  _____/ /_
#  / __/ _ \/ ___/ __/
# / /_/  __(__  ) /_  
# \__/\___/____/\__/  
mapic_test_usage () {
    echo ""
    echo "Usage: mapic test [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  all         Run all available Mapic tests"
    echo "  engine      Run all Mapic Engine tests"
    echo "  mile        Run all Mapic Mile tests"
    echo "  mapicjs     Run all Mapic.js tests"
    echo "  travis      Run a build test on Travis"
    echo ""
    exit 1   
}
mapic_test () {
    test -z "$2" && mapic_test_usage
    case "$2" in
        all)        mapic_test_all;;
        engine)     mapic_test_engine;;
        mile)       mapic_test_mile;;
        mapicjs)    mapic_test_mapicjs;;
        travis)     mapic_test_travis;;
        *)          mapic_test_usage;
    esac 
}
mapic_test_all () {
    echo "testing all"
    mapic run engine npm test || mapic_test_failed "$@"
    mapic run mile npm test || mapic_test_failed "$@"
    mapic run engine bash public/test/test.sh || mapic_test_failed "$@"
}
mapic_test_engine () {
    echo "Tesing Mapic Engine"
    mapic run engine npm test || mapic_test_failed "$@"
    exit 0;
}
mapic_test_mile () {
    echo "Tesing Mapic Mile"
    mapic run mile npm test || mapic_test_failed "$@"
    exit 0;
}
mapic_test_mapicjs () {
    echo "Tesing Mapic.js"
    mapic run engine bash public/test/test.sh || mapic_test_failed "$@"
    exit 0;
}
mapic_test_travis() {
    echo "Not yet supported."
    exit 0;
}
mapic_test_failed () {
    echo "Some tests failed: $@";
    exit 1;
}

#   _________  ____  / __(_)___ _
#  / ___/ __ \/ __ \/ /_/ / __ `/
# / /__/ /_/ / / / / __/ / /_/ / 
# \___/\____/_/ /_/_/ /_/\__, /  
#                       /____/   
mapic_config_usage () {
    echo ""
    echo "Usage: mapic config [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  refresh [config]   Refresh Mapic configuration files"
    echo ""
    exit 1   
}
mapic_config () {
    test -z "$2" && mapic_config_usage
     case "$2" in
        refresh)    mapic_config_refresh "$@";;
        *)          mapic_config_usage;;
    esac 
}
mapic_config_refresh_usage () {
    echo ""
    echo "Usage: mapic config refresh [OPTIONS]"
    echo ""
    echo "Attempts to reset configuration to default and working condition."
    echo ""
    echo "Options:"
    echo "  all         Refresh all Mapic configuration files"
    echo "  engine      Refresh Mapic Engine config"
    echo "  mile        Refresh Mapic Mile config"
    echo "  mapicjs     Refresh Mapic.js config"
    echo "  nginx       Refresh NGINX config"
    echo "  redis       Refresh Redis config"
    echo "  mongo       Refresh Mongo config"
    echo "  postgis     Refresh PostGIS config"
    echo "  slack       Refresh Slack config"
    echo ""
    exit 0
}
mapic_config_refresh () {
    echo $1 $2 $3
    test -z "$3" && mapic_config_refresh_usage
    case "$3" in
        all)        mapic_config_refresh_all "$@";;
        engine)     mapic_config_refresh_engine "$@";;
        mile)       mapic_config_refresh_mile "$@";;
        mapicjs)    mapic_config_refresh_mapicjs "$@";;
        nginx)      mapic_config_refresh_nginx "$@";;
        redis)      mapic_config_refresh_redis "$@";;
        mongo)      mapic_config_refresh_mongo "$@";;
        postgis)    mapic_config_refresh_postgis "$@";;
        slack)      mapic_config_refresh_slack "$@";;
        *)          mapic_config_refresh_usage "$@";;
    esac 
}
mapic_config_refresh_all () {
    cd $MAPIC_CLI_FOLDER
    bash configure-mapic.sh || failed "$@"
}
mapic_config_refresh_nginx () {
    echo "Not yet supported."
    exit 0;
}
mapic_config_refresh_postgis () {
    echo "Not yet supported."
    exit 0;
}
mapic_config_refresh_redis () {
    echo "Not yet supported."
    exit 0;
}   
mapic_config_refresh_mongo () {
    echo "Not yet supported."
    exit 0;
}
mapic_config_refresh_mile () {
    echo "Not yet supported."
    exit 0;
}
mapic_config_refresh_mapicjs () {
    echo "Not yet supported."
    exit 0;
}
mapic_config_refresh_engine () {
    echo "Not yet supported."
    exit 0;
}
mapic_config_refresh_slack () {
    echo "Not yet supported."
    exit 0;
}



#   ___  ____  / /________  ______  ____  (_)___  / /_
#  / _ \/ __ \/ __/ ___/ / / / __ \/ __ \/ / __ \/ __/
# /  __/ / / / /_/ /  / /_/ / /_/ / /_/ / / / / / /_  
# \___/_/ /_/\__/_/   \__, / .___/\____/_/_/ /_/\__/  
#                    /____/_/                         
mapic_cli "$@"
