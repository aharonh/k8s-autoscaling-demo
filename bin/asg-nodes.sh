#!/bin/bash

# ensure that the parameter is passed
if [ $# -eq 0 ]; then
    echo "No arguments provided. Please provide the dedicated label value."
    echo "Usage: $0 <dedicated label>"
    exit 1
fi

kubectl get node -o custom-columns="NODE:.metadata.name,STATUS:.status.conditions[?(@.type=='Ready')].status" -l dedicated=$1
