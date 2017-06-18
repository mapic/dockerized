#!/bin/bash
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
#
#   _________  ____  / /______(_) /_  __  __/ /_(_)___  ____ _
#  / ___/ __ \/ __ \/ __/ ___/ / __ \/ / / / __/ / __ \/ __ `/
# / /__/ /_/ / / / / /_/ /  / / /_/ / /_/ / /_/ / / / / /_/ / 
# \___/\____/_/ /_/\__/_/  /_/_.___/\__,_/\__/_/_/ /_/\__, /  
#                                                    /____/   
#
#   To whomever is using this script, feel free to add more scripts and wrappers. 
#   Look at the syntax and organisation of other functions, or follow these steps:
# 
#   How to add more scripts/commands:
#       1. fork this repo
#       2. add entry in mapic_cli_usage
#       3. add entry in mapic_cli
#       4. add your script in your own command (see other examples)
#       5. put script-file.sh in /cli/ or relevant subfolder (install, config, etc)
#       6. create PR @ https://github.com/mapic/mapic-cli
#       
#       (For "cool" ascii art text, see: http://patorjk.com/software/taag/#p=display&f=Slant&t=mapic)
#       (Tracking issue: https://github.com/mapic/mapic/issues/27)
#
#
#   / /_____  ____/ /___ 
#  / __/ __ \/ __  / __ \
# / /_/ /_/ / /_/ / /_/ /
# \__/\____/\__,_/\____/ 
#
# 1. (DONE!) Create an ENV.sh file to source each time mapic-cli is run. 
#    That way we don't have to worry about globals, just our own env file.
#    Need to clean up this ENV across Mapic
# 2. (DONE!) Prompt and contiune on missing $MAPIC_DOMAIN 
# 3. Install flow, work seamlessly with `mapic install [OPTIONS]`. Also for travis (`mapic install --travis [OPTIONS]`)
# 4. Create own repo for mapic-cli eventually
#
#   Currnetly working on: 1. sed -i not cross-comp 
#                         2. .mapic.env-e file is cause of sed bug
#
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #  




#   _____/ (_)
#  / ___/ / / 
# / /__/ / /  
# \___/_/_/      
mapic_cli_usage () {
    echo ""
    echo "Usage: mapic COMMAND"
    echo ""
    echo "A CLI for Mapic"
    echo ""
    echo "Management commands:"
    echo "  start               Start Mapic stack"
    echo "  restart             Stop, flush and start Mapic stack"
    echo "  stop                Stop Mapic stack"
    echo "  status              Display status on running Mapic stack"
    echo "  logs                Show logs of running Mapic server"
    echo "  logs dump           Dump logs of running Mapic server to disk"
    echo "  test                Run Mapic tests"
    echo ""
    echo "Commands:"
    echo "  install             Install Mapic"
    echo "  config              Configure Mapic"
    echo "  domain              Set Mapic domain"
    echo "  env                 Get and set Mapic environment variables"
    echo "  dns                 Create or check DNS entries for Mapic"
    echo "  ssl                 Create or scan SSL certificates for Mapic"
    echo "  enter               Enter running container"
    echo "  run                 Run command inside a container"
    echo "  grep                Find string in files in subdirectories of current path"
    echo "  ps                  Show running containers"
    echo "  debug               Toggle debug mode"
    echo "  pull                git pull --rebase all repos"
    echo ""
    echo "API commands:"
    echo "  api user            Handle Mapic users"
    echo "  api upload          Upload data"  
    echo ""
    
    # undocumented api
    if [[ "$MAPIC_DEBUG" = "true" ]]; then
    echo "Undocumented:"
    echo "  edit                Edit mapic-cli.sh source file"
    echo ""
    fi
    exit 0
}
mapic_cli () {

    # initialize mapic cli
    initialize "$@"

    # check 
    test -z "$1" && mapic_cli_usage

    # run internal mapic
    m "$@"
}

