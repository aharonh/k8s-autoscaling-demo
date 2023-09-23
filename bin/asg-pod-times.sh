#!/bin/bash
# provided the autoscaling group name, and assuming each node contains one workload pod, this script
# shows at what time the pod running on each node got into which state.
# this is useful when examining pod autoscaling groups timings and delays.
# 
# usage: 
# asg-pod-times.sh <asg-name>
#
# example usage: 
# asg-pod-times.sh demo.harley.systems
#
# output:
# <instance-id>,<pod-name>,<pod-scheduled-at>,<pod-initialized-at>,<pod-containers-ready-at>,<pod-ready-at>
#
# example output:
# INSTANCE-ID,POD-NAME,POD-SCHEDULED-AT,POD-INITIALIZED-AT,POD-CONTAINERS-READY-AT,POD-READY-AT
# i-0f1d6d348d8d50b2e,demo-service-76c7d56884-cbkjm,2023-09-01T19:46:07Z,2023-09-01T19:46:07Z,2023-09-01T19:46:20Z,2023-09-01T19:46:20Z

# ensure the parameter was passed
if [ -z "$1" ]; then
    echo "usage: asg-pod-times.sh <asg-name>"
    exit 1
fi

# if asked for help, print instructions
if [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
    echo "provided the autoscaling group name, and assuming each node contains one workload pod, this script"
    echo "shows at what time the pod running on each node got into which state."
    echo "this is useful when examining pod autoscaling groups timings and delays."
    echo "usage: asg-pod-times.sh <asg-name>"
    exit 0
fi

# get list of asg instace ids
INSTANCE_IDS=( $(asg-instance-ids.sh $1) )

echo "INSTANCE-ID,POD-NAME,POD_CREATED_AT,POD-SCHEDULED-AT,POD-INITIALIZED-AT,POD-CONTAINERS-READY-AT,POD-READY-AT"
# for each such instance id
for instance_id in "${INSTANCE_IDS[@]}"; do

    # get pod info
    POD_INFO=$(kubectl get pod -o custom-columns=POD:.metadata.name,CREATED_AT:.metadata.creationTimestamp --no-headers \
      --field-selector spec.nodeName=$instance_id)

    # get the pod name running on that instance
    POD_NAME=$(echo $POD_INFO | cut -d' ' -f1)
    
    # get the pod creation time
    POD_CREATED_AT=$(echo $POD_INFO | cut -d' ' -f2)

    # extract the pod conditions from it's json
    CONDITIONS_JSON=$(kubectl get pod -o json $POD_NAME | jq -r '.status.conditions[]')
    
    # extract the last transition time of each condition
    READY_AT=$(echo $CONDITIONS_JSON | jq -r 'select(.type == "Ready") | "\(.lastTransitionTime)"')
    CONTAINERS_READY_AT=$(echo $CONDITIONS_JSON | jq -r 'select(.type == "ContainersReady") | "\(.lastTransitionTime)"')
    POD_SCHEDULED_AT=$(echo $CONDITIONS_JSON | jq -r 'select(.type == "PodScheduled") | "\(.lastTransitionTime)"')
    POD_INITIALIZED_AT=$(echo $CONDITIONS_JSON | jq -r 'select(.type == "Initialized") | "\(.lastTransitionTime)"')
    
    # output the instance id and the times
    echo "$instance_id,$POD_NAME,$POD_CREATED_AT,$POD_SCHEDULED_AT,$POD_INITIALIZED_AT,$CONTAINERS_READY_AT,$READY_AT"
done
