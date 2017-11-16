#!/bin/bash

#
# spin up ec2 instances for DAYTIME mode
#
# this script is run from host cronjob, with no additional logic
#

export HOME=$MAPIC_HOME
# SCALE=${MAPIC_DAY_SCALE:-8} # nodes
INSTANCES_FILE=$MAPIC_CLI_FOLDER/.mapic.aws-ec2.env

echo "Scheduling Mapic for daytime mode..."
NODES=$(docker node ls | grep Ready | wc -l)
echo "Currently $NODES nodes active."

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

i=0
# read list of instances from .mapic.aws-ec2.env
while read -r INSTANCE
do
    printf "Starting instance $INSTANCE..."
    printf "done!\n"

    # start instances
    aws ec2 start-instances --instance-ids $INSTANCE  > /dev/null

done < "$INSTANCES_FILE"


# re-scale mapic
MILE_REPLICAS_PER_NODE=2
TOTAL_REPLICAS=$((i * $MILE_REPLICAS_PER_NODE))

# it will take some time for instances to be ready, so delay scaling...
# mapic delayed 110 mapic scale mile $TOTAL_REPLICAS &
mapic delayed 10 mapic scale mile auto &

echo "Mapic is now scaled for DAYTIME mode"