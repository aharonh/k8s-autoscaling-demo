#!/bin/bash
# provided an autoscaling group name. this script will display a table with short info
# about the state of the group instances
echo -e 'INSTANCE-ID\t\tLIFECYCLE-STATE'
aws autoscaling describe-auto-scaling-groups \
    --query "AutoScalingGroups[].Instances[].[InstanceId,LifecycleState]" \
    --output json --auto-scaling-group-names $1 \
    | jq -r '.[] | @tsv'
