#!/bin/bash

# This script will return time offsets for all given autoscaling group instances 
# since given date. It will return the time offset in seconds for each instance, 
# including instance offsets, node offsets and pod offsets.
#
# usage:
# ./asg-all-offsets.sh <autoscaling group name> <date>
#
# usage example:
# ./asg-all-offsets.sh demo.harley.systems 2021-09-01T19:45:47Z
#
# output:
# <instance-id>,<pod-name>,<pod-scheduled-offset>,<pod-initialized-offset>,<instance-launch-offset>,<instance-k8s-eni-attach-offset>,<node-created-offset>,<node-ready-offset>,<pod-containers-ready-offset>,<pod-ready-offset>

# ensure the parameter was passed
if [ -z "$1" ] || [ -z "$2" ]; then
    echo "usage: asg-all-offsets.sh <asg-name> <date>"
    exit 1
fi

# if asked for help, print instructions
if [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
    echo "This script will return time offsets for all given autoscaling group instances"
    echo "since given date. It will return the time offset in seconds for each instance,"
    echo "including instance offsets, node offsets and pod offsets."
    echo "usage: asg-all-offsets.sh <autoscaling group name> <date>"
    exit 0
fi

# get temporary file path
ALL_TIMES_FILE=$(mktemp)

# get all times
asg-all-times.sh $1 > $ALL_TIMES_FILE

# get the date
DATE=$2

# get the date in seconds
DATE_SECONDS=$(date -d $DATE +%s)

# output the header line
echo "INSTANCE-ID,POD-NAME,POD-CREATED-AT,INSTANCE-LAUNCHED-OFFSET,NODE-CREATED-OFFSET,NODE-READY-OFFSET,POD-SCHEDULED-OFFSET,POD-INITIALIZED-OFFSET,INSTANCE-K8S-ENI-OFFSET,POD-CONTAINERS-READY-OFFSET,POD-READY-OFFSET"
{
    read
    # for each line in the file
    while read line; do

        # get the instance id
        INSTANCE_ID=$(echo $line | cut -d, -f1)
        # get the pod name
        POD_NAME=$(echo $line | cut -d, -f2)
        # get the pod creation time
        POD_CREATED_AT=$(echo $line | cut -d, -f3)
        # get the instance boot time
        INSTANCE_BOOT_TIME=$(echo $line | cut -d, -f4)
        # get the node created time
        NODE_CREATED_TIME=$(echo $line | cut -d, -f5)
        # get the node ready time
        NODE_READY_TIME=$(echo $line | cut -d, -f6)
        # get the pod scheduled time
        POD_SCHEDULED_TIME=$(echo $line | cut -d, -f7)
        # get the pod initialized time
        POD_INITIALIZED_TIME=$(echo $line | cut -d, -f8)
        # get the pod containers ready time
        POD_CONTAINERS_READY_TIME=$(echo $line | cut -d, -f9)
        # get the pod ready time
        POD_READY_TIME=$(echo $line | cut -d, -f10)

        # calculate the pod created offset
        POD_CREATED_OFFSET=$(date -d $POD_CREATED_AT +%s)
        POD_CREATED_OFFSET=$(($POD_CREATED_OFFSET - $DATE_SECONDS))
        # calculate the instance boot offset
        INSTANCE_BOOT_OFFSET=$(date -d $INSTANCE_BOOT_TIME +%s)
        INSTANCE_BOOT_OFFSET=$(($INSTANCE_BOOT_OFFSET - $DATE_SECONDS))
        # calculate the node created offset
        NODE_CREATED_OFFSET=$(date -d $NODE_CREATED_TIME +%s)
        NODE_CREATED_OFFSET=$(($NODE_CREATED_OFFSET - $DATE_SECONDS))
        # calculate the node ready offset
        NODE_READY_OFFSET=$(date -d $NODE_READY_TIME +%s)
        NODE_READY_OFFSET=$(($NODE_READY_OFFSET - $DATE_SECONDS))
        # calculate the pod scheduled offset
        POD_SCHEDULED_OFFSET=$(date -d $POD_SCHEDULED_TIME +%s)
        POD_SCHEDULED_OFFSET=$(($POD_SCHEDULED_OFFSET - $DATE_SECONDS))
        # calculate the pod initialized offset
        POD_INITIALIZED_OFFSET=$(date -d $POD_INITIALIZED_TIME +%s)
        POD_INITIALIZED_OFFSET=$(($POD_INITIALIZED_OFFSET - $DATE_SECONDS))
        # calculate the pod containers ready offset
        POD_CONTAINERS_READY_OFFSET=$(date -d $POD_CONTAINERS_READY_TIME +%s)
        POD_CONTAINERS_READY_OFFSET=$(($POD_CONTAINERS_READY_OFFSET - $DATE_SECONDS))
        # calculate the pod ready offset
        POD_READY_OFFSET=$(date -d $POD_READY_TIME +%s)
        POD_READY_OFFSET=$(($POD_READY_OFFSET - $DATE_SECONDS))

        # output the instance id and the times
        echo "$INSTANCE_ID,$POD_NAME,$POD_CREATED_OFFSET,$INSTANCE_BOOT_OFFSET,$NODE_CREATED_OFFSET,$NODE_READY_OFFSET,$POD_SCHEDULED_OFFSET,$POD_INITIALIZED_OFFSET,$POD_CONTAINERS_READY_OFFSET,$POD_READY_OFFSET"
    done
} < $ALL_TIMES_FILE

# remove the temporary files
rm $ALL_TIMES_FILE

