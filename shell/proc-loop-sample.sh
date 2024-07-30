#!/bin/bash
##
## FILE: proc-loop-sample.sh
##
## DESCRIPTION: Loops over "status" file in each process directory in /proc, returns table sorted by requested stat e.g., "VmPeak", "VmSize", "VmRSS", etc.
##
## AUTHOR: Chris Buckley (github.com/chrisbuckleycode)
##
## USAGE: proc-loop-sample.sh <stat> e.g. proc-loop-sample.sh VmRSS
##

# - Tested for virtual memory related stats. Awk command/unit handling may fail for others.

# Check for the existence of required external programs
required_programs=("sort" "awk" "grep" "sed")
for program in "${required_programs[@]}"; do
  if ! command -v "$program" >/dev/null 2>&1; then
    echo "Error: $program is not installed."
    exit 1
  fi
done

# Check if the selected_item argument is provided
if [[ -z $1 ]]; then
  echo "Error: Missing argument."
  echo "Usage: $0 <selected_item>"
  echo "(e.g., "VmPeak", "VmSize", "VmRSS", etc.)"
  exit 1
fi

# List all directories with numerical names in /proc
proc_directories=$(find /proc -maxdepth 1 -type d -name '[0-9]*' 2>/dev/null)

# Store the numerical names in an array for later use
directories=()
while IFS= read -r directory; do
  directories+=("$directory")
done <<< "$proc_directories"

# Function to extract values from status file according to a specified key
extract_value() {
  local key=$1
  local file=$2
  grep -w "$key" "$file" | awk '{print $2}'
}

# Get the selected_item from command-line argument
selected_item=$1

# Assemble and print the process table
echo "Name    PID     $selected_item (kB)"
echo "--------------------------"
for directory in "${directories[@]}"; do
  status_file="$directory/status"

  # Check if the status file exists
  if [[ -f "$status_file" ]]; then
    name=$(extract_value "Name:" "$status_file")
    pid=$(extract_value "Pid:" "$status_file")
    selected_value=$(extract_value "$selected_item:" "$status_file")

    # Print the process details
    printf "%-8s%-8s%-12s\n" "$name" "$pid" "$selected_value"
  fi
done | sort -rnk3

exit 0
