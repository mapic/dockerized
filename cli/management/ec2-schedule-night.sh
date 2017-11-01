#!/bin/bash

#
# spin down ec2 instances for NIGHT / WEEKEND mode
#
# this script is run from host cronjob, with no additional logic
#
export HOME=$MAPIC_HOME
SCALE=${MAPIC_NIGHT_SCALE:-2}
INSTANCES_FILE=$MAPIC_CLI_FOLDER/.mapic.aws-ec2.env

echo "Scheduling Mapic for night-mode..."

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
    printf "Stopping instance $INSTANCE..."
    printf "done!\n"

    # stop instances
    aws ec2 stop-instances --instance-ids $INSTANCE >/dev/null 2>&1

done < "$INSTANCES_FILE"

# re-scale mapic
mapic scale mile $SCALE 

echo "Mapic is now scaled for NIGHT/WEEKEND mode"
