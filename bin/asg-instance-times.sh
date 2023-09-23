#!/bin/bash
# provided an autoscaling group name, this script shows the timing information about each node
# for each instance in the group, it shows the time it was launched, and the time k8s attached additional eni interface 
# and the difference between those two times in seconds
#
# usage:
# asg-instance-times.sh <asg-name>
#
# usage example:
# asg-instance-times.sh demo.harley.systems
#
# output:
# <instance-id>,<launch-time>,<k8s-eni-attach-time>
#
# output example:
# INSTANCE-ID,INSTANCE-LAUNCHED-AT,INSTANCE-K8S-ENI-AT
# i-0f1d6d348d8d50b2e,2023-09-01T19:44:10+00:00,2023-09-01T19:46:12+00:00

# ensure the parameter was passed
if [ -z "$1" ]; then
    echo "usage: asg-instance-times.sh <asg-name>"
    exit 1
fi

# if asked for help, print instructions
if [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
    echo "provided an autoscaling group name, this script shows the timing information about each node"
    echo "for each instance in the group, it shows the time it was launched, and the time k8s attached additional eni interface "
    echo "and the difference between those two times in seconds"
    echo "usage: asg-instance-times.sh <asg-name>"
    exit 0
fi

# get list of asg instace ids
INSTANCE_IDS=( $(asg-instance-ids.sh $1) )

echo "INSTANCE-ID,INSTANCE-LAUNCHED-AT,INSTANCE-K8S-ENI-AT"
for instance_id in "${INSTANCE_IDS[@]}"; do

    INSTANCE_TIMES=$( \
      aws ec2 describe-instances --instance-ids $instance_id \
      --query 'Reservations[*].Instances[*].[LaunchTime,NetworkInterfaces[*].Attachment.AttachTime]' \
      | jq -r '.[0][0][1] | sort | "\(.[0]),\(.[1])"')
    
    LAUNCHED=$(echo $INSTANCE_TIMES | cut -d, -f1)
    LAUNCHED=$(date -d "$LAUNCHED" -u '+%Y-%m-%dT%H:%M:%SZ')
    K8S_ENI=$(echo $INSTANCE_TIMES | cut -d, -f2)
    K8S_ENI=$(date -d "$K8S_ENI" -u '+%Y-%m-%dT%H:%M:%SZ')

    echo $instance_id","$LAUNCHED","$K8S_ENI \
    | awk -F ',' '{ OFS = ","; "date -d "$3" +%s"|getline kubenode; "date -d "$2" +%s"|getline launch; print $1, $2, $3, kubenode-launch}'
done 