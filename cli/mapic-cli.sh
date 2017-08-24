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
#       For "cool" ascii art text, see: http://patorjk.com/software/taag/#p=display&f=Slant&t=mapic
#       Tracking issue: https://github.com/mapic/mapic/issues/27
#
#       For printing colors, see the ecco() function (eg. ecco 12 "this is color 12"), and the .mapic.colors env file.
#
#   / /_____  ____/ /___ 
#  / __/ __ \/ __  / __ \
# / /_/ /_/ / /_/ / /_/ /
# \__/\____/\__,_/\____/ 
#
#   1. Move all config into ENV
#   2. Make Windows compatible
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #  

MAPIC_CLI_VERSION=17.8.23

# # # # # # # # # # # # # 
#
#
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
    echo "  stop                Stop Mapic stack"
    echo "  restart             Stop, flush and start Mapic stack"
    echo "  status              Display status on running Mapic stack"
    echo "  logs [container]    Show logs of running Mapic server"
    echo "  scale               Scale containers across nodes"
    echo ""
    echo "Commands:"
    echo "  configure           Automatically configure Mapic"
    echo "  install             Install Mapic"
    echo "  config              View and edit Mapic config"
    echo "  domain              Set Mapic domain"
    echo "  volume              See Mapic volumes"
    echo "  dns                 Create or check DNS entries for Mapic"
    echo "  ssl                 Create or scan SSL certificates for Mapic"
    echo "  enter               Enter running container"
    echo "  run                 Run command inside a container"
    echo "  grep                Find string in files in subdirectories of current path"
    echo "  ps                  Show running containers"
    echo "  debug               Toggle debug mode"
    echo "  version             Display Mapic version"
    echo "  info                Display Mapic info"
    echo "  test                Run Mapic tests"
    echo "  bench               Run Mapic benchmark tests"
    echo "  update              Update Mapic repositories"
    echo ""
    echo "API commands:"
    echo "  api login           Authenticate with (any) Mapic API"
    echo "  api user            Handle Mapic users"
    echo "  api upload          Upload data"  
    echo "  api project         Handle projects"
    echo ""
    
    # undocumented api
    if [[ "$MAPIC_DEBUG" == "true" ]]; then
    echo "Undocumented:"
    echo "  edit                Edit mapic-cli.sh source file"
    echo "  tor                 Run Tor Project non-exit relays"
    echo "  viz                 Visualize Docker nodes graphically"
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
    if [[ "$TRAVIS" == "true" ]];then
        (set -x; m "$@")
    else
        m "$@"
    fi
}
m () {
    
    case "$1" in

        # documented API
        install)    mapic_install "$@";;
        start)      mapic_up;;
        up)         mapic_up;;
        restart)    mapic_restart;;
        reup)       mapic_restart;;
        stop)       mapic_down;;
        down)       mapic_down;;
        status)     mapic_status "$@";;
        s)          mapic_status "$@";;
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
        configure)  mapic_configure "$@";;
        volume)     mapic_volume "$@";;
        grep)       mapic_grep "$@";;
        debug)      mapic_debug "$@";;
        domain)     mapic_domain "$@";;
        travis)     mapic_travis "$@";;
        # env)        mapic_config "$@";; # deprecated
        edit)       mapic_edit "$@";;
        version)    mapic_version "$@";;
        info)       mapic_info "$@";;
        tor)        mapic_tor "$@";;
        viz)        mapic_viz "$@";;
        scale)      mapic_scale "$@";;
        bench)      mapic_bench "$@";;
        update)     mapic_update "$@";;
        help)       mapic_cli_usage;;
        --help)     mapic_cli_usage;;
        -h)         mapic_cli_usage;;
        *)          mapic_wild "$@";;
    esac
}

