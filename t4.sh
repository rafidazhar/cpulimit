#!/bin/bash

# Desired CPU limit in percentage
CPU_LIMIT=18000

# Function to check if apoolminer is running
check_apoolminer() {
    pgrep apoolminer
}

# Function to check if cpulimit is already applied
is_cpulimit_applied() {
    local pid=$1
    pgrep -f "cpulimit -p $pid" > /dev/null
}

# Function to apply CPU limit using cpulimit
apply_cpu_limit() {
    local pid=$1
    echo "Applying CPU limit of $CPU_LIMIT% to process ID $pid..."
    nohup cpulimit -p "$pid" -l "$CPU_LIMIT" -z > /dev/null 2>&1 &
}

# Monitor apoolminer
while true; do
    AP_POOL_PID=$(check_apoolminer)
    if [ -n "$AP_POOL_PID" ]; then
        echo "apoolminer detected with PID(s): $AP_POOL_PID"
        for PID in $AP_POOL_PID; do
            if ! is_cpulimit_applied $PID; then
                apply_cpu_limit $PID
            else
                echo "CPU limit is already applied to PID $PID."
            fi
        done
    else
        echo "apoolminer not running."
    fi
    sleep 5 # Adjust monitoring interval as needed
done
