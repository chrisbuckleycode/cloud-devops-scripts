#!/bin/bash
##
## FILE: outlier-find.sh
##
## DESCRIPTION: Find outlier processes and display their statistics.
##
## AUTHOR: Chris Buckley (github.com/chrisbuckleycode)
##
## USAGE: outlier-find.sh
##

# TODO(chrisbuckleycode): Add check for installed package then remove comment below
# - Install pre-requisites e.g.
#     sudo yum install -y sysstat
#     sudo apt install -y sysstat

# TODO(chrisbuckleycode): Modify the z_score lower/upper bounds to catch more/fewer outliers

# Define the table variable
# Note: tested for Ubuntu. Yum/CentOS pidstat uses different column numbers
# - Edit 'table' below to customize or add your own new commands
table="Command,First_rows_to_ignore,Stat_name,Stat_column_number,Label_1_name,Label_1_column_number,Label_2_name,Label_2_column_number,z_score_lower_bound,z_score_upper_bound
pidstat -d,3,kB_rd/s,5,PID,4,Command,9,-3,3
pidstat -d,3,kB_wr/s,6,PID,4,Command,9,-3,3
pidstat -d,3,kB_ccwr/s,7,PID,4,Command,9,-3,3
pidstat,3,%CPU,9,PID,4,Command,11,-3,3
pidstat -r,3,%MEM,9,PID,4,Command,10,-3,3
"

# Split the table into rows
IFS=$'\n' read -rd '' -a rows <<<"$table"

# Loop through each row (skipping the header)
for ((i = 1; i < ${#rows[@]}; i++)); do
  row="${rows[$i]}"

  # Split the row into columns
  IFS=',' read -ra columns <<<"$row"

  # Retrieve the values from the columns
  command="${columns[0]}"
  ignore_rows="${columns[1]}"
  stat_name="${columns[2]}"
  stat_column="${columns[3]}"
  label1_name="${columns[4]}"
  label1_column="${columns[5]}"
  label2_name="${columns[6]}"
  label2_column="${columns[7]}"
  z_score_lower_bound="${columns[8]}"
  z_score_upper_bound="${columns[9]}"

  # Execute the command and store the output in a variable
  output=$(eval "$command")

  # Remove the first N rows
  output=$(echo "$output" | tail -n +$((ignore_rows + 1)))

  # Calculate the mean and standard deviation of the stat column
  mean=$(echo "$output" | awk '{sum += $'$stat_column'} END {printf "%.2f", sum/NR}')
  stddev=$(echo "$output" | awk -v mean="$mean" '{sumsq += ($'$stat_column' - mean)^2} END {printf "%.2f", sqrt(sumsq/NR)}')

  # Loop through each row of the output
  while IFS= read -r line; do
    # Calculate the z-score for the stat column value
    value=$(echo "$line" | awk '{print $'$stat_column'}')
    z_score=$(awk -v value="$value" -v mean="$mean" -v stddev="$stddev" 'BEGIN {print (value - mean) / stddev}')

    # Check if the z-score is significant
    if (( $(awk -v z_score="$z_score" -v z_score_lower_bound="$z_score_lower_bound" -v z_score_upper_bound="$z_score_upper_bound" 'BEGIN {print (z_score > z_score_upper_bound || z_score < z_score_lower_bound) ? 1 : 0}') )); then
      # Print the outlier information
      label1_value=$(echo "$line" | awk '{print $'$label1_column'}')
      label2_value=$(echo "$line" | awk '{print $'$label2_column'}')
      echo "Outlier: ($command) $stat_name = $value (Mean: $mean, StdDev: $stddev), $label1_name = $label1_value, $label2_name = $label2_value"
    fi
  done <<<"$output"
  echo # Separator newline
done