#    (_)___  (_) /_(_)___ _/ (_)___  ___ 
#   / / __ \/ / __/ / __  / / /_  / / _ \
#  / / / / / / /_/ / /_/ / / / / /_/  __/
# /_/_/ /_/_/\__/_/\__,_/_/_/ /___/\___/ 
initialize () {

    # get osx/linux
    get_mapic_host_os

    # global env files
    MAPIC_ENV_FILE=/usr/local/bin/.mapic.env
    MAPIC_AWS_ENV_FILE=/usr/local/bin/.mapic.aws.env

    # check if we're properly installed
    if [ ! -f $MAPIC_ENV_FILE ]; then

        # we're not installed, so let's do that

        # check for .mapic.env
        test ! -f mapic-cli.sh && _corrupted_install

        # check for default env
        test ! -f .mapic.default.env && _corrupted_install 

        # set cli folder
        MAPIC_CLI_FOLDER="$( cd "$(dirname "$0")" ; pwd -P )"

        # set root folder (../)
        MAPIC_ROOT_FOLDER="$(dirname "$MAPIC_CLI_FOLDER")"

        # set color file
        MAPIC_COLOR_FILE=$MAPIC_CLI_FOLDER/.mapic.colors

        # set config folder
        MAPIC_CONFIG_FOLDER=$MAPIC_ROOT_FOLDER/cli/config

        # cp default env files
        cp $MAPIC_CLI_FOLDER/.mapic.default.env $MAPIC_ENV_FILE
        cp $MAPIC_CLI_FOLDER/.mapic.default.aws.env $MAPIC_AWS_ENV_FILE 

        # determine public ip
        _determine_ip
        
        # create symlink for global mapic
        _create_mapic_symlink

        # install dependencies
        _install_dependencies

        # update submodules
        _init_submodules

        # ensure editor
        _ensure_editor

        # now everything should work, time to write ENV
        _write_env MAPIC_ROOT_FOLDER $MAPIC_ROOT_FOLDER
        _write_env MAPIC_CLI_FOLDER $MAPIC_CLI_FOLDER
        _write_env MAPIC_CONFIG_FOLDER $MAPIC_CONFIG_FOLDER
        _write_env MAPIC_ENV_FILE $MAPIC_ENV_FILE
        _write_env MAPIC_AWS_ENV_FILE $MAPIC_AWS_ENV_FILE
        _write_env MAPIC_COLOR_FILE $MAPIC_COLOR_FILE
        _write_env MAPIC_CONFIG_FOLDER $MAPIC_CONFIG_FOLDER
        _write_env MAPIC_IP $MAPIC_IP
        _write_env MAPIC_HOST_OS $MAPIC_HOST_OS

    fi

    # set which folder mapic was executed from
    MAPIC_CLI_EXECUTED_FROM=$PWD

    # source env file
    set -o allexport
    source $MAPIC_ENV_FILE
    source $MAPIC_AWS_ENV_FILE
    source $MAPIC_COLOR_FILE

    # mark [debug mode]
    # test "$MAPIC_DEBUG" == "true" && ecco 82 "debug mode"

    # mark that we're in a cli
    MAPIC_CLI=true

}
usage () {
    echo "Usage: mapic [COMMAND]"
    exit 1
}
failed () {
    echo "Something went wrong: $1"
    exit 1
}
abort () {
    echo "Something went wrong: $1"
    exit 1
}
_corrupted_install () {
    echo "Install is corrupted. Try downloading fresh with `curl -sSL https://get.mapic.io | sh`"
    exit 1 
}
_determine_ip () {
    MAPIC_IP=$(curl ipinfo.io/ip)

    if [[ "$TRAVIS" == "true" ]]; then
        MAPIC_IP=127.0.0.1
    fi
}
_init_submodules () {
    cd $MAPIC_ROOT_FOLDER
    git submodule init
    git submodule update --remote
    git remote set-url origin git@github.com:mapic/mapic.git
}
_install_dependencies () {

    # install dependencies on osx
    if [[ "$MAPIC_HOST_OS" == "osx" ]]; then
        _install_osx_tools
    fi

    # install dependencies on linux
    if [[ "$MAPIC_HOST_OS" == "linux" ]]; then
        _install_linux_tools
    fi

}
mapic_update () {
    cd $MAPIC_ROOT_FOLDER
    echo "Updating local repositories..."
    ecco 4 "mapic/mapic"
    git pull origin master --rebase
    cd $MAPIC_ROOT_FOLDER/mile
    ecco 4 "mapic/mile"
    git pull origin master --rebase
    cd $MAPIC_ROOT_FOLDER/engine
    ecco 4 "mapic/engine"
    git pull origin master --rebase
    cd $MAPIC_ROOT_FOLDER/mapic.js
    ecco 4 "mapic/mapic.js"
    git pull origin master --rebase
}
_install_linux_tools () {

    # realpath
    REALPATH=$(which realpath)
    if [ -z $REALPATH ]; then
        apt-get update -y
        apt-get install -y realpath
    fi

    # git
    GITPATH=$(which git)
    if [ -z $GITPATH ]; then
        apt-get update -y
        apt-get install -y git
    fi

    # certbot
    CERTBOTPATH=$(which certbot)
    if [ -z $CERTBOTPATH ]; then
        # todo: incorporate with nginx so refresh can be done on running server
        # perhaps put in docker image
        sudo apt-get update -y
        sudo apt-get install -y --force-yes software-properties-common
        sudo add-apt-repository -y ppa:certbot/certbot
        sudo apt-get update -y
        sudo apt-get install -y --force-yes python-certbot-nginx 
    fi

    # docker
    mapic_install_docker

}
_install_osx_tools () {
    
    SED=$(which sed)
    BREW=$(which brew)
    JQ=$(which jq)
    GREP=$(which grep)
    REALPATH=$(which realpath)
    DOCKERPATH=$(which docker)
   
    if [[ "$MAPIC_DEBUG" == true ]]; then
        echo "Installing OSX Tools"
        echo "SED: $SED"
        echo "BREW: $BREW"
        echo "JQ: $JQ"
        echo "GREP: $GREP"
        echo "PWGEN: $PWGEN"
        echo "TRAVIS: $TRAVIS"
        echo "CI: $CI"
        echo "MAPIC_TRAVIS: $MAPIC_TRAVIS"
        echo "DOCKERPATH: $DOCKERPATH"
    fi

    SEDV=$(sed --version | grep "sed (GNU sed)")
    echo "SED VERSION: $SEDV"

    # gnu-sed
    if [ -z $SEDV ]; then
        echo "Installing GNU sed..."
        cd $MAPIC_CLI_FOLDER/lib >/dev/null 2>&1
        rm -rf sed-4.4 >/dev/null 2>&1
        tar xf sed-4.4.tar.xz >/dev/null 2>&1
        cd sed-4.4 >/dev/null 2>&1
        ./configure >/dev/null 2>&1
        make >/dev/null 2>&1
        make install >/dev/null 2>&1
        cd .. && rm -rf sed-4.4 >/dev/null 2>&1
        SEDV=$(sed --version | grep "sed (GNU sed)")
        echo "$SEDV installed"
    fi

    # grep
    if [ -z $GREP ]; then
        if [ -z $BREW ]; then
            echo "Brew required for OSX. Please install 'grep' manually:"
            echo "brew install grep --with-default-names"
        else
            echo "Installing grep..."
            brew update
            brew install grep --with-default-names
            GREPV=$(grep --version)
            echo "$GREPV installed"
        fi
    fi

    # realpath
    if [ -z $REALPATH ]; then
        if [ -z $BREW ]; then
            echo "Brew required for OSX. Please install 'realpath' manually:"
            echo "brew install realpath"
        else
            echo "Installing realpath..."
            # realpath
            brew update
            brew install coreutils
            REALPATHV=$(realpath --version | grep realpath)
            echo "$REALPATHV installed"
        fi
    fi
    
    # docker
    if [ -z $DOCKERPATH ]; then
        mapic_install_docker
    fi
    
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
    if [[ "$MAPIC_DEBUG" == "true" ]]; then
        echo "Debug mode is off"
        _write_env MAPIC_DEBUG
    else
        echo "Debug mode is on"
        _write_env MAPIC_DEBUG true
    fi
}
mapic_edit () {
    # edit mapic-cli.sh
    $MAPIC_DEFAULT_EDITOR $MAPIC_CLI_FOLDER/mapic-cli.sh
}
ecco () {
    COLOR="c_"$1
    TEXT=${@:2}
    printf "${!COLOR}${TEXT}${c_reset}\n" 
}
ecco_sameline () {
    COLOR="c_"$1
    TEXT=${@:2}
    printf "${!COLOR}${TEXT}${c_reset}" 
}
mapic_info () {

    # docker nodes
    _print_docker_nodes
    
    # mapic config
    _print_config

    # docker info
    _print_docker_info
   
}
_print_docker_info () {
    ecco 6 "Docker:"
    docker info 2>/dev/null > /tmp/.mapic_info 
    cat /tmp/.mapic_info | grep "Swarm" 
    cat /tmp/.mapic_info | grep "Is Manager" 
    cat /tmp/.mapic_info | grep "Managers:" 
    cat /tmp/.mapic_info | grep "Nodes:" 
    cat /tmp/.mapic_info | grep "Containers:" 
    cat /tmp/.mapic_info | grep "Running:" 
    cat /tmp/.mapic_info | grep "Paused:" 
    cat /tmp/.mapic_info | grep "Stopped:" 
    cat /tmp/.mapic_info | grep "CPUs" 
    cat /tmp/.mapic_info | grep "Total Memory" 
    cat /tmp/.mapic_info | grep "Experimental" 
    cat /tmp/.mapic_info | grep "Operating System" 
    cat /tmp/.mapic_info | grep "Server version:" 
    cat /tmp/.mapic_info | grep "Username:" 
    rm /tmp/.mapic_info
    echo ""
}
_print_docker_nodes () {
    echo ""
    ecco 6 "Docker nodes:"
    docker node ls -q | xargs docker inspect --format='
    Node ({{.Spec.Role}})
    ID: {{.ID}}
    Role: {{.Spec.Role}} 
    Labels:
    {{ range $key, $value := .Spec.Labels }} {{$key }}: {{ $value }} 
    {{ end }}Status: {{.Status.State}}
    Addr: {{.Status.Addr}}' 
}
mapic_version () {
    echo ""
    ecco 5 "Mapic Version:"
    echo "  Mapic: $MAPIC_CLI_VERSION"
    echo "  Mapic Engine: $MAPIC_ENGINE_VERSION"
    echo "  Mapic Mile:   $MAPIC_MILE_VERSION"

    # git versions    
    _print_branches
}
mapic_travis_usage () {
    echo ""
    echo "Usage: mapic travis COMMAND"
    echo ""
    echo "Commands:"
    echo "  install     Install dependencies for Travis build"
    echo "  start       Start with Travis logs etc."
    echo ""
    exit 1
}
mapic_travis () {
    echo "mapic_travis $@"
    test -z "$2" && mapic_travis_usage
    case "$2" in
        install)    mapic_travis_install "$@";;
        start)      mapic_travis_start "$@";;
        *)          mapic_travis_usage;;
    esac 
}
mapic_travis_install () {

    # print version
    mapic_version

    # # install docker
    # mapic_install_docker_ubuntu

    # # print version
    # docker version

    # # set localhost
    # _write_env MAPIC_DOMAIN localhost

    # # install
    # _install_mapic

    # # configure
    # _mapic_configure
}

