#!/bin/bash

echo "Initializing submodules..."

# init submodules
cd $MAPIC_ROOT_FOLDER
git submodule init
git submodule update --recursive --remote
git submodule foreach --recursive git checkout master

# install yarn modules
docker run -it --rm -v $MAPIC_ROOT_FOLDER:/mapic_tmp -w /mapic_tmp mapic/xenial:latest yarn install 

# # debug mode. usage: command 2>"${PIPE}" 1>"${PIPE}"
# if [[ ${MAPIC_DEBUG} = true ]]; then
#     PIPE=/dev/stdout
# else
#     PIPE=/dev/null
# fi

# print_head () { printf "$cb_white $1 $c_red $2 $c_reset \n"; }
# print_sub () { printf "$cb_white $1 $c_red $2 $c_reset \r"; }

# # feedback
# print_head "#" "Pulling latest code..." "\n"


# # todo: do this in a container also, to remove dep on git..
# # init mapic/mapic submodule
# # print_sub "#" "Initing submodules..."
# cd $MAPIC_ROOT_FOLDER
# git submodule init 2>"${PIPE}" 1>"${PIPE}"
# git submodule update --recursive --remote 2>"${PIPE}" 1>"${PIPE}"
# git submodule foreach --recursive git checkout master 2>"${PIPE}" 1>"${PIPE}"

# # init mapic/mile submodule
# # print_sub "#" "Initing submodule: Mile"
# cd $MAPIC_ROOT_FOLDER/modules/mile
# git submodule init 2>"${PIPE}" 1>"${PIPE}"
# git submodule update --recursive --remote 2>"${PIPE}" 1>"${PIPE}"

# # init mapic/engine submodule
# # print_sub "#" "Initing submodule: Engine"
# cd $MAPIC_ROOT_FOLDER/modules/engine
# git submodule init 2>"${PIPE}" 1>"${PIPE}"
# git submodule update --recursive --remote 2>"${PIPE}" 1>"${PIPE}"

# # init mapic/mapic.js submodule
# # print_sub "#" "Initing submodule: Mapic.js"
# cd $MAPIC_ROOT_FOLDER/modules/mapic.js
# git submodule init 2>"${PIPE}"
# git submodule update --recursive --remote 2>"${PIPE}" 1>"${PIPE}"

# # install modules in mapic/mapic (for scripts, etc)
# # todo: do this in a container env also
# cd $MAPIC_ROOT_FOLDER
# yarn install 2>"${PIPE}" 1>"${PIPE}"
