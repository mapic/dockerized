#!/bin/bash

#
# spin up ec2 instances for DAYTIME mode
#
# this script is run from host cronjob, with no additional logic
#

export HOME=$MAPIC_HOME
SCALE=${MAPIC_DAY_SCALE:-8} # nodes
INSTANCES_FILE=$MAPIC_CLI_FOLDER/.mapic.aws-ec2.env

echo "Scheduling Mapic for daytime mode..."

# check for aws cli
AWSCLI=$(which aws)
if [[ -z $AWSCLI ]]; then
    echo "No AWS installed, installing..."
    apt-get update -y
    apt-get install -y awscli 
    clear
    echo "Please configure AWS for first-time use..."
    aws configure
    echo "AWS CLI is configured and ready for use."
fi

# read list of instances from .mapic.aws-ec2.env
while read -r INSTANCE
do
    printf "Starting instance $INSTANCE..."
    printf "done!\n"

    # start instances
    aws ec2 start-instances --instance-ids $INSTANCE  >/dev/null 2>&1

done < "$INSTANCES_FILE"

# re-scale mapic
# it will take some time for instances to be ready, so delay scaling...
mapic delayed 100 mapic scale mile 4 &   # half, due to messed up load balancing of docker containers
mapic delayed 110 mapic scale mile $SCALE &


echo "Mapic is now scaled for DAYTIME mode"