mapic_travis_start () {
    mapic_up
    mapic_status
    mapic_logs
    sleep 60
    mapic_status
    sleep 60
    mapic_status
    sleep 60
    mapic_status
    sleep 60
    mapic_status
    sleep 60
    mapic_status
    sleep 60
    mapic_status
    sleep 60
    mapic_status
    sleep 60
    mapic_status
    sleep 60
    mapic_status
    sleep 60
    mapic_status
    mapic_test_all
    mapic_down
}

mapic_volume_usage () {
    echo ""
    echo "Usage: mapic volume [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  ls      List volumes"
    echo "  rm      Remove volumes (USE WITH CAUTION!)"
    echo ""
    exit 1
}
mapic_volume () {
    test -z "$2" && mapic_volume_usage
    case "$2" in
        ls)    mapic_volume_ls "$@";;
        rm)    mapic_volume_rm "$@";;
        *)     mapic_volume_usage;;
    esac
}
mapic_volume_ls () {
    docker volume ls
}
mapic_volume_rm () {
    if [[ -z "$3" ]]; then 
        echo "Usage: mapic volume rm [volume]"
        exit 1
    fi
    if [[ "$3" == "all" ]]; then

        echo "WARNING: You are about to remove all mapic volumes. "
        ecco 2 "This CANNOT BE UNDONE!"
        read -p "Are you sure?  (y/n)" -n 1 -r
        if [[ $REPLY =~ ^[Yy]$ ]]
        then
            echo ""
            docker volume ls -q | grep mapic | while read line ; do docker volume rm $line ; done
        else
            echo "Nothing removed."
        fi

        exit 0
    fi

    # remove single volume
    echo "WARNING: You are about to remove the volume $3. This CANNOT BE UNDONE!"
    read -p "Are you sure?  (y/n)" -n 1 -r
    if [[ $REPLY =~ ^[Yy]$ ]]
    then
        echo ""
        docker volume rm $3
    else
        echo "Nothing removed."
    fi
}

mapic_scale () {
    echo ""
    echo "Scaling Mapic"
    echo ""
    echo "Please use manual commands. Example:"
    echo ""
    echo "  docker service scale mapic_mile=3"
    echo ""
}

#   _________  ____  / __(_)___ _
#  / ___/ __ \/ __ \/ /_/ / __ `/
# / /__/ /_/ / / / / __/ / /_/ / 
# \___/\____/_/ /_/_/ /_/\__, /  
#                       /____/   
mapic_configure () {
    test -z "$2" && _mapic_configure
    case "$2" in
        stack)      _mapic_configure_stack "$@";;
        aws)        _ensure_aws_creds "$@";;
        *)          _mapic_configure;;
    esac 
}
_mapic_configure () {
    # _refresh_config

    # first install, things that needs configuring:

    # 1. domain + email
    # 2. aws creds
    # 3. dns (if not localhost)
    # 4. ssl 
    # 5. stack is automaitcally configured with ENV inside stack.yml


    # domain
    _ensure_mapic_domain

    # email
    _ensure_user_email

    # aws
    _ensure_aws_creds

    # dns
    m dns create

    # ssl
    m ssl create

    # what else?
    # set redis/mongo auth

    exit 0
}
_mapic_configure_travis () {
    echo "travis"
}
_ensure_mapic_domain () {
    # ensure MAPIC_DOMAIN
    if [ -z "$MAPIC_DOMAIN" ]; then
        MAPIC_DOMAIN=$(m config prompt MAPIC_DOMAIN "Please provide a valid domain for the Mapic install")
    fi
}
_ensure_user_email () {
    # ensure MAPIC_USER_EMAIL
    if [ -z "$MAPIC_USER_EMAIL" ]; then
        MAPIC_USER_EMAIL=$(m config prompt MAPIC_USER_EMAIL "Please provide an email for use with Mapic")
    fi
}
_ensure_aws_creds () {
    # ensure MAPIC_AWS_ACCESSKEYID
    if [ -z "$MAPIC_AWS_ACCESSKEYID" ]; then
        MAPIC_AWS_ACCESSKEYID=$(m config prompt MAPIC_AWS_ACCESSKEYID "AWS: Please provide an Access Key ID for AWS (used for automatic creation of DNS records)")
    fi
    # ensure MAPIC_AWS_SECRETACCESSKEY
    if [ -z "$MAPIC_AWS_SECRETACCESSKEY" ]; then
        MAPIC_AWS_SECRETACCESSKEY=$(m config prompt MAPIC_AWS_SECRETACCESSKEY "AWS: Please provide a Secret Access Key for AWS (used for automatic creation of DNS records)")
    fi
    # ensure MAPIC_AWS_HOSTED_ZONE_DOMAIN
    if [ -z "$MAPIC_AWS_HOSTED_ZONE_DOMAIN" ]; then
        MAPIC_AWS_HOSTED_ZONE_DOMAIN=$(m config prompt MAPIC_AWS_HOSTED_ZONE_DOMAIN "AWS: Please provide an valid Hosted Zone Domain for AWS (eg. 'mapic.io') (used for automatic creation of DNS records)")
    fi
}
mapic_config_usage () {
    echo ""
    echo "Usage: mapic config [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  refresh     Refresh Mapic configuration files"
    echo "  get         Get an environment variable."
    echo "  set         Set an environment variable. See 'mapic config set --help' for more"
    echo "  list        List current config settings"
    echo "  edit        Edit config directly in your favorite editor"
    echo "  file        Returns absolute path of Mapic config file"
    echo ""
    exit 1   
}
mapic_config () {
    test -z "$2" && mapic_config_usage
    case "$2" in
        # refresh)    mapic_config_refresh "$@";;
        set)        mapic_config_set "$@";;
        get)        mapic_config_get "$@";;
        list)       mapic_config_list;;
        edit)       mapic_config_edit "$@";;
        file)       mapic_config_file "$@";;
        prompt)     mapic_config_prompt "$@";; 
        *)          mapic_config_usage;;
    esac 
}
# mapic_config_refresh_usage () {
#     echo ""
#     echo "Usage: mapic config refresh [OPTIONS]"
#     echo ""
#     echo "Attempts to reset configuration to default and working condition."
#     echo ""
#     echo "Options:"
#     echo "  all         Refresh all Mapic configuration files"
#     echo "  engine      Refresh Mapic Engine config"
#     echo "  mile        Refresh Mapic Mile config"
#     echo "  mapicjs     Refresh Mapic.js config"
#     echo "  nginx       Refresh NGINX config"
#     echo "  redis       Refresh Redis config"
#     echo "  mongo       Refresh Mongo config"
#     echo "  postgis     Refresh PostGIS config"
#     echo "  slack       Refresh Slack config"
#     echo ""
#     exit 0
# }
# mapic_config_refresh () {
#     _refresh_config
# }

