#!/bin/bash

usage () {
    echo "Please set $1 ENV variable. (Example: export $1=somevalue)"
    exit 1
}

function pull_all() {
	echo "Pulling masters..."
	cd $MAPIC_ROOT_FOLDER
	git pull origin master
	git submodule foreach --recursive git pull origin master
}

function test_all() {
	cd $MAPIC_ROOT_FOLDER/scripts/test
	./test.sh
}

# check env
[ -z "$MAPIC_ROOT_FOLDER" ] && usage MAPIC_ROOT_FOLDER
[ -z "$MAPIC_DOMAIN" ] && usage MAPIC_DOMAIN


# confirm pull
read -p "Update all repos? 
  [git submodule foreach --recursive git pull origin master]  (y/n):" -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
	# pull all
	pull_all

	# confirm test
	read -p "Run all tests on new code? [git submodule foreach --recursive git pull origin master]  (y/n):" -n 1 -r
	echo

	# run tests
	if [[ $REPLY =~ ^[Yy]$ ]]; then test_all; fi
fi