#!/bin/bash
# provided the autoscaling group name, this script shows when the node was created and when it became ready
# 
# usage:
# asg-node-times.sh <asg-name>
#
# usage example:
# asg-node-times.sh demo.harley.systems
#
# output:
# <instance-id>,<created-at>,<ready-at>
#
# example output:
# NODE-ID,NODE-CREATED-AT,NODE-READY-AT
# i-0f1d6d348d8d50b2e,2023-09-01T19:45:47Z,2023-09-01T19:46:07Z

# ensure the parameter was passed
if [ -z "$1" ]; then
    echo "Usage: asg-nodes-conditions.sh <asg-name>"
    echo "for help type asg-nodes-conditions.sh -h"
    exit 1
fi

# if asked for help, print instructions
if [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
    echo "Provided the autoscaling group name, this script shows when the node was created and when it became ready."
    echo "usage: asg-nodes-conditions.sh <asg-name>"
    exit 0
fi

# get list of asg instace ids
INSTANCE_IDS=( $(asg-instance-ids.sh $1) )

echo "NODE-ID,NODE-CREATED-AT,NODE-READY-AT"
# for each such instance id
for instance_id in "${INSTANCE_IDS[@]}"; do

    # extract node json
    NODE_JSON=$(kubectl get node $instance_id -o json)

    # extract node age
    CREATED_AT=$(echo $NODE_JSON | jq -r '.metadata.creationTimestamp')

    # extract the last transition time of each condition
    READY_AT=$(echo $NODE_JSON | jq -r '.status.conditions[] | select(.type == "Ready") | .lastTransitionTime')

    # output the instance id and the times
    echo "$instance_id,$CREATED_AT,$READY_AT"
done