# deprecated, todo: remove
# mapic_env () {
#     mapic_config "$@"
# }
mapic_config_set_help () {
    echo ""
    echo "Usage: mapic config set KEY VALUE"
    echo ""
    echo "Example: mapic config set MAPIC_DOMAIN localhost"
    echo ""
    echo "Possible environment variables options:"
    echo "  MAPIC_DOMAIN                    The domain which Mapic is running on, eg. 'maps.mapic.io' "
    echo "  MAPIC_USER_EMAIL                Your email. Only used for creating SSL certificates for now."
    echo "  MAPIC_IP                        Public IP of your server. Set automatically by default."
    echo "  MAPIC_AWS_ACCESSKEYID           Amazon AWS credentials: Access Key Id"
    echo "  MAPIC_AWS_SECRETACCESSKEY       Amazon AWS credentials: Secret Access Key"
    echo "  MAPIC_AWS_HOSTED_ZONE_DOMAIN    Amazon Route53 Zone Domain. Used for creating DNS entries with Route53."
    echo "  MAPIC_DEBUG                     Debug switch, for printing verbose logs"
    echo "  MAPIC_ROOT_FOLDER               Folder where 'mapic' root lives. Set automatically."
    echo ""
    echo "  See 'mapic config list' for all available variables"
    echo ""
    exit 0
}
mapic_config_set () {
    test -z $3 && mapic_config_set_usage
    test -z $4 && mapic_config_set_usage

    # undocumented flags
    FLAG=$5

    # update env file
    _write_env $3 $4
 
    # confirm new variable
    [[ "$FLAG" = "" ]] && m config get $3
    # [[ "$FLAG" = "value" ]] && echo $4
}
mapic_config_get_usage () {
    echo ""
    echo "Usage: mapic config get [KEY]"
    echo ""
    echo "Example: mapic config get MAPIC_DOMAIN"
    echo ""
    exit 1
}
mapic_config_get () {
    test -z $3 && mapic_config_get_usage
    cat $MAPIC_ENV_FILE | grep "$3="
}
mapic_config_list () {
    cat $MAPIC_ENV_FILE
}
mapic_config_edit () {
    # edit .mapic.env
    $MAPIC_DEFAULT_EDITOR $MAPIC_ENV_FILE
}
mapic_config_file () {
    echo "$MAPIC_ENV_FILE"
}
mapic_config_prompt_usage () {
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
mapic_config_prompt () {
    ENV_KEY=$3
    MSG=$4
    DEFAULT_VALUE=$5
    test -z $ENV_KEY && mapic_config_prompt_usage

    # prompt
    echo ""
    if [ $MAPIC_HOST_OS == "osx" ]; then
        # hack: (-i) not valid on osx
        read -e -p "$MSG: " ENV_VALUE 
    else
        read -e -p "$MSG: " -i "$DEFAULT_VALUE" ENV_VALUE 
    fi

    # set env
    _write_env "$ENV_KEY" "$ENV_VALUE" 

    # return value
    echo "Value saved: $ENV_KEY=$ENV_VALUE"
}
# fn used internally to write to env file
_write_env () {
    test -z $1 && failed "missing arg"

    # add or replace line in .mapic.env
    if grep -q "$1=" "$MAPIC_ENV_FILE"; then
        # replace line
        sed -i "/$1=/c\\$1=$2" $MAPIC_ENV_FILE
    else
        # ensure newline
        sed -i -e '$a\' $MAPIC_ENV_FILE 

        # add to bottom
        echo "$1"="$2" >> $MAPIC_ENV_FILE
    fi

    export $1=$2
}
_create_mapic_symlink () {
    unlink /usr/local/bin/mapic >/dev/null 2>&1
    ln -s $MAPIC_CLI_FOLDER/mapic-cli.sh /usr/local/bin/mapic >/dev/null 2>&1
    chmod +x /usr/local/bin/mapic >/dev/null 2>&1
    echo "Self-registered as global command (/usr/local/bin/mapic)"
}
_ensure_editor () {
    if [ -z $MAPIC_DEFAULT_EDITOR ]; then
        MAPIC_DEFAULT_EDITOR=nano
        
        # if rsub exists
        if [ -f $(which rsub) ]; then
            MAPIC_DEFAULT_EDITOR=rsub
        fi

        # save
        _write_env MAPIC_DEFAULT_EDITOR $MAPIC_DEFAULT_EDITOR
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
mapic_up () {
    STACK=$MAPIC_CONFIG_FOLDER/stack.yml
    docker stack deploy --compose-file=$STACK mapic 
    echo "Mapic is up."
    docker service ls
}
mapic_restart () {
    mapic_down
    mapic_flush
    mapic_up
}
mapic_down () {
    docker stack rm mapic
    echo "Mapic is down."
}
mapic_flush () {
    cd $MAPIC_CLI_FOLDER/management
    bash flush-mapic.sh
}

#    / /___  ____ ______
#   / / __ \/ __ `/ ___/
#  / / /_/ / /_/ (__  ) 
# /_/\____/\__, /____/  
#         /____/     
mapic_logs_container_usage () {
    echo ""
    echo "Usage: mapic logs [container]"
    echo ""
    echo "  container      Tail logs of container"
    echo ""
    echo "Example: 'mapic logs mongo'"
    echo ""
    echo "Available containers are [mile, engine, postgis, nginx, mongo, redis, tor, viz]."
    echo ""
    exit 1
}   
mapic_logs () {
    if [[ -n "$2" ]]; then
        case "$2" in
            mongo)          docker service logs -f mapic_mongo;;
            mile)           docker service logs -f mapic_mile;;
            postgis)        docker service logs -f mapic_postgis;;
            nginx)          docker service logs -f mapic_nginx;;
            engine)         docker service logs -f mapic_engine;;
            redis)          docker service logs -f mapic_redis;;
            *)              mapic_logs_container_usage;
        esac 
        exit
    fi
    if [[ "$TRAVIS" == "true" ]]; then
        # stream logs
        docker service logs -f mapic_mile         &
        docker service logs -f mapic_postgis      &
        docker service logs -f mapic_mongo        &
        docker service logs -f mapic_nginx        &
        docker service logs -f mapic_engine       &
        docker service logs -f mapic_redis        &
    else
        # print current logs
        docker service logs mapic_redis
        docker service logs mapic_mongo      
        docker service logs mapic_nginx      
        docker service logs mapic_postgis    
        docker service logs mapic_mile       
        docker service logs mapic_engine     
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
mapic_domain_usage () {
    echo ""
    echo "Usage: mapic domain [domain]"
    echo ""
    echo "  domain      Domain with which Mapic is configured"
    echo ""
    echo "Example: 'mapic domain localhost'"
    echo ""
    echo "Current Mapic domain is $MAPIC_DOMAIN"
    exit 1
}
mapic_domain () {
    [ -z "$1" ] && mapic_domain_usage
    [ -z "$2" ] && mapic_domain_usage
    DOMAIN=$2
    _write_env MAPIC_DOMAIN $DOMAIN
    echo ""
    echo "Current Mapic domain is $DOMAIN"

    # update config
    mapic_configure
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
    echo "  stable              Install latest stable version of Mapic"
    echo "  master              Install bleeding edge Mapic"
    echo "  branch [GIT-BRANCH] Install custom git branch of Mapic"
    # echo "  travis              Used by Travis build of Mapic"
    echo "  docker              Install Docker"
    echo "  jq                  Install JQ (dependency)"
    echo "  node                Install NodeJS (not a dependency)"
    echo "  prime               Prime new server"
    echo ""
    exit 1
}
mapic_install () {
    test -z $2 && mapic_install_usage
    case "$2" in
        stable)     mapic_install_stable "$@";;
        master)     mapic_install_master "$@";;
        branch)     mapic_install_branch "$@";;
        travis)     mapic_install_travis "$@";;
        docker)     mapic_install_docker "$@";;
        jq)         mapic_install_jq "$@";;
        node)       mapic_install_node "$@";;
        prime)      mapic_install_prime "$@";;
        *)          mapic_install_usage;
    esac 
}
mapic_install_stable () {

    # checkout latest stable tag
    cd $MAPIC_ROOT_FOLDER
    git fetch --tags
    STABLE=$(git describe --tags `git rev-list --tags --max-count=1`)
    echo "Checking out $STABLE..."
    git checkout $STABLE
    
    # install current branch
    _install_mapic
}
mapic_install_master () {

    echo "Checking out master..."
    cd $MAPIC_ROOT_FOLDER
    git checkout master
   
    # install current branch
    _install_mapic
}
mapic_install_travis () {
    # install whatever branch is designated in travis
    
    # 1. install docker
    # 2. set exp mode
    # 3. init swarm with 127...

    # install docker
    echo "Installing Docker!"
    cd $MAPIC_CLI_FOLDER/install
    bash install-docker-ubuntu.sh

    # put docker in experimental mode for swarm
    echo '{"experimental":true}' >> /etc/docker/daemon.json
    echo "Restarting Docker in experimental mode."

    # restart docker
    _restart_docker

    # init swarm
    docker swarm init --advertise-addr 127.0.0.1

    # set env
    _write_env MAPIC_USER_EMAIL travis@mapic.io
    _write_env MAPIC_DOMAIN localhost

}
mapic_install_branch_usage () {
    echo ""
    echo "Usage: mapic install branch [GIT-BRANCH]"
    echo ""
    exit 1
}
mapic_install_branch () {
    test -z "$3" && mapic_install_branch_usage
    BRANCH=$3

    # checkout branch
    git checkout $BRANCH || abort "Failed to checkout branch $BRANCH. Aborting!" 

    # install mapic on current branch
    _install_mapic
}
mapic_install_prime () {

    if [[ "$MAPIC_HOST_OS" == "linux" ]]; then

        # install tools
        apt-get update -y
        apt-get install -y fish htop build-essential iotop curl wget nano git

        # todo: rsub

        # install docker
        m install docker
        
    else
        echo "I can only prime Linux. Please install Docker manually."
    fi
}
_install_mapic () {

    # get branch
    BRANCH=$(git branch | grep \* | cut -d ' ' -f2)

    # wait ten seconds
    echo ""
    echo "Installing Mapic on branch $BRANCH to domain $MAPIC_DOMAIN"
    echo ""
    echo "Press Ctrl-C in next 10 seconds to cancel."
    sleep 10

    # update submodules
    _update_submodules

    # create ssl
    _create_ssl

    # refresh config
    _refresh_config

    # init docker swarm
    _init_docker_swarm
}

