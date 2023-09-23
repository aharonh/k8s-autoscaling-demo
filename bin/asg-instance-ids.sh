#!/bin/bash

# provided autoscaling group name, the script lists the ec2 instance ids that belong to the autoscaling group
#
# usage:
# asg-instance-ids.sh <asg-name>
#
# example usage:
# asg-instance-ids.sh demo.harley.systems
#
# example output:
# i-0f1d6d348d8d50b2e

# ensure the parameter was passed
if [ -z "$1" ]; then
    echo "usage: asg-instance-ids.sh <asg-name>"
    exit 1
fi

# if asked for help, print instructions
if [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
    echo "Provided autoscaling group name, the script lists the ec2 instance ids that belong to the autoscaling group."
    echo "usage: asg-instance-ids.sh <asg-name>"
    exit 0
fi

# get list of asg instace ids
aws autoscaling describe-auto-scaling-groups \
  --query "AutoScalingGroups[].Instances[].[InstanceId]" \
  --auto-scaling-group-names $1 | jq -r '.[][]'


