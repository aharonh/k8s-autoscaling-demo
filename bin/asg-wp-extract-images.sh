#!/bin/bash

# the parameter of this script is the label of the pod running on target node
# e.g. ./extract_images.sh app.kubernetes.io/name=algorithm-service

# ensure parameter is provided
if [ $# -eq 0 ]; then
    echo "No arguments provided"
    echo "Usage: ./extract_images.sh <label>"
    exit 1
fi

# if second paramter provided, use it as a boolean flag weather include prefix for pulling images
prefix=""
if [ $# -eq 2 ]; then
    if [ $2 = "-p" ]; then
        prefix="      sudo ctr -namespace k8s.io i pull "
    fi
fi


regex=":(v)?\d+(\.\d+)?(\.\d+)?$"

# Function to extract the preferred image name
extract_preferred_image() {
    local names=("$@")
    local preferred_image=""

    for name in "${names[@]}"; do
        if [[ $name =~ $regex ]]; then
            preferred_image="$name"
            break
        fi
        preferred_image="$name"
    done

    echo "$preferred_image"
}

# Run the kubectl command and extract the JSON data
kubectl_command="kubectl get node -o jsonpath={.status.images} $(kubectl get pod -o wide -l $1 -o jsonpath='{.items[].spec.nodeName}')"
json_data=$(eval "$kubectl_command")

# Convert JSON data to an array
data_array=()
while IFS= read -r line; do
    data_array+=("$line")
done <<< "$(echo "$json_data" | jq -c '.[]')"

# Extract and print preferred images
for entry in "${data_array[@]}"; do
    names=$(echo "$entry" | jq -r '.names[]')
    IFS=$'\n' names_array=($names)
    preferred_image=$(extract_preferred_image "${names_array[@]}")
    if [ -n "$preferred_image" ]; then
        echo "$prefix$preferred_image"
    fi
done