_print_branches () {
    echo ""
    ecco 5 "Git branches:"
    cd $MAPIC_ROOT_FOLDER
    GIT=$(git log --pretty=format:"%h (%ar)" -1)
    BRANCH=$(git branch | grep \* | cut -d ' ' -f2)
    echo "  mapic/mapic:    $BRANCH $GIT"

    cd $MAPIC_ROOT_FOLDER/mile
    GIT=$(git log --pretty=format:"%h (%ar)" -1)
    BRANCH=$(git branch | grep \* | cut -d ' ' -f2)
    echo "  mapic/mile:     $BRANCH $GIT"
   
    cd $MAPIC_ROOT_FOLDER/engine
    GIT=$(git log --pretty=format:"%h (%ar)" -1)
    BRANCH=$(git branch | grep \* | cut -d ' ' -f2)
    echo "  mapic/engine:   $BRANCH $GIT"

    cd $MAPIC_ROOT_FOLDER/mapic.js
    GIT=$(git log --pretty=format:"%h (%ar)" -1)
    BRANCH=$(git branch | grep \* | cut -d ' ' -f2)
    echo "  mapic/mapic.js: $BRANCH $GIT"

    echo ""
}
_refresh_config () {
    echo "TODO: remove this!"
    return
}
_set_redis_auth () {
    MAPIC_REDIS_AUTH=$(docker run mapic/tools pwgen 40)
    _write_env MAPIC_REDIS_AUTH $MAPIC_REDIS_AUTH
    echo "Updated Redis authentication"
}
_set_mongo_auth () {
    MAPIC_MONGO_AUTH=$(docker run mapic/tools pwgen 40)
    _write_env MAPIC_MONGO_AUTH $MAPIC_MONGO_AUTH
    echo "Updated MongoDB authentication"
}
_print_config () {
    
    # check if aws creds are set
    if [[ -n "$MAPIC_AWS_ACCESSKEYID" && -n "$MAPIC_AWS_SECRETACCESSKEY" ]]; then
        AWS_SET=true
    else
        AWS_SET=false
    fi

    echo ""
    ecco 6 "Configuration:"
    echo   "  Domain:               $MAPIC_DOMAIN"
    echo   "  IP:                   $MAPIC_IP"
    echo   "  Email:                $MAPIC_USER_EMAIL"
    echo   "  AWS credentials set:  $AWS_SET"
    echo   ""
}
_update_submodules () {

    # init submodules
    cd $MAPIC_ROOT_FOLDER
    git submodule init
    git submodule update --remote

    # debug: show branchs
    _print_branches
}
_yarn_mapic () {
    # install yarn modules
    docker run -it --rm -v $MAPIC_ROOT_FOLDER:/mapic_tmp -w /mapic_tmp mapic/xenial:latest yarn install 
}
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
    exit 0
}
mapic_install_docker_ubuntu () {

    # install/update docker
    _install_docker_ubuntu

    # use experimental mode
    _set_experimental_docker

    # init swarm
    _init_docker_swarm
    
}
_install_docker_ubuntu () {
    echo "Installing Docker!"
    cd $MAPIC_CLI_FOLDER/install
    bash install-docker-ubuntu.sh
}
_init_docker_swarm () {
    docker swarm init --advertise-addr $MAPIC_IP
}
_set_experimental_docker () {

    # put docker in experimental mode for swarm
    echo '{"experimental":true}' >> /etc/docker/daemon.json
    echo "Restarting Docker in experimental mode."

    # restart
    _restart_docker

}
_restart_docker () {
    if [[ "$TRAVIS" == "true" ]]; then
        # restart docker
        sudo systemctl restart docker || service docker restart
    else

        # ask before restarting docker
        read -p "Restart Docker now?  (y/n)" -n 1 -r
        if [[ $REPLY =~ ^[Yy]$ ]]
        then
            sudo systemctl restart docker || service docker restart
        else
            echo "Please restart Docker manually to access experimental mode needed for Docker Swarm"
        fi
    fi
}

