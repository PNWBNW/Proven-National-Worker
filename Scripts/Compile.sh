#!/bin/bash

# PNW System Smart Contract Compilation Script
# Compiles smart contracts for Aleo, Stellar Soroban, and EVM (Solidity).

echo "Starting PNW Contract Compilation..."

# Set compile script locations
ALEO_COMPILE_SCRIPT="./compile_scripts/compile_aleo.sh"
STELLAR_COMPILE_SCRIPT="./compile_scripts/compile_stellar.sh"
EVM_COMPILE_SCRIPT="./compile_scripts/compile_evm.sh"

LOG_FILE="compilation.log"

# Clear previous logs
rm -f $LOG_FILE

# Function to check for required dependencies
check_dependency() {
    command -v $1 >/dev/null 2>&1 || { echo >&2 "❌ Error: $1 is required but not installed."; exit 1; }
}

# Check for dependencies
check_dependency "aleo"
check_dependency "stellar"
check_dependency "solc"
check_dependency "foundry"

# Compile Aleo Smart Contracts
echo "🔹 Compiling Aleo Contracts..."
sh $ALEO_COMPILE_SCRIPT | tee -a $LOG_FILE

# Compile Stellar Soroban Smart Contracts
echo "🔹 Compiling Stellar Contracts..."
sh $STELLAR_COMPILE_SCRIPT | tee -a $LOG_FILE

# Compile EVM (Solidity) Smart Contracts
echo "🔹 Compiling EVM Contracts..."
sh $EVM_COMPILE_SCRIPT | tee -a $LOG_FILE

echo "✅ Compilation Completed Successfully."