m () {
    
    case "$1" in

        # documented API
        install)    mapic_install "$@";;
        start)      mapic_start;;
        restart)    mapic_restart;;
        stop)       mapic_stop;;
        status)     mapic_status "$@";;
        logs)       mapic_logs "$@";;
        enter)      mapic_enter "$@";;
        run)        mapic_run "$@";;
        api)        mapic_api "$@";;
        ps)         mapic_ps;;
        dns)        mapic_dns "$@";;
        ssl)        mapic_ssl "$@";;
        test)       mapic_test "$@";;
        home)       mapic_home "$@";;
        config)     mapic_config "$@";;
        grep)       mapic_grep "$@";;
        debug)      mapic_debug "$@";;
        pull)       mapic_pull "$@";;
        domain)     mapic_domain "$@";;
        help)       mapic_cli_usage;;
        --help)     mapic_cli_usage;;
        -h)         mapic_cli_usage;;
        env)        mapic_env "$@";;
        edit)       mapic_edit "$@";;
        create_storage) mapic_create_storage "$@";;
    
        *)          mapic_wild "$@";;
    esac
}

#    (_)___  (_) /_(_)___ _/ (_)___  ___ 
#   / / __ \/ / __/ / __  / / /_  / / _ \
#  / / / / / / /_/ / /_/ / / / / /_/  __/
# /_/_/ /_/_/\__/_/\__,_/_/_/ /___/\___/ 
print_debug () {
    printf "${c_dot}[debug mode]${c_reset}\n"
}
initialize () {

    # get osx/linux
    get_mapic_host_os

    # hardcoded env file
    MAPIC_ENV_FILE=/usr/local/bin/.mapic.env

    # check if we're properly installed
    if [ ! -f $MAPIC_ENV_FILE ]; then

        # we're not installed, so let's do that

        # check for .mapic.env
        test ! -f mapic-cli.sh && corrupted_install

        # check for default env
        test ! -f .mapic.default.env && corrupted_install 

        # set cli folder
        MAPIC_CLI_FOLDER="$( cd "$(dirname "$0")" ; pwd -P )"

        # set root folder (../)
        MAPIC_ROOT_FOLDER="$(dirname "$MAPIC_CLI_FOLDER")"

        # set color file
        MAPIC_COLOR_FILE=$MAPIC_CLI_FOLDER/.mapic.colors

        # cp default env file
        cp $MAPIC_CLI_FOLDER/.mapic.default.env /usr/local/bin/.mapic.env 

        # create symlink for global mapic
        create_mapic_symlink

        # install dependencies on osx
        test $MAPIC_HOST_OS == "osx" && install_osx_tools

        # ensure editor
        ensure_editor

        # now everything should work, time to write ENV
        write_env MAPIC_ROOT_FOLDER $MAPIC_ROOT_FOLDER
        write_env MAPIC_CLI_FOLDER $MAPIC_CLI_FOLDER
        write_env MAPIC_HOST_OS $MAPIC_HOST_OS
        write_env MAPIC_ENV_FILE $MAPIC_ENV_FILE
        write_env MAPIC_COLOR_FILE $MAPIC_COLOR_FILE

    fi

    # set which folder mapic was executed from
    MAPIC_CLI_EXECUTED_FROM=$PWD

    # source env file
    set -o allexport
    source $MAPIC_ENV_FILE
    source $MAPIC_COLOR_FILE

    # mark [debug mode]
    test ! -z $MAPIC_DEBUG && print_debug

    # mark that we're in a cli
    MAPIC_CLI=true
}
corrupted_install () {
    echo "Install is corrupted. Try downloading fresh from https://github.com/mapic/cli"
    exit 1 
}
install_osx_tools () {
    SED=$(which sed)
    BREW=$(which brew)
    JQ=$(which jq)

    # gnu-sed
    if [ -z $SED ]; then
        echo "Installing GNU sed..."
        cd $MAPIC_CLI_FOLDER/lib >/dev/null 2>&1
        rm -rf sed-4.4 >/dev/null 2>&1
        tar xf sed-4.4.tar.xz >/dev/null 2>&1
        cd sed-4.4 >/dev/null 2>&1
        ./configure >/dev/null 2>&1
        make >/dev/null 2>&1
        make install >/dev/null 2>&1
        cd .. && rm -rf sed-4.4 >/dev/null 2>&1
    fi
    # brew
    # jq
}
get_mapic_host_os () {
    case "$OSTYPE" in
      darwin*)  MAPIC_HOST_OS="osx";; 
      linux*)   MAPIC_HOST_OS="linux" ;;
      solaris*) echo "Your OS is not supported yet. Feel free to contribute with a PR! :)"; exit 1;;
      bsd*)     echo "Your OS is not supported yet. Feel free to contribute with a PR! :)"; exit 1;;
      msys*)    echo "Your OS is not supported yet. Feel free to contribute with a PR! :)"; exit 1;;
      *)        echo "Your OS is not supported yet. Feel free to contribute with a PR! :)"; exit 1;;
    esac
}
mapic_debug () {
    if [ -z $MAPIC_DEBUG ]; then
        echo "Debug mode is on"
        write_env MAPIC_DEBUG true
    else 
       
         echo "Debug mode is off"
        write_env MAPIC_DEBUG
    fi
}
mapic_edit () {
    # edit mapic-cli.sh
    echo "$MAPIC_DEFAULT_EDITOR $MAPIC_CLI_FOLDER/mapic-cli.sh"
    $MAPIC_DEFAULT_EDITOR $MAPIC_CLI_FOLDER/mapic-cli.sh
}
                  