#   ____ _____  (_)
#  / __ `/ __ \/ / 
# / /_/ / /_/ / /  
# \__,_/ .___/_/   
#     /_/          
mapic_api_usage () {
    echo ""
    echo "Usage: mapic [API COMMAND]"
    echo ""
    echo "API commands:"
    echo "  login [again]   Login to a Mapic API [with fresh credentials]"
    echo "  user            Show and edit users"
    echo "  upload          Upload data"
    echo "  project         Handle projects"
    echo ""
    mapic_api_display_config
    exit 1 
}
mapic_api () {
    test -z "$2" && mapic_api_usage
    case "$2" in
        login)      mapic_api_login "$@";;
        user)       mapic_api_user "$@";;
        upload)     mapic_api_upload "$@";;
        project)    mapic_api_project "$@";;
        *)          mapic_api_usage;
    esac 
}
mapic_api_login () {
    if [ "$3" = "again" ]; then
        _write_env MAPIC_API_DOMAIN
        _write_env MAPIC_API_USERNAME
        _write_env MAPIC_API_AUTH
    fi
    
    # todo: remove/merge
    test -z $MAPIC_API_DOMAIN && m config prompt MAPIC_API_DOMAIN "Please enter the domain of the Mapic API you want to connect with" $MAPIC_DOMAIN
    test -z $MAPIC_API_USERNAME && m config prompt MAPIC_API_USERNAME "Please enter your Mapic API username"
    test -z $MAPIC_API_AUTH && m config prompt MAPIC_API_AUTH "Please enter your Mapic API password"

    # todo: 
    _test_api_login

}
mapic_api_display_config () {
    # todo: remove/merge
    echo ""
    echo "Mapic API credentials:"
    echo "  Domain:   $MAPIC_API_DOMAIN"
    echo "  Username: $MAPIC_API_USERNAME"
    echo "  Password: $MAPIC_API_AUTH"
    echo ""
}
_test_api_login () {
    if [ "$1" = "quiet" ]; then
        QUIET=true
    fi
    docker run -it --rm --env-file $MAPIC_ENV_FILE --volume $MAPIC_CLI_FOLDER/api:/tmp -w /tmp node:6 node test-login.js >/dev/null 2>&1
    EXITCODE=$?
    if [ $EXITCODE = 1 ]; then
        echo ""
        ecco 2 "Failed to login to Mapic with the following config:"
        mapic_api_display_config
        exit 1
    elif [ $EXITCODE = 0 ]; then
        test -z $QUIET && ecco 4 "Successfully logged in!"
    fi
}
mapic_api_project_usage () {
    echo ""
    echo "Usage: mapic api project COMMAND"
    echo ""
    echo "Command:"
    echo "  create      Create new project"
    echo "  delete      Delete existing project"
    echo "  inspect     Inspect existing project"
    echo ""
    exit 1
}
mapic_api_project () {
    test -z "$3" && mapic_api_project_usage
    case "$3" in
        create)     mapic_api_project_create "$@";;
        delete)     mapic_api_project_delete "$@";;
        inspect)    mapic_api_project_inspect "$@";;
        *)          mapic_api_project_usage;
    esac 
}
mapic_api_project_create_usage () {
    echo ""
    echo "Usage: mapic api project create [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --name NAME    Name of project"
    echo "  --public       Make project public"
    echo "  --private      Make project private"
    echo "  --help         This help screen"
    echo ""
    exit 0
}
mapic_api_project_create () {

    ARGS=$@
    PUBLIC=false
    while [ ! $# -eq 0 ]
    do
        case "$1" in
            --name)
                NAME=$2
                ;;
            --public)
                PUBLIC=true
                ;;
            --private)
                PUBLIC=false
                ;;
            --help)
                mapic_api_project_create_usage
                exit 0
                ;;
        esac
        shift
    done

    # test login
    _test_api_login quiet

    # set env
    MAPIC_API_PROJECT_CREATE_NAME=$NAME
    MAPIC_API_PROJECT_CREATE_PUBLIC=$PUBLIC

    # ensure name
    test -z $MAPIC_API_PROJECT_CREATE_NAME && m config prompt MAPIC_API_PROJECT_CREATE_NAME "Please enter a project name"

    # create project
    _api_create_project

}

