#!/bin/bash
# shortcut for second use case to wait for all pods to become ready and collect offsets
# parameter is only the datetime when the workitems were submitted

# ensure all the parameters were passed
if [ $# -ne 1 ]; then
    echo "No arguments provided. Please provide the datetime when the workitems were submitted."
    echo "Usage: $0 <datetime when workitems submitted>"
    exit 1
fi

# get the datetime when the workitems were submitted
datetime="$1"

# wait for all the pods to become ready and collect the timings
asg-wait-and-collect.sh demo-service demo-wp.harley.systems $datetime
