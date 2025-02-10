#!/bin/bash

# PNW System - ANS Verification Script
# This script verifies ANS identity for workers & employers before payroll processing.

echo "🚀 Starting ANS Verification..."

# Set ANS contract API
ANS_VERIFICATION_API="https://api.pnw-system.com/verify_ans"

LOG_FILE="ans_verification.log"

# Clear previous logs
rm -f $LOG_FILE

# Function to check if a required command is installed
check_dependency() {
    command -v "$1" >/dev/null 2>&1 || { echo >&2 "❌ Error: $1 is required but not installed."; exit 1; }
}

# Check for required dependencies
check_dependency "curl"
check_dependency "jq"

# Function to verify ANS identity
verify_ans() {
    local ans_name=$1
    echo "🔍 Verifying ANS Name: $ans_name..."
    
    response=$(curl -s --max-time 10 -X POST -H "Content-Type: application/json" -d '{"ans_name": "'$ans_name'"}' $ANS_VERIFICATION_API)

    # Check for timeout or failed API response
    if [ $? -ne 0 ]; then
        echo "❌ Error: API request failed or timed out." | tee -a $LOG_FILE
        exit 1
    fi

    verified=$(echo "$response" | jq -r '.verified')

    if [[ "$verified" == "true" ]]; then
        echo "✅ ANS Name $ans_name is Verified!" | tee -a $LOG_FILE
        return 0
    else
        echo "❌ ANS Name $ans_name failed Verification." | tee -a $LOG_FILE
        return 1
    fi
}

# Check if an ANS name is provided
if [ -z "$1" ]; then
    echo "❌ Error: Please provide an ANS Name."
    echo "Usage: sh verify_ans.sh <ans_name>"
    exit 1
fi

# Run verification
verify_ans "$1"

echo "✅ ANS Verification Completed."