_api_create_project () {

    # create project
    RESULT=$(docker run -it --env-file $MAPIC_ENV_FILE -e "MAPIC_API_PROJECT_CREATE_NAME=$MAPIC_API_PROJECT_CREATE_NAME" -e "MAPIC_API_PROJECT_CREATE_PUBLIC=$MAPIC_API_PROJECT_CREATE_PUBLIC" --volume $MAPIC_CLI_FOLDER/api:/tmp -w /tmp node:6 node create-project.js)
   
    # get exit code
    EXITCODE=$?

    if [ $EXITCODE = 1 ]; then
        echo "Something went wrong: $RESULT"
        exit 1
    fi

    if [ $EXITCODE = 0 ]; then
        echo "Created project!"
        # _write_env MAPIC_PROJECT_CREATE_ID $RESULT
        _write_env MAPIC_API_PROJECT_CREATE_ID $RESULT
    fi
}


mapic_api_upload_usage () {
    echo ""
    echo "Usage: mapic api upload DATASET [OPTIONS]"
    echo ""
    echo "Dataset:"
    echo "  Absolute path of dataset to upload"
    echo ""
    echo "Options:"
    echo "  --project-id        Project id"
    echo ""
    exit 1 
}
mapic_api_upload () {
    test -z "$3" && mapic_api_upload_usage

    MAPIC_API_UPLOAD_DATASET=$(realpath "$3")
    MAPIC_API_UPLOAD_PROJECT=$MAPIC_API_PROJECT_CREATE_ID
    API_DIR=$MAPIC_CLI_FOLDER/api

    while [ ! $# -eq 0 ]
    do
        case "$1" in
            --project)
                MAPIC_API_UPLOAD_PROJECT=$2
                ;;
            --dataset)
                MAPIC_API_UPLOAD_DATASET=$(realpath "$2")
                ;;
        esac
        shift
    done

    # remember 
    _write_env MAPIC_API_UPLOAD_DATASET $MAPIC_API_UPLOAD_DATASET
    _write_env MAPIC_API_UPLOAD_PROJECT $MAPIC_API_UPLOAD_PROJECT

    # test login
    _test_api_login

    # install npm packages
    docker run -it --rm --volume $API_DIR:/tmp --workdir /tmp node:slim npm install --silent >/dev/null 2>&1

    # upload data
    docker run -it --rm --name mapic_uploader --volume $API_DIR:/tmp --volume $MAPIC_API_UPLOAD_DATASET:/mapic_upload$MAPIC_API_UPLOAD_DATASET --workdir /tmp --env-file $MAPIC_ENV_FILE node:slim node upload-data.js

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
    echo "This command will promote user to SUPERADMIN,"
    echo "giving access to all projects and data."
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
    docker exec -e MAPIC_DEBUG=$MAPIC_DEBUG $C  ${@:3}
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
        create)     _create_ssl;;
        scan)       _scan_ssl;;
        *)          mapic_ssl_usage;
    esac 
}
_create_ssl () {

    # ensure domain
    _ensure_mapic_domain

    # ensure email
    _ensure_user_email

    # create certs
    if [ $MAPIC_DOMAIN = "localhost" ]; then
        _create_ssl_localhost
    else 
        _create_ssl_public_domain
    fi

    # create dhparams
    _create_dhparams
}
_create_ssl_localhost () {
    docker run --rm -it --name openssl \
        -v $MAPIC_CONFIG_FOLDER:/certs \
        wallies/openssl \
        openssl req -x509 -nodes \
        -days 365 \
        -newkey rsa:2048 \
        -keyout /certs/privkey.key \
        -out /certs/fullchain.pem \
        -subj "/C=NO/ST=Oslo/L=Oslo/O=Mapic/OU=IT Department/CN=localhost" || abort "Failed to create SSL certificates"

}
_create_ssl_public_domain () {
    # certbot-auto
    cd $MAPIC_CLI_FOLDER/ssl
    certbot certonly \
        --standalone \
        --agree-tos \
        --email "$MAPIC_USER_EMAIL" \
        --hsts \
        --force-renew \
        --non-interactive \
        --domain "$MAPIC_DOMAIN"           \
        --domain proxy-a-"$MAPIC_DOMAIN"   \
        --domain proxy-b-"$MAPIC_DOMAIN"   \
        --domain proxy-c-"$MAPIC_DOMAIN"   \
        --domain proxy-d-"$MAPIC_DOMAIN"   \
        --domain tiles-a-"$MAPIC_DOMAIN"   \
        --domain tiles-b-"$MAPIC_DOMAIN"   \
        --domain tiles-c-"$MAPIC_DOMAIN"   \
        --domain tiles-d-"$MAPIC_DOMAIN"   \
        --domain  grid-a-"$MAPIC_DOMAIN"   \
        --domain  grid-b-"$MAPIC_DOMAIN"   \
        --domain  grid-c-"$MAPIC_DOMAIN"   \
        --domain  grid-d-"$MAPIC_DOMAIN"   || abort
       
    echo "Created certificates, moving them to config folder ($MAPIC_CONFIG_FOLDER)"
    cp /etc/letsencrypt/live/"$MAPIC_DOMAIN"/privkey.pem $MAPIC_CONFIG_FOLDER/privkey.key
    cp /etc/letsencrypt/live/"$MAPIC_DOMAIN"/fullchain.pem $MAPIC_CONFIG_FOLDER/fullchain.pem
}
_create_dhparams () {
    if  [[ -f "$MAPIC_CONFIG_FOLDER/dhparams.pem" ]]; then
        echo 'Using pre-existing Strong Diffie-Hellmann Group'
    else
        echo 'Creating Strong Diffie-Hellmann Group'
        docker run \
            --rm \
            -e "RANDFILE=.rnd" \
            -it \
            --name openssl \
            -v $MAPIC_CONFIG_FOLDER:/certs \
            wallies/openssl \
            openssl dhparam -out /certs/dhparams.pem 2048 || abort "Failed to create Diffie-Hellmann group"
    fi
}
_scan_ssl () {
    if [ $MAPIC_DOMAIN = "localhost" ]; then
        echo "SSLLabs scan not supported on localhost."
        exit 1
    fi
    cd $MAPIC_CLI_FOLDER/ssl
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
        create)     _set_dns;;
        *)          mapic_dns_usage;
    esac 
}
_set_dns () {
    cd $MAPIC_CLI_FOLDER/dns
    WDR=/usr/src/app
    docker run -it --rm -p 80:80 -p 443:443 --env-file $MAPIC_ENV_FILE --volume $PWD:$WDR -w $WDR node:6 sh entrypoint.sh
}

