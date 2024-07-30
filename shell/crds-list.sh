#!/bin/bash
##
## FILE: crds-list.sh
##
## DESCRIPTION: Lists CRDs in a Kubernetes manifest.
##
## AUTHOR: Chris Buckley (github.com/chrisbuckleycode)
##
## USAGE: crds-list.sh <manifest.yaml>
##

input_file=$1

if [ ! -f "$input_file" ]; then
    echo "Input file not found"
    exit 1
fi

echo "CRDS"

yq e '.spec.names.kind' "$input_file" | grep -v '^---$'
