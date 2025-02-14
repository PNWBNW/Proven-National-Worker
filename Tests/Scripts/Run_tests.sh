#!/bin/bash

# PNW System Smart Contract Testing Script
# Runs unit and integration tests for Aleo, Stellar Soroban, and EVM (Solidity).

echo "🚀 Starting PNW Contract Testing..."

# Set test script locations
ALEO_TEST_SCRIPT="./test_scripts/test_aleo.sh"
STELLAR_TEST_SCRIPT="./test_scripts/test_stellar.sh"
EVM_TEST_SCRIPT="./test_scripts/test_evm.sh"

LOG_FILE="test_results.log"

# Clear previous logs
rm -f $LOG_FILE

# Function to check for required dependencies
check_dependency() {
    command -v $1 >/dev/null 2>&1 || { echo >&2 Error: $1 is required but not installed."; exit 1; }
}

# Check for dependencies
check_dependency "aleo"
check_dependency "stellar"
check_dependency "solc"
check_dependency "foundry"

# Run Aleo Smart Contract Tests
echo "🔹 Running Aleo Tests..."
sh $ALEO_TEST_SCRIPT | tee -a $LOG_FILE

# Run Stellar Soroban Smart Contract Tests
echo "🔹 Running Stellar Tests..."
sh $STELLAR_TEST_SCRIPT | tee -a $LOG_FILE

# Run EVM (Solidity) Smart Contract Tests
echo "🔹 Running EVM Tests..."
sh $EVM_TEST_SCRIPT | tee -a $LOG_FILE

echo "✅ Testing Completed Successfully."
