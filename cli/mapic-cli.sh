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

MAPIC_CLI_VERSION=19.08.15

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
    echo "  init                Initialize Mapic"
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
    echo "  pull                Pull latest Mapic repositories"
    echo "  node                Manage Docker nodes"
    echo "  reload              Reload Docker service"
    echo ""
    echo "API commands:"
    echo "  api                 Help screen for Mapic API"
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
    echo "  schedule            Schedule AWS instances"
    echo "  delayed             Execute job after n seconds of sleep"
    echo ""

    # print config
    _print_config
    mapic_api_display_config
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

    # ping
    _ping_mapic_command $@
    
    case "$1" in

        # documented API
        install)    mapic_install "$@";;
        init)       mapic_init "$@";;
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
        edit)       mapic_edit "$@";;
        version)    mapic_version "$@";;
        info)       mapic_info "$@";;
        tor)        mapic_tor "$@";;
        viz)        mapic_viz "$@";;
        scale)      mapic_scale "$@";;
        bench)      mapic_bench "$@";;
        pull)       mapic_pull "$@";;
        node)       mapic_node "$@";;
        schedule)   mapic_schedule "$@";;
        delayed)    mapic_delayed "$@";;
        reload)     mapic_reload "$@";;
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

        # ask if only cli install needed
        if [ "$TRAVIS" != "true" ]; then
            echo "Installing Mapic CLI only..."
            MAPIC_CLI_INSTALL_ONLY=true
        fi

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

        # set home folder
        MAPIC_HOME=$HOME

        # cp default env files
        cp $MAPIC_CLI_FOLDER/.mapic.default.env $MAPIC_ENV_FILE
        cp $MAPIC_CLI_FOLDER/.mapic.default.aws.env $MAPIC_AWS_ENV_FILE 

        # determine public ip
        _determine_ip
        
        # create symlink for global mapic
        _create_mapic_symlink

        # install dependencies
        _install_dependencies

        # ensure docker is installed
        mapic_install_docker

        # unless only CLI mode
        if [ "$MAPIC_CLI_INSTALL_ONLY" != "true" ]; then

            # update submodules
            _init_submodules

            # ensure editor
            _ensure_editor

        fi

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
        _write_env MAPIC_HOME $MAPIC_HOME
        _write_env TRAVIS $TRAVIS

        # ping
        _ping_cli_install

    fi

    # set which folder mapic was executed from
    MAPIC_CLI_EXECUTED_FROM=$PWD

    # source env file
    set -o allexport
    source $MAPIC_ENV_FILE
    # source $MAPIC_AWS_ENV_FILE
    source $MAPIC_COLOR_FILE

    # mark [debug mode]
    test "$MAPIC_DEBUG" == "true" && ecco 82 "[debug mode]"

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
    MAPIC_IP=$(curl -sSL ipinfo.io/ip)

    if [[ "$TRAVIS" == "true" ]]; then
        MAPIC_IP=127.0.0.1
    fi
}
mapic_init_usage () {
    echo ""
    echo "Usage: mapic init COMMAND"
    echo ""
    echo "Commands:"
    echo "  manager     Initialize Mapic as a manager node"
    echo "  worker      Initialize Mapic as a worker node"
    echo ""
    exit 0
}
mapic_init () {
    test -z "$2" && mapic_init_usage
    case "$2" in
        manager)    mapic_init_manager "$@";;
        worker)     mapic_init_worker "$@";;
        *)          mapic_init_usage;;
    esac 
}
mapic_init_manager () {
    echo "manager init"
    # mapic_install_docker

    # swarm mode
    # exp mode
}
mapic_init_worker () {
    echo "worker init"
    # mapic_install_docker

    # swarm mode
    # exp mode
}
_init_submodules () {
    cd $MAPIC_ROOT_FOLDER
    ecco 4 "Initializing submodules..."
    git submodule init >/dev/null 2>&1
    git submodule update --remote >/dev/null 2>&1
    git remote set-url origin git@github.com:mapic/mapic.git >/dev/null 2>&1
}
_install_dependencies () {

    # install dependencies on linux
    if [[ "$MAPIC_HOST_OS" == "linux" ]]; then
        _install_linux_tools
    fi

    # install dependencies on osx
    if [[ "$MAPIC_HOST_OS" == "osx" ]]; then
        _install_osx_tools
    fi

}
mapic_pull () {

    echo ""
    echo "Pulling latest repositories..."

    echo ""
    ecco 4 "mapic/mapic"
    cd $MAPIC_ROOT_FOLDER
    git pull origin master --rebase

    echo ""
    ecco 4 "mapic/mile"
    cd $MAPIC_ROOT_FOLDER/mile
    git pull origin master --rebase

    echo ""
    ecco 4 "mapic/engine"
    cd $MAPIC_ROOT_FOLDER/engine
    git pull origin master --rebase

    echo ""
    ecco 4 "mapic/mapic.js"
    cd $MAPIC_ROOT_FOLDER/mapic.js
    git pull origin master --rebase

    echo ""
    ecco 4 "git status:"
    cd $MAPIC_ROOT_FOLDER
    git status
    echo ""

}
_install_linux_tools () {

    # realpath
    REALPATH=$(which realpath)
    if [ -z $REALPATH ]; then
        echo "Installing realpath..."
        apt-get update -y >/dev/null 2>&1
        apt-get install -y realpath >/dev/null 2>&1
    fi

    # git
    GITPATH=$(which git)
    if [ -z $GITPATH ]; then
        echo "Installing git..."
        apt-get update -y >/dev/null 2>&1
        apt-get install -y git >/dev/null 2>&1
    fi

    # rsub
    RSUB=$(which rsub)
    if [ -z $RSUB ]; then
        cp $MAPIC_CLI_FOLDER/install/rsub /usr/local/bin/rsub
        chmod +x /usr/local/bin/rsub
    fi

}
_install_certbot () {
    # certbot
    CERTBOTPATH=$(which certbot)
    if [ -z $CERTBOTPATH ]; then
        # todo: incorporate with nginx so refresh can be done on running server
        # perhaps put in docker image
        echo "Installing Let's Encrypt..."
        sudo apt-get update -y >/dev/null 2>&1
        sudo apt-get install -y --force-yes software-properties-common >/dev/null 2>&1
        sudo add-apt-repository -y ppa:certbot/certbot >/dev/null 2>&1
        sudo apt-get update -y >/dev/null 2>&1
        sudo apt-get install -y --force-yes python-certbot-nginx >/dev/null 2>&1
    fi
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
    if [ -z "$SEDV" ]; then
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
    if [ -z "$GREP" ]; then
        if [ -z $BREW ]; then
            echo "Brew required for OSX. Please install 'grep' manually:"
            echo "brew install grep --with-default-names"
        else
            echo "Installing grep..."
            brew update >/dev/null 2>&1
            brew install grep --with-default-names >/dev/null 2>&1
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
            brew update >/dev/null 2>&1
            brew install coreutils >/dev/null 2>&1
            REALPATHV=$(realpath --version | grep realpath)
            echo "$REALPATHV installed"
        fi
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
mapic_node () {
    echo ""
    echo "Manage Docker nodes"
    echo ""
    echo "  Add label to Docker nodes like so:"
    echo ""
    echo "      docker node update --add-label mile=true vycxdgqtd8pzqa40v85mw4rpu"
    echo ""
    echo "    where last string is node-id. Node-id is found with 'docker node ls'"
    echo ""  
    echo "  Designate nodes in stack.yml with node.labels.LABEL == LABEL_VALUE to target respective nodes."
    echo ""
    echo "  See cli/config/stack.yml for more."
}
mapic_schedule_usage () {
    echo ""
    echo "Usage: mapic schedule COMMAND"
    echo ""
    echo "Commands:"
    echo "  day          Schedule up day-time instances"
    echo "  night        Schedule down to night-time (and weekend) only instances"
    echo "  register     Register cronjob"
    echo ""
    exit 1
}
mapic_schedule () {
    test -z "$2" && mapic_schedule_usage
    case "$2" in
        day)        mapic_schedule_day "$@";;
        night)      mapic_schedule_night "$@";;
        register)   mapic_schedule_register "$@";;
        *)          mapic_schedule_usage;;
    esac 
}
mapic_schedule_day () {
    cd $MAPIC_CLI_FOLDER/management
    bash ec2-schedule-day.sh
}
mapic_schedule_night () {
    cd $MAPIC_CLI_FOLDER/management
    bash ec2-schedule-night.sh
}
mapic_schedule_register () {
    cd $MAPIC_CLI_FOLDER/management
    bash ec2-schedule-register.sh
}
mapic_delayed_usage () {
    echo ""
    echo "Usage: mapic delayed DELAY COMMAND"
    echo ""
    echo "Options:"
    echo "  DELAY        Seconds delay before execution"
    echo "  COMMAND      Any bash compatible command"
    echo ""
    echo "Example: mapic delayed 60 mapic scale mile 3"
    exit 1
}
mapic_delayed () {
    test -z "$2" && mapic_schedule_usage
    test -z "$3" && mapic_schedule_usage

    # sleep n seconds
    echo "Delaying execution of [${@:3}] for $2 seconds..."
    sleep $2

    # execute
    ${@:3}
}
mapic_reload_usage (){
    echo ""
    echo "Usage: mapic reload SERVICE"
    echo ""
    echo "Services:"
    echo "  mile        Update mile services"
    echo ""
    exit 1
}
mapic_reload () {
    test -z "$2" && mapic_reload_usage
    case "$2" in
        mile)       mapic_reload_mile "$@";;
        nginx)      mapic_reload_nginx "$@";;
        engine)     mapic_reload_engine "$@";;
        *)          mapic_reload_usage;;
    esac 
}
mapic_reload_mile () {
    echo "Reloading mile services..."
    docker service update mapic_mile --force --detach=true --update-parallelism=0
}
mapic_reload_nginx () {
    echo "Reloading nginx service..."
    docker service update mapic_nginx --force --detach=true --update-parallelism=0
}
mapic_reload_nginx () {
    echo "Reloading engine service..."
    docker service update mapic_engine --force --detach=true --update-parallelism=0
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
    test -z "$2" && mapic_travis_usage
    case "$2" in
        install)    mapic_travis_install "$@";;
        start)      mapic_travis_start "$@";;
        stack)      mapic_travis_stack "$@";;
        *)          mapic_travis_usage;;
    esac 
}
mapic_travis_install () {
    # print version
    mapic_version
}
mapic_travis_stack () {
    cd $MAPIC_CLI_FOLDER/config
    cp stack.travis.yml stack.yml
}
mapic_travis_start () {
    cat $MAPIC_CLI_FOLDER/config/stack.yml
    mapic_up
    mapic_status
    mapic_logs
    mapic_travis_ready_check
    echo "All done with ready checks..."
    sleep 240
}
mapic_travis_ready_check () {
    mapic_status
    PREPARING=$(docker stack ps mapic | grep "Preparing")
    if [[ "$PREPARING" == "" ]]; then
        echo "Mapic is running and ready..."
    else
        echo "Still preparing images..."
        sleep 10
        mapic_travis_ready_check
    fi
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
mapic_scale_usage () {
    echo ""
    echo "Usage: mapic scale SERVICE NODES"
    echo ""
    echo "  eg. 'mapic scale mile 4' will scale Mile tileserver to four nodes."
    echo ""
    echo "Services:"
    echo "  mile        Mapic tileserver"
    echo ""
    exit 0
}
mapic_scale () {
    test -z "$2" && mapic_scale_usage
    case "$2" in
        mile)       _scale_mile "$@";;
        *)          mapic_scale_usage;;
    esac 
}
_scale_mile () {
    
    SCALE=$3
    if [[ "$3" == "auto" ]]; then
        # autoscale to x replicas per node for all nodes minus one
        MILE_REPLICAS_PER_NODE=2
        NODES=$(docker node ls | grep Ready | wc -l)
        SCALE=$((($NODES - 1) * $MILE_REPLICAS_PER_NODE))
    fi
    
    # scale services
    docker service scale mapic_mile=$SCALE > /dev/null 2>&1
    echo "Scaling mapic/mile to $SCALE nodes...done!"
}
_ping_cli_install () {
    cd $MAPIC_CLI_FOLDER/install
    bash ping.sh "CLI installed @ $MAPIC_IP (CLI version: $MAPIC_CLI_VERSION)"
}
_ping_mapic_install () {
    cd $MAPIC_CLI_FOLDER/install
    bash ping.sh "Mapic installed @ $MAPIC_DOMAIN @ $MAPIC_IP" &
}
_ping_mapic_command () {
    MCMD="mapic $@"
    cd $MAPIC_CLI_FOLDER/install
    if [ -z "$TRAVIS" ]; then
        bash ping.sh "Mapic CLI command @ $MAPIC_DOMAIN @ $MAPIC_IP: \`$MCMD\`" &
    else 
        bash ping.sh "\`[travis]\` $MAPIC_DOMAIN @ $MAPIC_IP: \`$MCMD\`" &
    fi
}
mapic_configure_usage () {
    echo ""
    echo "Usage: mapic configure [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  manager     Configure Mapic as a manager node"
    echo "  stack       Configure Docker Swarm stack"
    echo "  aws         Configure Amazon AWS integration"
    echo ""
    exit 0
}
mapic_configure () {
    test -z "$2" && mapic_configure_usage
    case "$2" in
        manager)    _mapic_configure_manager "$@";;
        stack)      _mapic_configure_stack "$@";;
        aws)        _mapic_configure_aws "$@";;
        *)          mapic_configure_usage;;
    esac 
}
_mapic_configure_manager () {
 
    # domain
    _ensure_mapic_domain

    # email
    _ensure_user_email

    # aws
    _ensure_aws_creds

    # dns
    read -p "Do you want to create DNS entries for $MAPIC_DOMAIN?  (y/n)" -n 1 -r
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "Creating DNS entries..."
        m dns create
    fi

    # ssl
    m ssl create

    # done
    ecco 5 "Mapic is configured!"

    # ping
    _ping_mapic_install

    exit 0
}
_mapic_configure_stack () {
    echo "todo"
}
_mapic_configure_aws () {
    _ensure_aws_creds
    # todo: test config
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
mapic_config_set_usage () {
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
mapic_ps () {
    docker ps 
    exit 0
}
_test_config () {

    # ensure domain is set
    _ensure_mapic_domain

    # ensure mongo auth
    if [ -z $MAPIC_MONGO_AUTH ]; then
        _set_mongo_auth
    fi

    # ensure redis auth
    if [ -z $MAPIC_REDIS_AUTH  ]; then
        _set_redis_auth
    fi

}
mapic_up () {

    # test sanity of config
    _test_config

    # start mapic stack
    STACK=$MAPIC_CONFIG_FOLDER/stack.yml
    docker stack deploy --compose-file=$STACK mapic 

    # feedback
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
mapic_logs_container_usage () {
    echo "22"
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
    echo "ml"
    if [[ -n "$2" ]]; then
        case "$2" in
            mongo)          docker service logs -f mapic_mongo;;
            mile)           docker service logs -f mapic_mile;;
            postgis)        docker service logs -f mapic_postgis;;
            nginx)          docker service logs -f mapic_nginx;;
            engine)         docker service logs -f mapic_engine;;
            redis)          docker service logs -f mapic_redis;;
            cache)          docker service logs -f mapic_cache;;
            *)              mapic_logs_container_usage;
        esac 
        exit
    fi
    if [[ "$TRAVIS" == "true" ]]; then
        echo "travis"
        # stream logs
        docker service logs -f mapic_mile         &
        docker service logs -f mapic_postgis      &
        docker service logs -f mapic_mongo        &
        docker service logs -f mapic_nginx        &
        docker service logs -f mapic_engine       &
        docker service logs -f mapic_redis        &
    else
        # print current logs
        echo "else"
        docker service logs mapic_redis
        docker service logs mapic_mongo      
        docker service logs mapic_nginx      
        docker service logs mapic_postgis    
        docker service logs mapic_mile       
        docker service logs mapic_engine     
    fi
}
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
    test -z $1 && mapic_enter_usage
    test -z $2 && mapic_enter_usage
    case "$2" in
        db)         mapic_enter_db "$@";;
        *)          mapic_enter_container "$@";;
    esac 
}
mapic_enter_container () {
    C=$(docker ps -q --filter name=$2)
    test -z "$C" && mapic_enter_usage_missing_container "$@"
    docker exec -it $C bash
}
mapic_enter_db () {
    C=$(docker ps -q --filter name=engine)
    echo "Entering PostGIS database. Do \quit to exit."
    echo ""
    docker exec -it $C bash scripts/postgis/enter_db.sh
}
mapic_enter_usage_missing_container () {
    echo "No container matched filter: $2" 
    exit 1
}
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
    MAPIC_REDIS_AUTH=$(docker run --rm mapic/tools pwgen 40)
    _write_env MAPIC_REDIS_AUTH $MAPIC_REDIS_AUTH
    echo "Updated Redis authentication"
}
_set_mongo_auth () {
    MAPIC_MONGO_AUTH=$(docker run --rm mapic/tools pwgen 40)
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
    LSB=$(which lsb_release)
    if [[ "$LSB" == "" ]]; then
        mapic_install_jq_unsupported
    else 
        DISTRO=$(lsb_release -si)
        case "$DISTRO" in
            Ubuntu)     mapic_install_jq_ubuntu "$@";;
            *)          mapic_install_jq_unsupported;;
        esac 
    fi
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
    LSB=$(which lsb_release)
    if [[ "$LSB" == "" ]]; then
        mapic_install_docker_unsupported
    else 
        DISTRO=$(lsb_release -si)
        case "$DISTRO" in
            Ubuntu)     mapic_install_docker_ubuntu "$@";;
            *)          mapic_install_docker_unsupported;;
        esac 
    fi
}
mapic_install_docker_unsupported () {
    echo ""
    echo "Unable to install Docker automatically."
    echo ""
    echo "See https://docs.docker.com/engine/installation/"
    echo ""
    # exit 0
}
mapic_install_docker_ubuntu () {

    # install/update docker
    _install_docker_ubuntu

    if [ "$MAPIC_CLI_INSTALL_ONLY" != "true" ]; then

        # use experimental mode
        _set_experimental_docker

        # init swarm
        _init_docker_swarm # todo: init swarm only if manager
    
    fi
    
}
_install_docker_ubuntu () {
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
mapic_api_usage () {
    echo ""
    echo "Usage: mapic api [COMMAND]"
    echo ""
    echo "Commands:"
    echo "  login           Login to a Mapic API"
    echo "  user            Show and edit users"
    echo "  upload          Upload data"
    echo "  project         Handle projects"
    echo "  layer           Handle layers"
    echo ""
    echo "All commands have their own help screens."
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
        layer)      mapic_api_layer "$@";;
        test)       mapic_api_test "$@";;
        *)          mapic_api_usage;
    esac 
}
mapic_api_login_usage () {
    echo ""
    echo "Usage: mapic api login OPTIONS"
    echo ""
    echo "Options:"
    echo "  --domain    API domain to use, eg. maps.mapic.io"
    echo "  --email     The user email"
    echo "  --password  The user password"
    echo ""
    echo "Example: mapic api login --domain maps.mapic.io --email test@mapic.io --password batteryhorsestaple"
    echo ""
    exit 1
}
mapic_api_login () {
    test -z "$3" && mapic_api_login_usage
   
    # options
    while [ ! $# -eq 0 ]
    do
        case "$1" in
            --domain)
                MAPIC_API_DOMAIN=$2
                ;;
            --email)
                MAPIC_API_USERNAME=$2
                ;;
            --pass | --password)
                MAPIC_API_AUTH=$2
                ;;
            --help)
                mapic_api_login_usage
                ;;
        esac
        shift
    done
    
    _write_env MAPIC_API_DOMAIN $MAPIC_API_DOMAIN
    _write_env MAPIC_API_USERNAME $MAPIC_API_USERNAME
    _write_env MAPIC_API_AUTH $MAPIC_API_AUTH

    # todo: 
    _test_api_login

}
mapic_api_display_config () {
    echo ""
    echo "Mapic API credentials:"
    echo "  API domain:         $MAPIC_API_DOMAIN"
    echo "  Email:              $MAPIC_API_USERNAME"
    echo "  Password:           $MAPIC_API_AUTH"
    echo ""
}
_test_api_login () {
    if [ "$1" = "quiet" ]; then
        QUIET=true
    fi
    docker run -it --rm --env-file $MAPIC_ENV_FILE --volume $MAPIC_CLI_FOLDER/api:/wd -w /wd node:slim node test-login.js >/dev/null 2>&1
    EXITCODE=$?
    if [ $EXITCODE = 1 ]; then
        echo ""
        ecco 2 "Failed to login to Mapic with the following credentials:"
        mapic_api_display_config
        exit 1
    elif [ $EXITCODE = 0 ]; then
        
        # test -z $QUIET && ecco 4 "Successfully authenticated to Mapic API @ $MAPIC_API_DOMAIN as $MAPIC_API_USERNAME"
        if [ -z $QUIET ]; then
            ecco 4 "Successfully authenticated to Mapic API!"
            mapic_api_display_config
        fi

    fi
}
mapic_api_layer_usage () {
    echo ""
    echo "Usage: mapic api layer COMMAND"
    echo ""
    echo "Commands:"
    echo "  create      Create layer"
    echo "  delete      Delete layer"
    echo "  inspect     Inspect layer"
    echo "  update      Update layer"
    echo ""
    echo "  mask        Work with layer masks"
    echo ""
    echo "Example: mapic api layer update --help"
    echo ""
    exit 1
}
mapic_api_layer () {
    test -z "$3" && mapic_api_layer_usage
    case "$3" in
        mask)       mapic_api_layer_mask "$@";;
        create)     mapic_api_layer_create "$@";;
        delete)     mapic_api_layer_delete "$@";;
        inspect)    mapic_api_layer_inspect "$@";;
        update)     mapic_api_layer_update "$@";;
        list)       mapic_api_layer_list "$@";;
        *)          mapic_api_layer_usage;
    esac 
}
mapic_api_layer_mask_usage () {
    echo ""
    echo "Usage: mapic api layer mask create"
    echo ""
    echo "Commands:"
    echo "  create      Create mask"
    echo "  update      Update mask"
    echo "  delete      Delete mask"
    echo ""
    exit 1
}
mapic_api_layer_mask () {
    test -z "$4" && mapic_api_layer_mask_usage
    case "$4" in
        create)       mapic_api_layer_mask_create "$@";;
        update)       mapic_api_layer_mask_update "$@";;
        *)            mapic_api_layer_mask_usage;
    esac 
}
mapic_api_layer_mask_create_usage () {
    echo ""
    echo "Usage: mapic api layer mask create OPTIONS"
    echo ""
    echo "Options:"
    echo "  --layer-id                Mask will be added to this Layer"
    echo "  --verbose                 Verbose output. Without this flag, returns mask_id only (useful for scripting)."
    echo ""
    exit 1
}
mapic_api_layer_mask_create () {
    test -z "$5" && mapic_api_layer_mask_create_usage

    MAPIC_API_LAYER_MASK_CREATE_LAYER_ID=
    MAPIC_API_VERBOSE=false
    while [ ! $# -eq 0 ]
    do
        case "$1" in
            --layer-id)
                MAPIC_API_LAYER_MASK_CREATE_LAYER_ID=$2
                ;;
            --verbose)
                MAPIC_API_VERBOSE=true
                ;;
        esac
        shift
    done

    # create empty layer mask
    cd $MAPIC_CLI_FOLDER/api 
    docker run -v "$PWD":/wd -w /wd \
        --env-file $MAPIC_ENV_FILE \
        -e "MAPIC_API_LAYER_MASK_CREATE_LAYER_ID=$MAPIC_API_LAYER_MASK_CREATE_LAYER_ID" \
        -e "MAPIC_API_VERBOSE=$MAPIC_API_VERBOSE" \
        node:slim node api.create-empty-layer-mask.js

}
mapic_api_layer_mask_update_usage () {
    echo ""
    echo "Usage: mapic api layer mask update OPTIONS"
    echo ""
    echo "Options:"
    echo "  --layer-id                  Layer which contains mask"
    echo "  --mask-id                   Mask to update"
    echo "  --mask-geojson              Absolute path to GeoJSON file with mask geometry"
    echo "  --mask-json                 Absolute path to JSON file with mask data"
    echo "  --mask-title                Give your mask a name"
    echo "  --verbose                   Verbose output. Without this flag, returns mask_id only (useful for scripting)."
    echo ""
    exit 1
}
mapic_api_layer_mask_update () {
    test -z "$5" && mapic_api_layer_mask_update_usage

    MAPIC_API_LAYER_MASK_UPDATE_LAYER_ID=
    MAPIC_API_LAYER_MASK_UPDATE_MASK_ID=
    MAPIC_API_LAYER_MASK_UPDATE_MASK_GEOJSON=
    MAPIC_API_LAYER_MASK_UPDATE_MASK_JSON=
    MAPIC_API_LAYER_MASK_UPDATE_MASK_TITLE=
    MAPIC_API_VERBOSE=false
    while [ ! $# -eq 0 ]
    do
        case "$1" in
            --layer-id)
                MAPIC_API_LAYER_MASK_UPDATE_LAYER_ID=$2
                ;;
            --mask-id)
                MAPIC_API_LAYER_MASK_UPDATE_MASK_ID=$2
                ;;
            --mask-geojson)
                MAPIC_API_LAYER_MASK_UPDATE_MASK_GEOJSON=$2
                ;;
            --mask-json)
                MAPIC_API_LAYER_MASK_UPDATE_MASK_JSON=$2
                ;;
            --mask-title)
                MAPIC_API_LAYER_MASK_UPDATE_MASK_TITLE=$2
                ;;
            --verbose)
                MAPIC_API_VERBOSE=true
                ;;
        esac
        shift
    done

    test -z "$MAPIC_API_LAYER_MASK_UPDATE_LAYER_ID" && mapic_api_layer_mask_update_usage
    test -z "$MAPIC_API_LAYER_MASK_UPDATE_MASK_ID"  && mapic_api_layer_mask_update_usage

    # create tmp dir
    mkdir $MAPIC_CLI_FOLDER/tmp >/dev/null 2>&1

    # move files to tmp dir
    if  [[ -f "$MAPIC_API_LAYER_MASK_UPDATE_MASK_GEOJSON" ]]; then
        cp $MAPIC_API_LAYER_MASK_UPDATE_MASK_GEOJSON $MAPIC_CLI_FOLDER/tmp/mask.geojson
    fi
    if  [[ -f "$MAPIC_API_LAYER_MASK_UPDATE_MASK_JSON" ]]; then
        cp $MAPIC_API_LAYER_MASK_UPDATE_MASK_JSON $MAPIC_CLI_FOLDER/tmp/mask.json
    fi

    cd $MAPIC_CLI_FOLDER/api 
    docker run -v "$PWD":/wd -w /wd \
        -v "$MAPIC_CLI_FOLDER/tmp":/mask \
        --env-file $MAPIC_ENV_FILE \
        -e "MAPIC_API_LAYER_MASK_UPDATE_LAYER_ID=$MAPIC_API_LAYER_MASK_UPDATE_LAYER_ID" \
        -e "MAPIC_API_LAYER_MASK_UPDATE_MASK_ID=$MAPIC_API_LAYER_MASK_UPDATE_MASK_ID" \
        -e "MAPIC_API_LAYER_MASK_UPDATE_MASK_TITLE=$MAPIC_API_LAYER_MASK_UPDATE_MASK_TITLE" \
        -e "MAPIC_API_LAYER_MASK_UPDATE_MASK_GEOJSON=$MAPIC_API_LAYER_MASK_UPDATE_MASK_GEOJSON" \
        -e "MAPIC_API_LAYER_MASK_UPDATE_MASK_JSON=$MAPIC_API_LAYER_MASK_UPDATE_MASK_JSON" \
        -e "MAPIC_API_VERBOSE=$MAPIC_API_VERBOSE" \
        node:slim node api.update-mask.js

    # cleanup tmp dir
    # rm -r $MAPIC_CLI_FOLDER/tmp

}
mapic_api_layer_mask_delete () {
    echo "mapic_api_layer_mask_delete"
}
mapic_api_layer_create_usage () {
    echo ""
    echo "Usage: mapic api layer create OPTIONS"
    echo ""
    echo "Options:"
    echo "  --layer-type        scf             Only available layer type at the moment, a Snow Cover Fraction layer"
    echo "  --add-to-project    project-id      The project_id of the project which the layer will be added to" 
    echo "  --layer-title       title           Give your layer a great name." 
    echo "  --verbose                           Verbose output. Without this flag, the function will return layer_id only (useful for scripting)." 
    echo "  --layer-id          layer-id        " 
    echo ""
    exit 1
}
mapic_api_layer_create () {
    test -z "$4" && mapic_api_layer_create_usage
    cd $MAPIC_CLI_FOLDER/api 

    ARGS=$@
    MAPIC_API_LAYER_CREATE_PROJECT_ID=
    MAPIC_API_LAYER_CREATE_LAYER_TYPE=
    MAPIC_API_LAYER_CREATE_LAYER_TITLE=
    MAPIC_API_VERBOSE=false
    while [ ! $# -eq 0 ]
    do
        case "$1" in
            --layer-type)
                MAPIC_API_LAYER_CREATE_LAYER_TYPE=$2
                ;;
            --add-to-project)
                MAPIC_API_LAYER_CREATE_PROJECT_ID=$2
                ;;
            --layer-title)
                MAPIC_API_LAYER_CREATE_LAYER_TITLE=$2
                ;;
            --verbose)
                MAPIC_API_VERBOSE=true
                ;;
        esac
        shift
    done

    # ensure name
    test -z $MAPIC_API_LAYER_CREATE_PROJECT_ID && mapic_api_layer_create_usage "Missing argument for --add-to-project"
    test -z $MAPIC_API_LAYER_CREATE_LAYER_TYPE && mapic_api_layer_create_usage "Missing argument for --layer-type"

    # create layer type scf
    if [ "$MAPIC_API_LAYER_CREATE_LAYER_TYPE" == "scf" ]; then
        docker run -v "$PWD":/wd -w /wd \
            --env-file $MAPIC_ENV_FILE \
            -e "MAPIC_API_LAYER_CREATE_PROJECT_ID=$MAPIC_API_LAYER_CREATE_PROJECT_ID" \
            -e "MAPIC_API_LAYER_CREATE_LAYER_TITLE=$MAPIC_API_LAYER_CREATE_LAYER_TITLE" \
            -e "MAPIC_API_VERBOSE=$MAPIC_API_VERBOSE" \
            node:slim node api.create-cube-layer.js
    
    # unsupported layer types
    else 
        mapic_api_layer_create_usage "Unsupported layer type: $MAPIC_API_LAYER_CREATE_LAYER_TYPE"
    fi

}
mapic_api_layer_inspect () {
    echo "mapic api layer inspect"
}
mapic_api_layer_update_usage () {
    echo ""
    echo "Usage: mapic api layer update OPTIONS"
    echo ""
    echo "Options:"
    echo "  --layer-id          Layer id"
    echo "  --add-dataset       Absolute path for the dataset to upload and add to timeseries" 
    echo "  --verbose           Verbose output." 
    echo ""
    exit 1
}
mapic_api_layer_update () {
    test -z "$5" && mapic_api_layer_update_usage

    cd $MAPIC_CLI_FOLDER/api 
    
    ARGS=$@
    MAPIC_API_LAYER_UPDATE_LAYER_ID=
    MAPIC_API_LAYER_UPDATE_DATASET=
    MAPIC_API_VERBOSE=false
    while [ ! $# -eq 0 ]
    do
        case "$1" in
            --layer-id)
                MAPIC_API_LAYER_UPDATE_LAYER_ID=$2
                ;;
            --add-dataset)
                MAPIC_API_LAYER_UPDATE_DATASET=$2
                ;;
            --verbose)
                MAPIC_API_VERBOSE=true
                ;;
        esac
        shift
    done

    test -z $MAPIC_API_LAYER_UPDATE_LAYER_ID && mapic_api_layer_update_usage
    test -z $MAPIC_API_LAYER_UPDATE_DATASET  && mapic_api_layer_update_usage

    # create tmp dir
    mkdir $MAPIC_CLI_FOLDER/tmp >/dev/null 2>&1

    # move files to tmp dir
    if  [[ -f "$MAPIC_API_LAYER_UPDATE_DATASET" ]]; then
        BASENAME=$(basename $MAPIC_API_LAYER_UPDATE_DATASET)
        cp $MAPIC_API_LAYER_UPDATE_DATASET $MAPIC_CLI_FOLDER/tmp/$BASENAME >/dev/null 2>&1
    fi
    
    cd $MAPIC_CLI_FOLDER/api 
    docker run -v "$PWD":/wd -w /wd \
        -v "$MAPIC_CLI_FOLDER/tmp":/data \
        --env-file $MAPIC_ENV_FILE \
        -e "MAPIC_API_LAYER_UPDATE_LAYER_ID=$MAPIC_API_LAYER_UPDATE_LAYER_ID" \
        -e "MAPIC_API_LAYER_UPDATE_DATASET=/data/$BASENAME" \
        -e "MAPIC_API_VERBOSE=$MAPIC_API_VERBOSE" \
        node:slim node api.layer-update.js

    # cleanup tmp dir
    # rm -r $MAPIC_CLI_FOLDER/tmp

}
mapic_api_layer_list () {
    echo "mapic api layer list"
}

