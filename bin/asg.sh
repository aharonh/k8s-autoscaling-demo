#!/bin/bash
# Prints basic info on the instances, nodes and pods that belong to an autoscaling group. 
# Recieves as it's parameter a name of an autoscaling group, value of the nodes label 'dedicated', and
# pods label 'app.kubernetes.io/name' value. 

# ensure the parameters is passed
if [ $# -ne 4 ]; then
    echo "No arguments provided. Please provide the autoscaling" \
        "group name and the app.kubernetes.io/name label value."
    echo "Usage: $0 <autoscaling group name> <nodes dedicated label value> <pods app.kubernetes.io/name label value> <hpa name>"
    exit 1
fi

# read the parameters into variables
export ASG_NAME=$1
export NODE_LABEL=$2
export APP_LABEL=$3
export HPA_NAME=$4

export INSTANCES_OUTPUT=$(mktemp)
export NODES_OUTPUT=$(mktemp)
export PODS_OUTPUT=$(mktemp)
export HPA_OUTPUT=$(mktemp)

while true; do

    # show instances info
    asg-instances.sh $ASG_NAME > $INSTANCES_OUTPUT &

    # show nodes info
    asg-nodes.sh $NODE_LABEL > $NODES_OUTPUT &


    # show pods info
    asg-pods.sh $APP_LABEL > $PODS_OUTPUT &


    # show hpa info
    hpa-info.sh $HPA_NAME > $HPA_OUTPUT &

    # wait for all to finish
    wait

    # clear the screen
    clear

    # print the header
    echo "ASG: $ASG_NAME"
    echo "Nodes: $NODE_LABEL"
    echo "Pods: $APP_LABEL"
    echo "HPA: $HPA_NAME"
    echo ""

    # print the instances info
    cat $INSTANCES_OUTPUT
    echo ""

    # print the nodes info
    cat $NODES_OUTPUT
    echo ""

    # print the pods info
    cat $PODS_OUTPUT
    echo ""

    # print the hpa info
    cat $HPA_OUTPUT
    echo ""
    
    # sleep for 3 seconds
    sleep 3

done
