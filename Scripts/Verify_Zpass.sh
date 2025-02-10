#!/bin/bash

# PNW System - ZPass Verification Script
# This script verifies ZPass identity for workers before payroll processing.

echo "🚀 Starting ZPass Verification..."

# Set worker identity contract API
WORKER_IDENTITY_API="https://api.pnw-system.com/verify_zpass"

LOG_FILE="zpass_verification.log"

# Clear previous logs
rm -f $LOG_FILE

# Function to check if a required command is installed
check_dependency() {
    command -v "$1" >/dev/null 2>&1 || { echo >&2 "❌ Error: $1 is required but not installed."; exit 1; }
}

# Check for required dependencies
check_dependency "curl"
check_dependency "jq"

# Function to verify a worker's ZPass
verify_zpass() {
    local worker_id=$1
    echo "🔍 Verifying ZPass for Worker: $worker_id..."
    
    response=$(curl -s --max-time 10 -X POST -H "Content-Type: application/json" -d '{"worker_id": "'$worker_id'"}' $WORKER_IDENTITY_API)

    # Check for timeout or failed API response
    if [ $? -ne 0 ]; then
        echo "❌ Error: API request failed or timed out." | tee -a $LOG_FILE
        exit 1
    fi

    verified=$(echo "$response" | jq -r '.verified')

    if [[ "$verified" == "true" ]]; then
        echo "✅ Worker $worker_id is ZPass Verified!" | tee -a $LOG_FILE
        return 0
    else
        echo "❌ Worker $worker_id failed ZPass Verification." | tee -a $LOG_FILE
        return 1
    fi
}

# Check if a worker ID is provided
if [ -z "$1" ]; then
    echo "❌ Error: Please provide a Worker ID."
    echo "Usage: sh verify_zpass.sh <worker_id>"
    exit 1
fi

# Run verification
verify_zpass "$1"

echo "✅ ZPass Verification Completed."