mapic_api_project_usage () {
    echo ""
    echo "Usage: mapic api project COMMAND"
    echo ""
    echo "Commands:"
    echo "  create      Create new project"
    echo "  delete      Delete existing project"
    echo "  inspect     Inspect existing project"
    echo "  update      Update existing project"
    echo ""
    exit 1
}
mapic_api_project () {
    test -z "$3" && mapic_api_project_usage
    case "$3" in
        create)     mapic_api_project_create "$@";;
        delete)     mapic_api_project_delete "$@";;
        inspect)    mapic_api_project_inspect "$@";;
        update)     mapic_api_project_update "$@";;
        list)       mapic_api_project_list "$@";;
        *)          mapic_api_project_usage;
    esac 
}
mapic_api_project_update () {
    echo "mapic api project update"
    echo "todo!"
    # cd $MAPIC_CLI_FOLDER/api 
    # # todo: dynamic cube IDs
    # # todo: dynamic ftp details
    # CUBE_ID=cube-4058a673-c0e0-4bad-a6ad-7e0039489540
    # docker run -v "$PWD":/wd -w /wd --env-file $MAPIC_ENV_FILE node node ftp-update-scf-cube.js $CUBE_ID
}
mapic_api_project_list () {
    cd $MAPIC_CLI_FOLDER/api
    bash list-projects.sh 
}
mapic_api_project_delete () {
    cd $MAPIC_CLI_FOLDER/api
    bash delete-project.sh "$@"
}
mapic_api_project_create_usage () {
    echo ""
    echo "Usage: mapic api project create [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --project-name      NAME                Name of project"
    echo "  --access            public | private    Make project public or private (private by default)"
    echo "  --verbose                               Verbose output. Without this flag, the function will return project_id only (useful for scripting)."
    echo "  --help                                  This help screen"
    echo ""
    exit 0
}
mapic_api_project_create () {
    test -z "$4" && mapic_api_project_create_usage

    ARGS=$@
    ACCESS=false
    VERBOSE=false
    while [ ! $# -eq 0 ]
    do
        case "$1" in
            --name)
                NAME=$2
                ;;
            --project-name)
                NAME=$2
                ;;
            --access)
                ACCESS=$2
                ;;
            --verbose)
                VERBOSE=true
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
    MAPIC_API_PROJECT_CREATE_PUBLIC=false

    if [ $ACCESS == "public" ]; then
        MAPIC_API_PROJECT_CREATE_PUBLIC=true
    fi

    # ensure name
    test -z $MAPIC_API_PROJECT_CREATE_NAME && m config prompt MAPIC_API_PROJECT_CREATE_NAME "Please enter a project name"

    # create project
    _api_create_project $VERBOSE

}
_api_create_project () {

    VERBOSE=$1

    # create project
    RESULT=$(docker run -it --env-file $MAPIC_ENV_FILE -e "MAPIC_API_PROJECT_CREATE_NAME=$MAPIC_API_PROJECT_CREATE_NAME" -e "MAPIC_API_PROJECT_CREATE_PUBLIC=$MAPIC_API_PROJECT_CREATE_PUBLIC" --volume $MAPIC_CLI_FOLDER/api:/workdir -w /workdir node:slim node api.create-project.js)
   
    # get exit code
    EXITCODE=$?

    if [ $EXITCODE = 1 ]; then
        echo "Something went wrong: $RESULT"
        exit 1
    fi

    if [ $EXITCODE = 0 ]; then

        # print success message
        if [ "$VERBOSE" = "true" ]; then
            echo "Successfully created project!"
        fi

        # print project_id
        CLEAN_RESULT="${RESULT/$'\r'/}"
        echo $CLEAN_RESULT

        # save
        _write_env MAPIC_API_PROJECT_CREATE_ID $CLEAN_RESULT
    fi
}

