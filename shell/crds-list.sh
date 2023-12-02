#!/usr/bin/env bash

input_file=$1

if [ ! -f "$input_file" ]; then
    echo "Input file not found"
    exit 1
fi

echo "CRDS"

yq e '.spec.names.kind' "$input_file" | grep -v '^---$'