#  / _ \/ __ \ | / /
# /  __/ / / / |/ / 
# \___/_/ /_/|___/  
mapic_env_usage () {
    echo ""
    echo "Usage: mapic env COMMAND"
    echo ""
    echo "Commands:"
    echo "  set [key] [value]       Set an environment variable. See 'mapic env set --help' for more."
    echo "  get [key]               Get an environment variable. Do 'mapic get' to list all variables."
    echo "  edit                    Edit ENV directly in your favorite editor. (Set editor with MAPIC_DEFAULT_EDITOR env, "
    echo "  file                    Returns absolute path of Mapic ENV file, useful for scripts and '--env-file'"
    echo "                          eg. 'mapic env set MAPIC_DEFAULT_EDITOR nano')"
    echo ""
    echo "Use with caution. Variables are sourced to Mapic environment."
    echo ""
    exit 0
}
mapic_env () {

    # debug mode: show env with 'mapic env'
    if [ -z $MAPIC_DEBUG ] && test -z $2; then
        echo "(Mapic DEBUG mode: Showing ENV instead of help screen.)"
        echo ""
        mapic_env_get
        exit 0
    fi

    test -z $2 && mapic_env_usage
    case "$2" in
        get)        mapic_env_get "$@";;
        set)        mapic_env_set "$@";;
        edit)       mapic_env_edit "$@";;
        file)       mapic_env_file "$@";;
        prompt)     mapic_env_prompt "$@";;
        *)          mapic_env_usage;
    esac 
}
mapic_env_set_usage () {
    echo ""
    echo "Usage: mapic env set KEY VALUE"
    echo ""
    echo "Use with caution. Variables are sourced to Mapic environment."
    echo ""
    exit 0
}
mapic_env_set_help () {
    echo ""
    echo "Usage: mapic env set KEY VALUE"
    echo ""
    echo "Example: mapic env set MAPIC_DOMAIN localhost"
    echo ""
    echo "Possible environment variables options:"
    echo "  MAPIC_DOMAIN                    The domain which Mapic is running on, eg. 'maps.mapic.io' "
    echo "  MAPIC_USER_EMAIL                Your email. Only used for creating SSL certificates for now."
    echo "  MAPIC_IP                        Public IP of your server. Set automatically by default."
    echo "  MAPIC_AWS_ACCESSKEYID           Amazon AWS credentials: Access Key Id"
    echo "  MAPIC_AWS_SECRETACCESSKEY       Amazon AWS credentials: Secret Access Key"
    echo "  MAPIC_AWS_HOSTED_ZONE_DOMAIN    Amazon Route53 Zone Domain. Used for creating DNS entries with Route53."
    echo "  MAPIC_DEBUG                     Debug switch, used arbitrarily."
    echo "  MAPIC_ROOT_FOLDER               Folder where 'mapic' root lives. Set automatically."
    echo ""
    echo "  See 'mapic env get' for all variables"
    echo ""
    exit 0
}
mapic_env_set () {
    test -z $3 && mapic_env_set_usage
    test -z $4 && mapic_env_set_usage

    # undocumented flags
    FLAG=$5

    # update env file
    write_env $3 $4
 
    # confirm new variable
    [[ "$FLAG" = "" ]] && mapic env get $3
    [[ "$FLAG" = "value" ]] && echo $4
}
# fn used internally to write to env file
write_env () {
    test -z $1 && failed "missing arg"
    # test -z $2 && failed "missing arg"

    # add or replace line in .mapic.env
    if grep -q "$1" "$MAPIC_ENV_FILE"; then

        # replace line
        sed -i "/$1/c\\$1=$2" $MAPIC_ENV_FILE 
    else
        # add to bottom
        echo "$1"="$2" >> $MAPIC_ENV_FILE

        # ensure newline
        sed -i -e '$a\' $MAPIC_ENV_FILE 
    fi
}
mapic_env_get () {
    if [ -z $3 ]
    then
        cat $MAPIC_ENV_FILE 
    else 
        cat $MAPIC_ENV_FILE | grep "$3="
    fi
}
mapic_env_edit () {
    # edit .mapic.env
    $MAPIC_DEFAULT_EDITOR $MAPIC_ENV_FILE
}
mapic_env_file () {
    echo "$MAPIC_ENV_FILE"
}
mapic_env_prompt_usage () {
    echo ""
    echo "Usage: mapic env prompt ENV_KEY [MESSAGE] [DEFAULT_VALUE]"
    echo ""
    echo "Prompt user for Mapic environment variable and set it permanently"
    echo ""
    echo "Options:"
    echo "  ENV_KEY         The environment key to set"
    echo "  MESSAGE         A message to diplay at prompt"
    echo "  DEFAULT_VALUE   The default provided value"
    echo ""
    exit 1
}
mapic_env_prompt () {
    ENV_KEY=$3
    MSG=$4
    DEFAULT_VALUE=$5
    test -z $ENV_KEY && mapic_env_prompt_usage

    # prompt
    echo ""
    if [ $MAPIC_HOST_OS == "osx" ]; then
        # hack: (-i) not valid on osx
        read -e -p "$ENV_KEY $MSG: " ENV_VALUE 
    else
        read -e -p "$ENV_KEY $MSG: " -i "$DEFAULT_VALUE" ENV_VALUE 
    fi

    # set env
    # test -n "$ENV_VALUE" && mapic env set "$ENV_KEY" "$ENV_VALUE" 
    mapic env set "$ENV_KEY" "$ENV_VALUE" 
}

