#!/bin/bash

env_domain () {
	echo "Need to set \$MAPIC_DOMAIN environment variable."
	exit 1
}
env_root_folder () {
	echo "Need to set \$MAPIC_ROOT_FOLDER environment variable."
	exit 1
}

test -z "$MAPIC_DOMAIN" && env_domain
test -z "$MAPIC_ROOT_FOLDER" && env_root_folder

LOGFOLDER=$MAPIC_ROOT_FOLDER/logs

if [ ! -d "$LOGFOLDER" ]; then	
	echo "Creating log folder $LOGFOLDER" 
	echo "Log folder added to .gitignore."
	mkdir $LOGFOLDER
fi

# log path
MAINLOG=$LOGFOLDER/mapic-$MAPIC_DOMAIN-`date +"%Y%m%d%H%M%S"`.log

# ensure jq
JQ=$(which jq)
test -z "$JQ" && apt update -y && apt install -y jq

# get docker logs
docker ps -q | while read -r container_id ; do

	# get keys
	LOGPATH=$(docker inspect $container_id | jq .[0].LogPath)
	NAME=$(docker inspect $container_id | jq .[0].Name)
	LOGFILE=$(echo "$LOGPATH" | tr -d '"')

	# concat to log
	echo $NAME >> $MAINLOG
	echo "#########################" >> $MAINLOG

	cat $LOGFILE | while read -r log_line ; do
		log_text=$(echo $log_line | jq .log | tr -d '"')
		log_time=$(echo $log_line | jq .time | tr -d '"')
		IFS='.' read -a myarray <<< "$log_time"
		pretty_log_time=${myarray[0]}
		echo $pretty_log_time "|    " $log_text >> $MAINLOG
	done

	echo  $'\n\n\n\n\n' >> $MAINLOG

done

# Print filename
echo "Logs dumped to file: $MAINLOG"
