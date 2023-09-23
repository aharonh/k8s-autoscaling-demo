#!/bin/bash

# wait for all the pods in an autoscaling group to become ready
# then collect the timings using asg-all-offsets.sh
# the parameters are 
# 1. the label selector
# 2. the name of the autoscaling group
# 3. the datetime when the workitems were submitted
#
# usage:
# asg-wait-and-collect.sh <label-selector> <asg-name> <datetime when workitems submitted>


# ensure all the parameters were passed
if [ $# -ne 3 ]; then
    echo "No arguments provided. Please provide the label selector, the autoscaling group name and the datetime when the workitems were submitted."
    echo "Usage: $0 <app.kubernetes.io/name label value> <asg-name> <datetime when workitems submitted>"
    exit 1
fi

# Define the label selector and namespace
label_selector="app.kubernetes.io/name=$1"

asg_name="$2"

datetime="$3"

# Define the desired pod readiness condition
desired_condition="1/1"

# Define the polling interval (in seconds)
poll_interval=2

# Wait for all pods with the specified label to become ready
while true; do
    # Get the list of pods matching the label selector and their readiness status
    pods=$(kubectl get pods -l $label_selector --no-headers)

    # Check if all pods are ready
    all_ready=true
    while read -r line; do
        readiness=$(echo $line | awk '{print $2}')
        if [ "$readiness" != "$desired_condition" ]; then
            all_ready=false
            break
        fi
    done <<< "$pods"

    # If all pods are ready, exit the loop
    if [ "$all_ready" = true ]; then
        echo "All pods with label '$label_selector' are ready."
        break
    fi

    # Sleep for the polling interval before checking again
    sleep $poll_interval
done

# Collect the timings
asg-all-offsets.sh $asg_name $datetime