#    _____/ /_____ _/ /___  _______
#   / ___/ __/ __ `/ __/ / / / ___/
#  (__  ) /_/ /_/ / /_/ /_/ (__  ) 
# /____/\__/\__,_/\__/\__,_/____/  
mapic_status () {
    
    # show stack status
    _print_stack

    # show config
    _print_config
}
_print_stack () {
    echo ""
    ecco 6 "docker node ls:"
    docker node ls
    echo ""
    ecco 6 "docker stack ps mapic:"
    docker stack ps mapic
    echo ""
    ecco 6 "docker stack services mapic:"
    docker stack services mapic
    echo ""
    ecco 6 "docker ps"
    docker ps

    # print more debug info for travis build
    if [[ "$TRAVIS" == "true" ]]; then
        echo 'docker inspect $(docker stack services mapic -q):'
        docker stack services mapic -q
        docker inspect $(docker stack services mapic -q)
    fi
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
    echo "  js          Run all Mapic.js tests"
    echo ""
    exit 1   
}
mapic_test () {
    test -z "$2" && mapic_test_usage
    case "$2" in
        all)        mapic_test_all;;
        engine)     mapic_test_engine;;
        mile)       mapic_test_mile;;
        js)         mapic_test_js;;
        *)          mapic_test_usage;;
    esac 
}
mapic_test_all () {
    mapic_test_engine
    mapic_test_mile
    mapic_test_js
}
mapic_test_engine () {
    echo "Testing Mapic Engine"
    mapic_test_ensure_data_engine
    mapic run engine npm test || mapic_test_failed "$@"
    exit 0;
}
mapic_test_mile () {
    echo "Testing Mapic Mile"
    mapic_test_ensure_data_mile
    mapic run mile npm test || mapic_test_failed "$@"
    exit 0;
}
mapic_test_js () {
    echo "Testing Mapic.js"
    mapic_test_ensure_data_mapicjs
    mapic run engine bash public/test/test.sh || mapic_test_failed "$@"
    exit 0;
}
mapic_test_failed () {
    echo "Some tests failed: $@";
    exit 1;
}
mapic_test_ensure_data_mile () {
    cd $MAPIC_ROOT_FOLDER/mile/test
    mapic_test_download_data
}
mapic_test_ensure_data_engine () {
    cd $MAPIC_ROOT_FOLDER/engine/test
    mapic_test_download_data
}
mapic_test_ensure_data_mapicjs () {
    cd $MAPIC_ROOT_FOLDER/engine/test
    mapic_test_download_data
}
mapic_test_download_data () {
    # ensure open-data is downloaded
    if [ ! -d "open-data" ]; then
        echo "Downloading test data..."
        git clone https://github.com/mapic/open-data.git
    fi
}

mapic_bench () {
    echo ""
    ecco 5 "Mapic Benchmark Tests"
    echo ""
    echo "Benchmarking Mile tileserver replication..."
    echo ""

    # run benchmark
    mapic_bench_run
}

mapic_bench_run () {

    # get info on replicas
    DOCKER_INFO=$(docker stack services mapic | grep mapic_mile |  head -c -30 | tail -c +21 | tr -d '\n')
    
    echo "$get"
    echo "Starting benchmark"
    echo "$DOCKER_INFO"

    _write_env MAPIC_BENCHMARK_TILES 300

    BENCHMARK=$(docker run -it --rm --env-file $MAPIC_ENV_FILE --volume $MAPIC_CLI_FOLDER/api:/tmp -w /tmp node:6 node benchmark.js)
    
    echo ""
    echo "Benchmark (ms): $BENCHMARK"
    echo ""
}
mapic_scale_mile () {
    
    echo "Scaling to $1 replicas of mapic/mile"

    # scale services
    docker service scale mapic_mile=$1

    echo "Please allow a few minutes for correct number of replicas to become active (especially when scaling down)."
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
mapic_viz () {
    test -z "$2" && mapic_viz_usage
    case "$2" in
        start)      mapic_viz_start;;
        stop)       mapic_viz_stop;;
        status)     mapic_viz_status;;
        *)          mapic_viz_usage;;
    esac 
}
mapic_viz_usage () {
    echo ""
    echo "Usage: mapic viz start|stop|status"
    echo ""
    exit 1
}
mapic_viz_start () {
    docker service create \
        --name=swarm-visualizer \
        --publish=8080:8080/tcp \
        --detach \
        --constraint=node.labels.domain_node==true \
        --mount=type=bind,src=/var/run/docker.sock,dst=/var/run/docker.sock \
        mapic/swarm-visualizer
}
mapic_viz_stop () {
    echo "Stopping Swarm Visualizer..."
    docker service rm swarm-visualizer
}
mapic_tor () {
    test -z "$2" && mapic_tor_usage
    case "$2" in
        start)      mapic_tor_start;;
        stop)       mapic_tor_stop;;
        status)     mapic_tor_status;;
        *)          mapic_tor_usage;;
    esac 
}
mapic_tor_usage () {
    mapic_tor_status
}
mapic_tor_status () {
    echo ""
    docker service ps tor-relay
}
mapic_tor_start () {
    echo "Starting Tor relays..."
    docker pull mapic/tor-relay:latest >/dev/null 2>&1
    docker service create --mode global --detach -p 9001:9001 --name tor-relay mapic/tor-relay:latest
}
mapic_tor_stop () {
    echo "Stopping Tor relays..."
    docker service rm tor-relay
}


#   ___  ____  / /________  ______  ____  (_)___  / /_
#  / _ \/ __ \/ __/ ___/ / / / __ \/ __ \/ / __ \/ __/
# /  __/ / / / /_/ /  / /_/ / /_/ / /_/ / / / / / /_  
# \___/_/ /_/\__/_/   \__, / .___/\____/_/_/ /_/\__/  
#                    /____/_/                         
mapic_cli "$@"