usage () {
    echo "Usage: mapic [COMMAND]"
    exit 1
}
failed () {
    echo "Something went wrong: $1"
    exit 1
}
create_mapic_symlink () {
    unlink /usr/local/bin/mapic >/dev/null 2>&1
    ln -s $MAPIC_CLI_FOLDER/mapic-cli.sh /usr/local/bin/mapic >/dev/null 2>&1
    chmod +x /usr/local/bin/mapic >/dev/null 2>&1
    echo "Self-registered as global command (/usr/local/bin/mapic)"
}
ensure_editor () {
    if [ -z $MAPIC_DEFAULT_EDITOR ]; then
        MAPIC_DEFAULT_EDITOR=nano
        write_env MAPIC_DEFAULT_EDITOR $MAPIC_DEFAULT_EDITOR
    fi
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
    cd $MAPIC_CLI_FOLDER/management
    bash start-mapic.sh
}
mapic_restart () {
    mapic_stop
    mapic_flush
    mapic_start
}
mapic_stop () {
    cd $MAPIC_CLI_FOLDER/management
    bash stop-mapic.sh
}
mapic_flush () {
    cd $MAPIC_CLI_FOLDER/management
    bash flush-mapic.sh
}
mapic_create_storage () {
    cd $MAPIC_CLI_FOLDER/install
    bash create-storage-containers.sh
}