mapic_api_upload_cube_usage () {
    echo ""
    echo "Usage: mapic api upload_cube DATASET"
    echo ""
    echo "Dataset:"
    echo "  JSON file of cube"
    echo ""
    exit 1 
}
mapic_api_upload_usage () {
    echo ""
    echo "Deprecated. Use [mapic api layer] instead."
    # echo "Usage: mapic api upload TYPE path [OPTIONS]"
    # echo ""
    # echo "Types of upload:"
    # echo "  Dataset     Upload a dataset"
    # echo "  Snow        Upload a snow-raster timeseries"
    # echo ""
    # echo "Path:"
    # echo "  Absolute path of JSON file or dataset to upload"
    # echo ""
    # echo "Options:"
    # echo "  --project-id        Project id"
    # echo ""
    # echo "Examples:"
    # echo "  mapic api upload dataset /tmp/raster.tiff"
    # echo "  mapic api upload snow snow-project.json"
    # echo ""
    # echo "See https://github.com/mapic/mapic/wiki/Upload-Snow-Raster-Datasets for more information."
    # echo ""
    exit 1 
}
mapic_api_upload () {
    test -z "$3" && mapic_api_upload_usage
    case "$3" in
        dataset)    mapic_api_upload_dataset "$@";;
        snow)       mapic_api_upload_snow "$@";;
        *)          mapic_api_upload_usage;
    esac 
}
mapic_api_upload_snow () {
    test -z "$4" && mapic_api_upload_usage

    cd $MAPIC_CLI_FOLDER/api
    docker run -v $PWD:/sdk/ -v /:/data -v $4:/dataset.json --env-file $(mapic config file) -it node node /sdk/upload_datacube.js $4

}
mapic_api_upload_dataset () {
    test -z "$4" && mapic_api_upload_usage

    MAPIC_API_UPLOAD_DATASET=$(realpath "$4")
    MAPIC_API_UPLOAD_PROJECT=$MAPIC_API_PROJECT_CREATE_ID
    API_DIR=$MAPIC_CLI_FOLDER/api

    while [ ! $# -eq 0 ]
    do
        case "$1" in
            --project)
                MAPIC_API_UPLOAD_PROJECT=$3
                ;;
            --dataset)
                MAPIC_API_UPLOAD_DATASET=$(realpath "$3")
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
    docker run -it --rm --volume $API_DIR:/wd --workdir /wd node:slim npm install --silent >/dev/null 2>&1

    # upload data
    docker run -it --rm --name mapic_uploader --volume $API_DIR:/wd --volume $MAPIC_API_UPLOAD_DATASET:/mapic_upload$MAPIC_API_UPLOAD_DATASET --workdir /wd --env-file $MAPIC_ENV_FILE node:slim node api.upload-data.js

}
mapic_api_user_usage () {
    echo ""
    echo "Usage: mapic api user [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  list        List registered users"
    echo "  create      Create user"
    echo "  rm          Remove user"
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
        rm)         mapic_api_user_remove "$@";;
        *)          mapic_api_user_usage;
    esac 
}
mapic_api_user_list () {
    cd $MAPIC_CLI_FOLDER/api
    docker run -it --rm --volume $MAPIC_CLI_FOLDER/api:/wd --workdir /wd --env-file $MAPIC_ENV_FILE node:slim node api.list-users.js
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

    MAPIC_USER_CREATE_EMAIL=$4
    MAPIC_USER_CREATE_USERNAME=$5
    MAPIC_USER_CREATE_FIRSTNAME=$6
    MAPIC_USER_CREATE_LASTNAME=$7

    cd $MAPIC_CLI_FOLDER/api
    docker run -it --rm \
        --volume $MAPIC_CLI_FOLDER/api:/wd \
        --workdir /wd \
        --env-file $MAPIC_ENV_FILE \
        -e MAPIC_USER_CREATE_EMAIL=$MAPIC_USER_CREATE_EMAIL \
        -e MAPIC_USER_CREATE_USERNAME=$MAPIC_USER_CREATE_USERNAME \
        -e MAPIC_USER_CREATE_FIRSTNAME=$MAPIC_USER_CREATE_FIRSTNAME \
        -e MAPIC_USER_CREATE_LASTNAME=$MAPIC_USER_CREATE_LASTNAME \
        node:slim node api.create-user.js

}
mapic_api_user_remove_usage () {
    echo ""
    echo "Usage: mapic api user rm [EMAIL]"
    echo ""
    exit 1
}
mapic_api_user_remove () {
    test -z "$4" && mapic_api_user_remove_usage
    cd $MAPIC_CLI_FOLDER/api
    bash delete-user.sh "${@:4}"
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
    echo "Warning: This will promote user $4 to SUPER, giving access to all projects and data."
    echo ""
    read -p "Are you sure? (y/n)" -n 1 -r
    echo 
    if [[ $REPLY =~ ^[Yy]$ ]]
    then
        cd $MAPIC_CLI_FOLDER/api
        cd $MAPIC_CLI_FOLDER/api
        docker run -it --rm \
            --volume $MAPIC_CLI_FOLDER/api:/wd \
            --workdir /wd \
            --env-file $MAPIC_ENV_FILE \
            -e MAPIC_USER_PROMOTE_EMAIL=$4 \
            node:slim node api.promote-user.js
    fi
}
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
    docker exec -it -e MAPIC_DEBUG=$MAPIC_DEBUG $C  ${@:3}
}
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
    CERTBOTPATH=$(which certbot)
    if [ -z $CERTBOTPATH ]; then
        _install_certbot
    fi

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
}
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

    # engine tests
    mapic_test_ensure_data_engine
    mapic run engine npm test || mapic_test_failed "$@"

    # mile tests
    mapic_test_ensure_data_mile
    mapic run mile npm test || mapic_test_failed "$@"

    # mapicjs tests
    mapic_test_ensure_data_mapicjs
    mapic run engine bash public/test/test.sh || mapic_test_failed "$@"
    
    exit 0;
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

