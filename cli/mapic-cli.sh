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
MAPIC_CLI_VERSION=17.7



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
    echo "  test                Run Mapic tests"
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
    echo ""
    echo "API commands:"
    echo "  user                Handle Mapic users"
    echo "  upload              Upload data"  
    echo ""
    
    # undocumented api
    if [[ "$MAPIC_DEBUG" == "true" ]]; then
    echo "Undocumented:"
    echo "  edit                Edit mapic-cli.sh source file"
    echo "  tor                 Tor Project relay settings"
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
        user)       mapic_api_user "$@";;
        upload)     mapic_api_upload "$@";;
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
        help)       mapic_cli_usage;;
        --help)     mapic_cli_usage;;
        -h)         mapic_cli_usage;;
        env)        mapic_env "$@";;
        edit)       mapic_edit "$@";;
        version)    mapic_version "$@";;
        info)       mapic_info "$@";;
        tor)        mapic_tor "$@";;
    
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

    # hardcoded env file
    MAPIC_ENV_FILE=/usr/local/bin/.mapic.env

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
        MAPIC_CONFIG_FOLDER=$MAPIC_CLI_FOLDER/config/files

        # cp default env file
        cp $MAPIC_CLI_FOLDER/.mapic.default.env /usr/local/bin/.mapic.env 

        # create symlink for global mapic
        _create_mapic_symlink

        # install dependencies on osx
        if [[ "$MAPIC_HOST_OS" == "osx" ]]; then
            _install_osx_tools
        fi

        # install dependencies on linux
        if [[ "$MAPIC_HOST_OS" == "linux" ]]; then
            _install_linux_tools
        fi

        # ensure editor
        _ensure_editor

        # determine public ip
        MAPIC_IP=$(curl ipinfo.io/ip)

        # now everything should work, time to write ENV
        _write_env MAPIC_ROOT_FOLDER $MAPIC_ROOT_FOLDER
        _write_env MAPIC_CLI_FOLDER $MAPIC_CLI_FOLDER
        _write_env MAPIC_HOST_OS $MAPIC_HOST_OS
        _write_env MAPIC_ENV_FILE $MAPIC_ENV_FILE
        _write_env MAPIC_COLOR_FILE $MAPIC_COLOR_FILE
        _write_env MAPIC_CONFIG_FOLDER $MAPIC_CONFIG_FOLDER
        _write_env MAPIC_IP $MAPIC_IP

    fi

    # set which folder mapic was executed from
    MAPIC_CLI_EXECUTED_FROM=$PWD

    # source env file
    set -o allexport
    source $MAPIC_ENV_FILE
    source $MAPIC_COLOR_FILE

    # mark [debug mode]
    test "$MAPIC_DEBUG" == "true" && ecco 82 "debug mode"

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
_install_linux_tools () {
    PWGEN=$(which pwgen)
    if [ -z $PWGEN ]; then
        apt-get update -y
        apt-get install -y pwgen
    fi
}
_install_osx_tools () {
    
    SED=$(which sed)
    BREW=$(which brew)
    JQ=$(which jq)
    GREP=$(which grep)
    PWGEN=$(which pwgen)

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
            echo "Brew required for OSX. Please install 'grep' manually."
        else
            echo "Installing grep..."
            brew update
            brew install grep --with-default-names
            GREPV=$(grep --version)
            echo "$GREPV installed"
        fi
    fi

    # pwget
    if [ -z $PWGEN ]; then
        cd $MAPIC_ROOT_FOLDER/tmp
        wget "http://http.debian.net/debian/pool/main/p/pwgen/pwgen_2.07.orig.tar.gz"
        tar xf pwgen_2.07.orig.tar.gz
        cd pwget-2.07
        ./configure
        make && make install
    fi

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
    echo "$MAPIC_DEFAULT_EDITOR $MAPIC_CLI_FOLDER/mapic-cli.sh"
    $MAPIC_DEFAULT_EDITOR $MAPIC_CLI_FOLDER/mapic-cli.sh
}
ecco () {
    COLOR="c_"$1
    TEXT=${@:2}
    printf "${!COLOR}${TEXT}${c_reset}\n" 
}
mapic_info () {

    # docker nodes
    echo ""
    ecco 6 "Docker nodes:"
    _print_docker_nodes
    
    # mapic config
    _print_config

    # docker info
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
    ecco 58 "Version"
    echo "  Mapic:        $MAPIC_VERSION"
    echo "  Mapic CLI:    $MAPIC_CLI_VERSION"
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

    # install docker
    mapic_install_docker_ubuntu

    # print version
    docker version

    # set localhost
    _write_env MAPIC_DOMAIN localhost

    # install
    _install_mapic

    # configure
    mapic_configure
}
_init_docker_swarm () {
    docker swarm init --advertise-addr $MAPIC_IP
     # || abort "Docker Swarm is currently only available in experimental mode. Please put Docker in experimental mode and try again."
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

#   _________  ____  / __(_)___ _
#  / ___/ __ \/ __ \/ /_/ / __ `/
# / /__/ /_/ / / / / __/ / /_/ / 
# \___/\____/_/ /_/_/ /_/\__, /  
#                       /____/   
mapic_configure () {
    _refresh_config
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
        refresh)    mapic_config_refresh "$@";;
        set)        mapic_config_set "$@";;
        get)        mapic_config_get "$@";;
        list)       mapic_config_list;;
        edit)       mapic_config_edit "$@";;
        file)       mapic_config_file "$@";;
        prompt)     mapic_config_prompt "$@";; 
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
    _refresh_config
}
mapic_api_configure () {
    # todo: remove/merge
    m config prompt MAPIC_API_DOMAIN "Please enter the domain of the Mapic API you want to connect with (eg. maps.mapic.io)"
    m config prompt MAPIC_API_USERNAME "Please enter your Mapic API username"
    m config prompt MAPIC_API_AUTH "Please enter your Mapic API password"

    mapic_api_display_config
}
mapic_api_display_config () {
    # todo: remove/merge
    echo ""
    echo "Mapic API config:"
    echo "  Domain:   $MAPIC_API_DOMAIN"
    echo "  Username: $MAPIC_API_USERNAME"
    echo "  Auth:     $MAPIC_API_AUTH"
}
mapic_env () {
    echo "Deprecated! Todo: change to `mapic config ... `"
    mapic_config "$@"
}
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
    echo "  MAPIC_DEBUG                     Debug switch, used arbitrarily."
    echo "  MAPIC_ROOT_FOLDER               Folder where 'mapic' root lives. Set automatically."
    echo ""
    echo "  See 'mapic config list' for all variables"
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
    [[ "$FLAG" = "" ]] && mapic env get $3
    [[ "$FLAG" = "value" ]] && echo $4
}
mapic_config_get_usage () {
    echo ""
    echo "Usage: mapic config get [KEY]"
    echo ""
    echo "Example: `mapic config get MAPIC_DOMAIN`"
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
        read -e -p "$ENV_KEY $MSG: " ENV_VALUE 
    else
        read -e -p "$ENV_KEY $MSG: " -i "$DEFAULT_VALUE" ENV_VALUE 
    fi

    # set env
    _write_env "$ENV_KEY" "$ENV_VALUE" 

    # return value
    echo $ENV_VALUE
}
# fn used internally to write to env file
_write_env () {
    test -z $1 && failed "missing arg"

    echo "_write_env $1 $2"

    # add or replace line in .mapic.env
    if grep -q "$1=" "$MAPIC_ENV_FILE"; then
        echo "found so replace"
        # replace line
        sed -i "/$1=/c\\$1=$2" $MAPIC_ENV_FILE
    else
        echo "new"
        # ensure newline
        sed -i -e '$a\' $MAPIC_ENV_FILE 

        # add to bottom
        echo "$1"="$2" >> $MAPIC_ENV_FILE
    fi
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
    COMPOSEFILE=$MAPIC_CONFIG_FOLDER/stack.yml
    # docker stack rm mapic
    docker stack deploy --compose-file=$COMPOSEFILE mapic 
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
        echo "2: $2"    
        case "$2" in
            mongo)          docker service logs -f mapic_mongo;;
            mile)           docker service logs -f mapic_mile;;
            tor)            docker service logs -f mapic_tor;;
            viz)            docker service logs -f mapic_visualizer;;
            postgis)        docker service logs -f mapic_postgis;;
            nginx)          docker service logs -f mapic_nginx;;
            engine)         docker service logs -f mapic_engine;;
            redis)          docker service logs -f mapic_redislayers;;
            redislayers)    docker service logs -f mapic_redislayers;;
            redisstats)     docker service logs -f mapic_redisstats;;
            redistokens)    docker service logs -f mapic_redistokens;;
            redistemp)      docker service logs -f mapic_redistemp;;
            *)              mapic_logs_container_usage;
        esac 
        exit
    fi
    if [[ "$TRAVIS" == "true" ]]; then
        # stream logs
        docker service logs -f mapic_mile         &
        docker service logs -f mapic_postgis      &
        docker service logs -f mapic_redistokens  &
        docker service logs -f mapic_redislayers  &
        docker service logs -f mapic_mongo        &
        docker service logs -f mapic_redisstats   &
        docker service logs -f mapic_nginx        &
        docker service logs -f mapic_engine       &
        docker service logs -f mapic_redistemp    & 
    else
        # print current logs
        docker service logs mapic_redistokens
        docker service logs mapic_redislayers
        docker service logs mapic_redisstats 
        docker service logs mapic_redistemp  
        docker service logs mapic_mongo      
        docker service logs mapic_nginx      
        docker service logs mapic_postgis    
        docker service logs mapic_mile       
        docker service logs mapic_engine     
        docker service logs mapic_tor     
        docker service logs mapic_visualizer     
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
    _install_mapic
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
_ensure_mapic_domain () {
    # ensure MAPIC_DOMAIN
    if [ -z "$MAPIC_DOMAIN" ]; then
        MAPIC_DOMAIN=$(mapic env prompt MAPIC_DOMAIN "Please provide a valid domain for the Mapic install")
    fi
}
_print_branches () {
    echo ""
    ecco 41 "Git branches:"
    cd $MAPIC_ROOT_FOLDER
    GIT=$(git log --pretty=format:"%h (%ar)" -1)
    BRANCH=$(git branch | grep \* | cut -d ' ' -f2)
    ecco 4 "mapic/mapic"
    ecco 0 "branch: $BRANCH"
    ecco 0 "commit: $GIT"

    cd $MAPIC_ROOT_FOLDER/mile
    GIT=$(git log --pretty=format:"%h (%ar)" -1)
    BRANCH=$(git branch | grep \* | cut -d ' ' -f2)
    ecco 4 "mapic/mile"
    ecco 0 "branch: $BRANCH"
    ecco 0 "commit: $GIT"
   
    cd $MAPIC_ROOT_FOLDER/engine
    GIT=$(git log --pretty=format:"%h (%ar)" -1)
    BRANCH=$(git branch | grep \* | cut -d ' ' -f2)
    ecco 4 "mapic/engine"
    ecco 0 "branch: $BRANCH"
    ecco 0 "commit: $GIT"

    cd $MAPIC_ROOT_FOLDER/mapic.js
    GIT=$(git log --pretty=format:"%h (%ar)" -1)
    BRANCH=$(git branch | grep \* | cut -d ' ' -f2)
    ecco 4 "mapic/mapic.js"
    ecco 0 "branch: $BRANCH"
    ecco 0 "commit: $GIT"

    echo ""
}
_refresh_config () {

    echo ""
    ecco 8 "Refreshing configuration..."

    # create auth for redis/mongo
    MAPIC_REDIS_AUTH=$(pwgen 40 1)
    MAPIC_MONGO_AUTH=$(pwgen 40 1)
    _write_env MAPIC_REDIS_AUTH $MAPIC_REDIS_AUTH
    _write_env MAPIC_MONGO_AUTH $MAPIC_MONGO_AUTH

    echo "  Created secure auths..."

    # replace old config with defaults
    cd $MAPIC_CLI_FOLDER/config
    rm -rf files
    yes | cp -rf default-files files
    chmod +w files
    
    echo "  Copied config files..."

    # update config files
    docker run \
    -it \
    --rm \
    --env-file $MAPIC_ENV_FILE \
    -v $MAPIC_ROOT_FOLDER/cli/config:/tmp \
    -v $MAPIC_ROOT_FOLDER/cli/config/files:/config \
    -w /tmp \
    node:6 \
    node refresh-config.js

    echo "  Updated config files..."

    # print config
    _print_config
  
    # done    
    ecco 8 "Mapic configuration updated!"
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
    echo "Installing Docker!"
    cd $MAPIC_CLI_FOLDER/install
    bash install-docker-ubuntu.sh

    # put docker in experimental mode for swarm
    # see https://github.com/moby/moby/issues/30585#issuecomment-280822231
    echo '{"experimental":true}' >> /etc/docker/daemon.json
    sudo systemctl restart docker || service docker restart
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
    echo "Usage: mapic upload DATASET [OPTIONS]"
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
    echo "Usage: mapic user [OPTIONS]"
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
    echo "Usage: mapic user create [EMAIL] [USERNAME] [FIRSTNAME] [LASTNAME]"
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
    echo "Usage: mapic user super [EMAIL]"
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
        create)     _create_ssl;;
        scan)       _scan_ssl;;
        *)          mapic_ssl_usage;
    esac 
}
_create_ssl () {

    # ensure domain
    _ensure_mapic_domain

    # create certs
    if [ $MAPIC_DOMAIN = "localhost" ]; then
        cd $MAPIC_CLI_FOLDER/ssl
        bash create-ssl-localhost.sh
    else 
        cd $MAPIC_CLI_FOLDER/ssl
        bash create-ssl-public-domain.sh
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
    # bash create-dns-entries-route-53.sh
    WDR=/usr/src/app
    docker run -it -p 80:80 -p 443:443 --env-file $MAPIC_ENV_FILE --volume $PWD:$WDR -w $WDR node:6 sh entrypoint.sh
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
mapic_status_visualize () {
    echo "todo"
    # docker run -it -d -p 8080:8080 -v /var/run/docker.sock:/var/run/docker.sock dockersamples/visualizer
    # note: don't run this in production, as it exposes docker remote api
    # see: https://github.com/dockersamples/docker-swarm-visualizer/issues/66
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
        *)          mapic_test_usage;
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

mapic_tor () {
    test -z "$2" && mapic_tor_usage
    case "$2" in
        install)    mapic_tor_install;;
        start)      mapic_tor_start;;
        stop)       mapic_tor_stop;;
        status)     mapic_tor_status;;
        *)          mapic_tor_usage;
    esac 
    # ensure 
}
mapic_tor_usage () {
    _tor_status
}
_tor_status () {
    echo ""
}

mapic_tor_install () {
    # install 
    sudo apt-get update -y
    sudo apt-get install -y tor tor-arm

    # ok
    # create torrc file

}


#   ___  ____  / /________  ______  ____  (_)___  / /_
#  / _ \/ __ \/ __/ ___/ / / / __ \/ __ \/ / __ \/ __/
# /  __/ / / / /_/ /  / /_/ / /_/ / /_/ / / / / / /_  
# \___/_/ /_/\__/_/   \__, / .___/\____/_/_/ /_/\__/  
#                    /____/_/                         
mapic_cli "$@"