#    / /___  ____ ______
#   / / __ \/ __ `/ ___/
#  / / /_/ / /_/ (__  ) 
# /_/\____/\__, /____/  
#         /____/        
mapic_logs () {
    if [ "$2" == "dump" ]; then
        # dump logs to disk
        cd $MAPIC_CLI_FOLDER/management
        bash dump-logs.sh
    else
        # print logs to console
        cd $MAPIC_CLI_FOLDER/management
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


mapic_pull () {
    cd $MAPIC_ROOT_FOLDER

    REPO_FOLDER=$MAPIC_ROOT_FOLDER/modules

    echo "Pulling mapic/mapic"
    git pull --rebase

    echo "Pulling mapic/engine"
    cd $REPO_FOLDER/engine
    git pull --rebase

    echo "Pulling mapic/mile"
    cd $REPO_FOLDER/mile
    git pull --rebase

    echo "Pulling mapic/mapic.js"
    cd $REPO_FOLDER/mapic.js
    git pull --rebase

    echo "Pulling mapic/sdk"
    cd $REPO_FOLDER/sdk
    git pull --rebase
    
    echo "All pulled!"
}

    
mapic_domain_usage () {
    echo ""
    echo "Usage: mapic domain [domain]"
    echo ""
    echo "  domain      Domain with which Mapic is configured"
    echo ""
    echo "Example: 'mapic domain localhost'"
    exit 1
}
mapic_domain () {
    [ -z "$1" ] && mapic_domain_usage
    [ -z "$2" ] && mapic_domain_usage
    DOMAIN=$2
    write_env MAPIC_DOMAIN $DOMAIN
    echo ""
    echo "Mapic domain is now configured to $DOMAIN"
}

#   ___  ____  / /____  _____
#  / _ \/ __ \/ __/ _ \/ ___/
# /  __/ / / / /_/  __/ /    
# \___/_/ /_/\__/\___/_/     
mapic_enter_usage () {
    echo ""
    echo "Usage: mapic enter [filter]"
    echo ""
    echo "  filter      Grep filter for container name."
    echo ""
    echo "Example: 'mapic enter engine'"
    exit 1
}
mapic_enter () {
    [ -z "$1" ] && mapic_enter_usage
    [ -z "$2" ] && mapic_enter_usage
    C=$(docker ps -q --filter name=$2)
    [ -z "$C" ] && mapic_enter_usage_missing_container "$@"
    docker exec -it $C bash
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
    echo ""
    echo "Usage: mapic install [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  stable      Install latest stable version of Mapic"
    echo "  master      Install master (dev) branch of Mapic"
    echo "  docker      Install Docker"
    echo "  jq          Install JQ (dependency)"
    echo "  node        Install NodeJS (not a dependency)"
    echo ""
    exit 1
}
mapic_install () {
    test -z $2 && mapic_install_usage
    case "$2" in
        stable)     mapic_install_stable "$@";;
        master)     mapic_install_master "$@";;
        docker)     mapic_install_docker "$@";;
        jq)         mapic_install_jq "$@";;
        node)       mapic_install_node "$@";;
        *)          mapic_install_usage;
    esac 
}
mapic_install_stable () {

    # todo: use revisions, latest stable tag, etc.
    cd $MAPIC_ROOT_FOLDER
    git checkout master # todo: revision tag

    # ensure MAPIC_DOMAIN
    test -z $MAPIC_DOMAIN && mapic env prompt MAPIC_DOMAIN "Domain for Mapic. (Example: maps.mapic.io)" localhost
    
    # save env
    write_env MAPIC_DOMAIN $MAPIC_DOMAIN

    # notify
    echo ""
    echo "Installing Mapic to $MAPIC_DOMAIN"
    echo ""
    echo "Press Ctrl-C in next 10 seconds to cancel."
    sleep 10

    # init submodules
    cd $MAPIC_CLI_FOLDER/install
    bash init-submodules.sh

    # create ssl
    cd $MAPIC_CLI_FOLDER/install
    if [ $MAPIC_DOMAIN = "localhost" ]; then
        bash create-ssl-localhost.sh
    else 
        bash create-ssl-public-domain.sh
    fi

    # update config
    cd $MAPIC_CLI_FOLDER/install
    bash update-config.sh

    # create storage (todo: remove with deploy)
    cd $MAPIC_CLI_FOLDER/install
    bash create-storage-containers.sh

}
mapic_install_master () {
    echo "todo"
    mapic_install_stable
}

# mapic_install_mapic_domain () {
#     cd $MAPIC_CLI_FOLDER/install
#     bash init-submodules.sh

#     cd $MAPIC_CLI_FOLDER/install
#     if [ $MAPIC_DOMAIN = "localhost" ]; then
#         bash create-ssl-localhost.sh
#     else 
#         bash create-ssl-public-domain.sh
#     fi

#     cd $MAPIC_CLI_FOLDER/install
#     bash update-config.sh

#     cd $MAPIC_CLI_FOLDER/install
#     bash create-storage-containers.sh
# }

# mapic_install_mapic_localhost () {
#     cd $MAPIC_CLI_FOLDER/install
#     bash init-submodules.sh

#     cd $MAPIC_CLI_FOLDER/install
#     bash create-ssl-localhost.sh

#     cd $MAPIC_CLI_FOLDER/install
#     bash update-config.sh