mapic_bench_usage () {
    echo ""
    echo "Usage: mapic bench [OPTIONS] COMMAND"
    echo ""
    echo "Commands:"
    echo "  large       Run large benchmark tests"
    echo "  small       Run small benchmark tests"
    echo "  help        This screen"
    echo ""
    echo "Options:"
    echo "  --dataset   Absolute path of dataset to use for benchmark, if other than default"
    echo "  --tiles     Number of tiles to request (Default: 300)"
    echo "  --layer-id  Layer ID to use for benchmarking"
    echo ""
    exit 0
}
mapic_bench () {
    test -z "$2" && mapic_bench_usage
    case "$2" in
        large)      mapic_bench_run "$@";;
        small)      mapic_bench_run "$@";;
        help)       mapic_bench_usage ;;
        *)          mapic_bench_usage;;
    esac 
}
mapic_bench_run () {

    # defaults
    MAPIC_BENCHMARK_NUMBER_OF_TILES=300
    MAPIC_BENCHMARK_DATASET_PATH=$MAPIC_CLI_FOLDER/api/benchmark-data.zip
    MAPIC_BENCHMARK_UPLOADED_DATA_LAYER=$MAPIC_BENCHMARK_UPLOADED_DATA_LAYER

    # get options
    while [ ! $# -eq 0 ]
    do
        case "$1" in
            --dataset)
                MAPIC_BENCHMARK_DATASET_PATH=$2;;
            --tiles)
                MAPIC_BENCHMARK_NUMBER_OF_TILES=$2;;
            --layer_id)
                MAPIC_BENCHMARK_UPLOADED_DATA_LAYER=$2;;
            --help)
                mapic_bench_usage;;
            large)
                MAPIC_BENCHMARK_SIZE=large;;
            small)
                MAPIC_BENCHMARK_SIZE=small;;
        esac
        shift
    done

    # write to env
    _write_env MAPIC_BENCHMARK_NUMBER_OF_TILES $MAPIC_BENCHMARK_NUMBER_OF_TILES
    _write_env MAPIC_BENCHMARK_DATASET_PATH $MAPIC_BENCHMARK_DATASET_PATH
    _write_env MAPIC_BENCHMARK_UPLOADED_DATA_LAYER $MAPIC_BENCHMARK_UPLOADED_DATA_LAYER
    _write_env MAPIC_BENCHMARK_SIZE $MAPIC_BENCHMARK_SIZE

    if [[ "$MAPIC_DEBUG" == true ]]; then
        echo "MAPIC_BENCHMARK_DATASET_PATH: $MAPIC_BENCHMARK_DATASET_PATH"
        echo "MAPIC_BENCHMARK_NUMBER_OF_TILES: $MAPIC_BENCHMARK_NUMBER_OF_TILES"
        echo "MAPIC_BENCHMARK_UPLOADED_DATA_LAYER: $MAPIC_BENCHMARK_UPLOADED_DATA_LAYER"
        echo "MAPIC_BENCHMARK_SIZE: $MAPIC_BENCHMARK_SIZE"
    fi

    # get info on replicas
    DOCKER_INFO=$(docker stack services mapic | grep mapic_mile |  head -c -30 | tail -c +21 | tr -d '\n' |   tail -c 20)

    echo ""
    ecco 5 "Mapic Benchmark Tests"
    ecco 5 "---------------------"
    echo "Number of active mapic/mile nodes: $DOCKER_INFO"
    echo "Benchmarking $MAPIC_BENCHMARK_SIZE dataset with $MAPIC_BENCHMARK_NUMBER_OF_TILES tiles..."

    # run benchmark
    docker run -it --rm --env-file $MAPIC_ENV_FILE -e MAPIC_BENCHMARK_NUMBER_OF_TILES=$MAPIC_BENCHMARK_NUMBER_OF_TILES -e MAPIC_BENCHMARK_SIZE=$MAPIC_BENCHMARK_SIZE --volume $MAPIC_CLI_FOLDER/api:/mapic --volume $MAPIC_BENCHMARK_DATASET_PATH:/data/$MAPIC_BENCHMARK_DATASET_PATH -w /mapic node:6 sh api.benchmark.sh

    echo "Benchmark done."    
}
mapic_scale_mile () {
    
    echo "Scaling to $1 replicas of mapic/mile"

    # scale services
    docker service scale mapic_mile=$1 

    echo "Please allow a few minutes for correct number of replicas to become active (especially when scaling down)."
}
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
        --constraint=node.ip==$MAPIC_IP \
        --mount=type=bind,src=/var/run/docker.sock,dst=/var/run/docker.sock \
        mapic/swarm-visualizer
}
mapic_viz_stop () {
    echo "Stopping Swarm Visualizer..."
    docker service rm swarm-visualizer
}
mapic_tor_usage () {
    echo ""
    echo "Usage: mapic tor start|stop|status"
    echo ""
    exit 1
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
mapic_tor_status () {
    echo ""
    docker service ps tor-relay
}
mapic_tor_start () {
    echo "Starting Tor relays..."
    docker pull mapic/tor-relay:latest >/dev/null
    docker service create --mode global --detach -p 9001:9001 --name tor-relay mapic/tor-relay:latest
}
mapic_tor_stop () {
    echo "Stopping Tor relays..."
    docker service rm tor-relay
}

# entrypoint
mapic_cli "$@"
