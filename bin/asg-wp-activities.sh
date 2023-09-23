#!/bin/bash

# Ensure that two parametrers were passed - the asg group name and the number of hours ago
if [ -z "$1" ] || [ -z "$2" ]; then
  echo "usage: warm-pool-activities.sh <asg-name> <hours-ago>"
  exit 1
fi  

# Define the Auto Scaling Group name
auto_scaling_group_name="$1"

# Define the number of hours ago
hours_ago="$2"

# Calculate the start time for the last hour in ISO 8601 format
start_time=$(date -u --date='-'"${hours_ago}"' hours' '+%Y-%m-%dT%H:%M:%S')


# AWS CLI command to describe scaling activities and filter by start time
# activities=$(aws autoscaling describe-scaling-activities --auto-scaling-group-name "$auto_scaling_group_name" \
#   --query "Activities[?StartTime >= '$start_time'].{Description: Description, StartTime: StartTime, EndTime: EndTime, Progress: Progress, Cause: Cause}" \
#   --output json)

# Get the scaling activities in the last x hours
activities=$(aws autoscaling describe-scaling-activities --auto-scaling-group-name "$auto_scaling_group_name" | jq -c --arg start_time "$start_time" '.Activities[] | select(.StartTime >= $start_time)')


# Check if there are any activities
if [ -n "$activities" ]; then
  echo "Start Time|End Time|Duration (s)|Status|Description|Cause"

  # Process each activity
  while read -r activity; do
    # Extract values from the JSON
    description=$(echo "$activity" | jq -r '.Description')
    start_time=$(echo "$activity" | jq -r '.StartTime')
    end_time=$(echo "$activity" | jq -r '.EndTime')
    status=$(echo "$activity" | jq -r '.StatusCode')
    cause=$(echo "$activity" | jq -r '.Cause')

    # Calculate the duration in seconds
    start_timestamp=$(date -u -d "$start_time" '+%s')
    end_timestamp=$(date -u -d "$end_time" '+%s')
    duration=$((end_timestamp - start_timestamp))

    # Print the values in CSV format
    echo "$start_time|$end_time|$duration|$status|$description|$cause"
  done <<< "$activities"

else
  echo "No activities found in the last hour."
fi