#     cd $MAPIC_CLI_FOLDER/install
#     bash create-storage-containers.sh
# }
mapic_install_jq () {
    DISTRO=$(lsb_release -si)
    case "$DISTRO" in
        Ubuntu)     mapic_install_jq_ubuntu "$@";;
        *)          mapic_install_jq_unsupported;;
    esac 
}
mapic_install_jq_ubuntu () {
    apt-get -qq update -y || exit 1
    apt-get -qq install -y jq || exit 1
    echo "JQ installed."
    exit 0
}
mapic_install_jq_unsupported () {
    echo ""
    echo "Unable to install JQ automatically."
    echo ""
    echo "See https://stedolan.github.io/jq/download/"
    echo ""
    exit 1
}
mapic_install_docker () {
    DISTRO=$(lsb_release -si)
    case "$DISTRO" in
        Ubuntu)     mapic_install_docker_ubuntu "$@";;
        *)          mapic_install_docker_unsupported;;
    esac 
}
mapic_install_docker_unsupported () {
    echo ""
    echo "Unable to install Docker automatically."
    echo ""
    echo "See https://docs.docker.com/engine/installation/"
    echo ""
    exit 1
}
mapic_install_docker_ubuntu () {
    echo "Installing Docker!"
    cd $MAPIC_CLI_FOLDER/install
    ls -l
    echo $PWD
    bash install-docker.sh
}

#   ____ _____  (_)
#  / __ `/ __ \/ / 
# / /_/ / /_/ / /  
# \__,_/ .___/_/   
#     /_/          
mapic_api_usage () {
    mapic_api_display_config
    echo ""
    echo "Usage: mapic api [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  configure   Configure API settings"
    echo "  user        Show and edit users"
    echo "  upload      Upload data"
    echo ""
    exit 1 
}
mapic_api () {
    test -z "$2" && mapic_api_usage
    case "$2" in
        configure)  mapic_api_configure "$@";;
        user)       mapic_api_user "$@";;
        upload)     mapic_api_upload "$@";;
        *)          mapic_api_usage;
    esac 
}

#   ____ _____  (_)  __  ______  / /___  ____ _____/ /
#  / __ `/ __ \/ /  / / / / __ \/ / __ \/ __ `/ __  / 
# / /_/ / /_/ / /  / /_/ / /_/ / / /_/ / /_/ / /_/ /  
# \__,_/ .___/_/   \__,_/ .___/_/\____/\__,_/\__,_/   
#     /_/              /_/                            
mapic_api_upload_usage () {
    echo ""
    echo "Usage: mapic api upload DATASET [OPTIONS]"
    echo ""
    echo "Dataset:"
    echo "  Absolute path of dataset to upload"
    echo ""
    # echo "Options:"
    # echo "  (Not yet implemented:)"
    # echo "  --project-id        Project id"
    # echo "  --dataset-name      Name of dataset'"
    # echo "  --project-name      Name of new project if created"
    # echo ""
    exit 1 
}
mapic_api_upload () {
    test -z "$3" && mapic_api_upload_usage
    cd $MAPIC_CLI_FOLDER/api
    bash upload-data.sh "$@"
    exit 0
}

#   ____ _____  (_)  __  __________  _____
#  / __ `/ __ \/ /  / / / / ___/ _ \/ ___/
# / /_/ / /_/ / /  / /_/ (__  )  __/ /    
# \__,_/ .___/_/   \__,_/____/\___/_/     
#     /_/                                     
mapic_api_user_usage () {
    echo ""
    echo "Usage: mapic api user [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  list        List registered users"
    echo "  create      Create user"
    echo "  super       Promote user to superadmin"
    echo ""
    exit 1
}
mapic_api_user () {
    [ -z "$3" ] && mapic_api_user_usage
    case "$3" in
        list)       mapic_api_user_list "$@";;
        create)     mapic_api_user_create "$@";;
        super)      mapic_api_user_super "$@";;
        *)          mapic_api_user_usage;
    esac 
}
mapic_api_user_list () {
    cd $MAPIC_CLI_FOLDER/api
    bash list-users.sh
}
mapic_api_user_create_usage () {
    echo ""
    echo "Usage: mapic api user create [EMAIL] [USERNAME] [FIRSTNAME] [LASTNAME]"
    echo ""
    exit 1
}
mapic_api_user_create () {
    test -z "$4" && mapic_api_user_create_usage
    test -z "$5" && mapic_api_user_create_usage
    test -z "$6" && mapic_api_user_create_usage
    test -z "$7" && mapic_api_user_create_usage
    cd $MAPIC_CLI_FOLDER/api
    bash create-user.sh "${@:4}"
}
mapic_api_user_super_usage () {
    echo ""
    echo "Usage: mapic api user super [EMAIL]"
    echo ""
    echo "(WARNING: This command will promote user to SUPERADMIN,"
    echo "giving access to all projects and data.)"
    echo ""
    exit 1
}
mapic_api_user_super () {
    test -z "$4" && mapic_api_user_super_usage
    echo "WARNING: This command will promote user to SUPERADMIN,"
    echo "giving access to all projects and data."
    echo ""
    read -p "Are you sure? (y/n)" -n 1 -r
    echo 
    if [[ $REPLY =~ ^[Yy]$ ]]
    then
        cd $MAPIC_CLI_FOLDER/api
        bash promote-super.sh "${@:4}"
    fi
}
mapic_api_configure () {
    m config prompt MAPIC_API_DOMAIN "Please enter the domain of the Mapic API you want to connect with (eg. maps.mapic.io)"
    m config prompt MAPIC_API_USERNAME "Please enter your Mapic API username"
    m config prompt MAPIC_API_AUTH "Please enter your Mapic API password"

    mapic_api_display_config
}

