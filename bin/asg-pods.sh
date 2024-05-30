#!/bin/bash

# ensure the parameters is passed
if [ $# -ne 1 ]; then
    echo "No arguments provided. Please provide the app.kubernetes.io/name label."
    echo "Usage: $0 <app.kubernetes.io/name label value>"
    exit 1
fi

kubectl get pods -l app.kubernetes.io/name=$1 -o custom-columns=POD:.metadata.name,STATUS:.status.phase