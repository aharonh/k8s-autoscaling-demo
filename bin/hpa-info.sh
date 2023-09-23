#!/bin/bash
# show basic hpa info, provided the hpa name

# ensure the parameters is passed
if [ $# -ne 1 ]; then
    echo "No arguments provided. Please provide the hpa name."
    echo "Usage: $0 <hpa name>"
    exit 1
fi

export HPA_NAME=$1

kubectl get hpa $HPA_NAME -o custom-columns="\
DESIRED_REP:.status.desiredReplicas,\
CURRENT_REP:.status.currentReplicas,\
AVERAGE_VALUE:.status.currentMetrics[0].external.current.averageValue,\
CURRENT_VALUE:.status.currentMetrics[0].external.current.value"
#LAST_SCALE:.status.lastScaleTime"
