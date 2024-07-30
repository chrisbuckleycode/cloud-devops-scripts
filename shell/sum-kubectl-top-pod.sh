#!/bin/bash
##
## FILE: sum-kubectl-top-pod.sh
##
## DESCRIPTION: Runs "kubectl top pod -A" and sums the CPU and Memory columns.
##
## AUTHOR: Chris Buckley (github.com/chrisbuckleycode)
##
## USAGE: sum-kubectl-top-pod.sh
##

# TODO(chrisbuckleycode): Add check for kubectl

# Run the kubectl command and store the output in a variable
output=$(kubectl top pod -A)

total_cpu=0
total_memory=0

# Read each line of the command output
while IFS= read -r line; do
  # Skip the header line
  if [[ ! $line =~ CPU ]]; then
    # Extract the CPU and memory values from the line
    cpu=$(echo "$line" | awk '{print $2}' | tr -d '[:alpha:]')
    memory=$(echo "$line" | awk '{print $3}' | tr -d '[:alpha:]')
    total_cpu=$((total_cpu + cpu))
    total_memory=$((total_memory + memory))
  fi
done <<< "$output"

echo "Total CPU: ${total_cpu}m"
echo "Total Memory: ${total_memory}Mi"
