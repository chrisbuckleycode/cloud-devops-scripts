#!/bin/bash
##
## FILE: node-top.sh
##
## DESCRIPTION: Displays a node's pods, sorted by CPU usage. Similar to kubectl get nodes.
##
## AUTHOR: Chris Buckley (github.com/chrisbuckleycode)
##
## USAGE: load-average.sh <node>
##

# Check for missing arguments
if [ $# -eq 0 ]; then
    echo "Error: Missing argument. Please provide a kubernetes node as the first argument."
    exit 1
fi

# Script's first argument, kubernetes node name
node=$1

# List of pods on the node
pods=$(kubectl get pods --all-namespaces -o wide --field-selector spec.nodeName=$node | awk '{print $2}')

# Namespace, Pod Name, CPU, Memory
top_pods=$(kubectl top pod --all-namespaces)

# top_pods but only those pods seen on node
filtered_pods=$(echo "$top_pods" | grep -Ff <(echo "$pods"))

# Keep header, reverse sort column 3 (CPU)
header=$(echo "$filtered_pods" | head -n 1)
sorted_pods=$(echo "$filtered_pods" | tail -n +2 | sort -k3 -r -n)

# Output to console
echo "$header"
echo "$sorted_pods"
