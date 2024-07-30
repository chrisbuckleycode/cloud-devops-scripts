#!/bin/bash
##
## FILE: load-average.sh
##
## DESCRIPTION: Monitors cpu and memory usage over a period, gets running averages without external monitoring.
##
## AUTHOR: Chris Buckley (github.com/chrisbuckleycode)
##
## USAGE: Start script in background:  load-average.sh &
##        Tail the logfile using:      tail -f monitor_output.txt
##        Restore to foreground using: fg
##

# Check if sysstat package is installed
if ! command -v mpstat &>/dev/null; then
    echo "sysstat package is not installed. Please install it using the following command:"
    echo "sudo apt-get install sysstat"
    exit 1
fi

# Check if procps package is installed
if ! command -v free &>/dev/null; then
    echo "procps package is not installed. Please install it using the following command:"
    echo "sudo apt-get install procps"
    exit 1
fi

# Time interval in seconds
interval=10

# Number of iterations
iterations=$((600 / $interval))  # 10 minutes (600 seconds)

# Output file
output_file=monitor_output.txt

# Clear output file
> "$output_file"

echo "CPU and Memory Usage Monitoring"
echo "Monitoring will run for 10 minutes with an interval of $interval seconds."
echo "Output file: $output_file"
echo "Press Ctrl+C to stop monitoring."

echo "CPU(%),Memory(%),Running Average CPU(%),Running Average Memory(%)" >> "$output_file"

cpu_sum=0
mem_sum=0
count=0

for ((i = 1; i <= $iterations; i++)); do
    # Get CPU usage percentage
    cpu_usage=$(mpstat 1 1 | awk '/Average:/ {print 100 - $NF}')

    # Get memory usage percentage
    mem_usage=$(free | awk '/Mem:/ {print $3/$2 * 100}')

    cpu_sum=$(echo "scale=2; $cpu_sum + $cpu_usage" | bc)
    mem_sum=$(echo "scale=2; $mem_sum + $mem_usage" | bc)
    count=$((count + 1))

    avg_cpu=$(echo "scale=2; $cpu_sum / $count" | bc)
    avg_mem=$(echo "scale=2; $mem_sum / $count" | bc)

    # Append to output file
    echo "$cpu_usage,$mem_usage,$avg_cpu,$avg_mem" >> "$output_file"

    sleep "$interval"
done

echo "Monitoring completed. Results saved to $output_file."