mapic_api_display_config () {
    echo ""
    echo "Mapic API config:"
    echo "  Domain:   $MAPIC_API_DOMAIN"
    echo "  Username: $MAPIC_API_USERNAME"
    echo "  Auth:     $MAPIC_API_AUTH"
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
    test -z "$C" && mapic_enter_usage_missing_container "$@"
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
    if [ $MAPIC_DOMAIN = "localhost" ]; then
        cd $MAPIC_CLI_FOLDER/install
        bash create-ssl-localhost.sh
    else 
        cd $MAPIC_CLI_FOLDER/install
        bash create-ssl-public-domain.sh
    fi
}
mapic_ssl_scan () {
    if [ $MAPIC_DOMAIN = "localhost" ]; then
        echo "SSLLabs scan not supported on localhost."
        exit 1
    fi
    cd $MAPIC_CLI_FOLDER/install/ssl
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
    cd $MAPIC_CLI_FOLDER/dns
    bash create-dns-entries-route-53.sh
}

#    _____/ /_____ _/ /___  _______
#   / ___/ __/ __ `/ __/ / / / ___/
#  (__  ) /_/ /_/ / /_/ /_/ (__  ) 
# /____/\__/\__,_/\__/\__,_/____/  
mapic_status () {
    cd $MAPIC_CLI_FOLDER/management
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
    echo "  refresh                 Refresh Mapic configuration files"
    echo "  set                     Set an environment variable. See 'mapic config set --help' for more."
    echo "  get                     Get an environment variable. Do 'mapic config get' to list all variables."
    echo "  get                     Get an environment variable. Do 'mapic config get' to list all variables."
    echo "  edit                    Edit config directly in your favorite editor."
    echo "  file                    Returns absolute path of Mapic config file, useful for scripts and 'docker run --env-file'"
    echo ""
    exit 1   
}
mapic_config () {
    test -z "$2" && mapic_config_usage
     case "$2" in
        refresh)    mapic_config_refresh "$@";;
        set)        mapic_env_set "$@";;
        get)        mapic_env_get "$@";;
        list)       mapic_env_get;;
        edit)       mapic_env_edit "$@";;
        file)       mapic_env_file "$@";;
        prompt)     mapic_env_prompt "$@";; 
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
                        
#   / __ `/ ___/ _ \/ __ \
#  / /_/ / /  /  __/ /_/ /
#  \__, /_/   \___/ .___/ 
# /____/         /_/      
mapic_grep_usage () {
    echo ""
    echo "Usage: mapic grep [PATTERN]"
    echo ""
    echo "Will run: grep -rnw . -e \"PATTERN\""
    echo ""
    exit 1  
}
mapic_grep () {
    test -z "$2" && mapic_grep_usage
    echo "[grep -rn \"$2\" $MAPIC_CLI_EXECUTED_FROM]:"
    grep -rn "$2" $MAPIC_CLI_EXECUTED_FROM
}

#   ___  ____  / /________  ______  ____  (_)___  / /_
#  / _ \/ __ \/ __/ ___/ / / / __ \/ __ \/ / __ \/ __/
# /  __/ / / / /_/ /  / /_/ / /_/ / /_/ / / / / / /_  
# \___/_/ /_/\__/_/   \__, / .___/\____/_/_/ /_/\__/  
#                    /____/_/                         
mapic_cli "$@"
