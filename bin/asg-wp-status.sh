#!/bin/bash

aws autoscaling describe-warm-pool --auto-scaling-group-name $1 | jq -r '.Instances[]| "\(.InstanceId)\t\(.LifecycleState)"'
