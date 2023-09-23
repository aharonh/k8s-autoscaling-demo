#!/bin/bash

# this script uses the scripts asg-instance-ids.sh, asg-instance-times.sh, asg-pod-times.sh and asg-node-times.sh
# to show all timing related infomration in relation to the autoscaling group and it's associated nodes and pods.
#
# usage:
# asg-instance-times.sh <asg-name>
#
# usage example:
# asg-instance-times.sh demo.harley.systems
# 
# output:
# <instance-id>,<pod-name>,<pod-scheduled-at>,<pod-initialized-at>,<instance-launch-time>,<instance-k8s-eni-attach-time>,<node-created-at>,<node-ready-at>,<pod-containers-ready-at>,<pod-ready-at>
#
# output example:
# 

# ensure the parameter was passed
if [ -z "$1" ]; then
    echo "usage: asg-all-times.sh <asg-name>"
    exit 1
fi

# if asked for help, print instructions
if [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
    echo "This script uses the scripts asg-instance-ids.sh, asg-instance-times.sh, asg-pod-times.sh and asg-node-times.sh"
    echo "to show all timing related infomration in relation to the autoscaling group and it's associated nodes and pods."
    echo "usage: asg-all-times.sh <asg-name>"
    exit 0
fi

# get temporary file path
INSTANCE_TIMINGS_FILE=$(mktemp)
NODE_TIMINGS_FILE=$(mktemp)
POD_TIMINGS_FILE=$(mktemp)

# asg-instance-times is problematic as the instance launch time
# in warm pool instances is not available. So we use asg-instance-boottimes
# that is relevant in all cases (warm pool and regular pool)
# asg-instance-times.sh $1 >> $INSTANCE_TIMINGS_FILE
asg-instance-boottimes.sh $1 >> $INSTANCE_TIMINGS_FILE
asg-node-times.sh $1 >> $NODE_TIMINGS_FILE
asg-pod-times.sh $1 >> $POD_TIMINGS_FILE


# asg-instance-boottimes.sh $G >> $INSTANCE_TIMINGS_FILE
# asg-node-times.sh $G >> $NODE_TIMINGS_FILE
# asg-pod-times.sh $G >> $POD_TIMINGS_FILE

# join the files
#
# first join fields 
# 1:
# 1.1 - instance id
# 1.2 - instance boot time
# 2:
# 2.1 - node id (=instance id)
# 2.2 - node created
# 2.3 - node ready
# out:
# 1 - instance id (=node id) 1.1
# 2 - instance launch time 1.2
# 3 - node created 2.2
# 4 - node ready 2.3
#
# second join fields
# 1:
# 1.1 - instance id (=node id)
# 1.2 - instance launch time
# 1.3 - node created
# 1.4 - node ready
# 2:
# 2.1 - instance id
# 2.2 - pod name
# 2.3 - pod created
# 2.4 - pod scheduled
# 2.5 - pod initialized
# 2.6 - pod containers ready
# 2.7 - pod ready
# out:
# 1 - instance id (=node id) 1.1
# 2 - pod name 2.2
# 3 - pod created 2.3
# 4 - instance launch time 1.2
# 5 - node created 1.3
# 6 - node ready 1.4
# 7 - pod scheduled 2.4
# 8 - pod initialized 2.5
# 9 - pod containers ready 2.6
# 10 - pod ready 2.7
join --header -t, -o1.1,1.2,2.2,2.3 \
  $INSTANCE_TIMINGS_FILE $NODE_TIMINGS_FILE \
  | join --header -t, -o1.1,2.2,2.3,1.2,1.3,1.4,2.4,2.5,2.6,2.7 \
  - $POD_TIMINGS_FILE

# remove the temporary files
rm $INSTANCE_TIMINGS_FILE
rm $NODE_TIMINGS_FILE
rm $POD_TIMINGS_FILE
