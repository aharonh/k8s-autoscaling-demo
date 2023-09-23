#!/bin/bash
# the script collects instance boot times for the given autoscaling group instances
# usage:
# asg-instance-boottimes.sh <asg-name>
# example usage:
# asg-instance-boottimes.sh demo.harley.systems
# example output:
# i-0f1d6d348d8d50b2e,2023-09-01T19:45:47Z

# ensure the parameter was passed
if [ -z "$1" ]; then
    echo "usage: asg-instance-boottimes.sh <asg-name>"
    exit 1
fi

# if asked for help, print instructions
if [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
    echo "The script collects instance boot times for the given autoscaling group instances."
    echo "usage: asg-instance-boottimes.sh <asg-name>"
    exit 0
fi

# get list of asg instace ids
INSTANCE_IDS=( $(asg-instance-ids.sh $1) )

echo "INSTANCE-ID,INSTANCE-BOOT-TIME"
for instance_id in "${INSTANCE_IDS[@]}"; do

    # retrieve node ip
    INSTANCE_IP=$(aws ec2 describe-instances --instance-ids $instance_id \
        --query 'Reservations[*].Instances[*].[PrivateIpAddress]' \
        | jq -r '.[0][0][0]')

    BOOT_TIME=$(ssh $INSTANCE_IP "awk '{if (\$1 == \"btime\") print \$2}' /proc/stat \
| xargs -I{} date -d @{} +'%Y-%m-%dT%H:%M:%SZ'")

    echo $instance_id","$BOOT_TIME
done