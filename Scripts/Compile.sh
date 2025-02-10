#!/bin/bash

# PNW System - Smart Contract Compilation Script
# Compiles smart contracts for Aleo, Stellar Soroban, and EVM (Solidity).

echo "🚀 Starting PNW Contract Compilation..."

# Set compile script locations
ALEO_COMPILE_SCRIPT="./compile_scripts/compile_aleo.sh"
STELLAR_COMPILE_SCRIPT="./compile_scripts/compile_stellar.sh"
EVM_COMPILE_SCRIPT="./compile_scripts/compile_evm.sh"

LOG_FILE="compilation.log"

# Clear previous logs
rm -f "$LOG_FILE"

# Function to check for required dependencies
check_dependency() {
    command -v "$1" >/dev/null 2>&1 || { echo >&2 "❌ Error: $1 is required but not installed."; exit 1; }
}

# ✅ Check for dependencies
check_dependency "aleo"
check_dependency "stellar"
check_dependency "solc"
check_dependency "foundry"

# ✅ Function to compile contracts with error handling
compile_contracts() {
    local script=$1
    local name=$2

    echo "🔹 Compiling $name Contracts..."
    if sh "$script" 2>&1 | tee -a "$LOG_FILE"; then
        echo "✅ $name Compilation Successful!" | tee -a "$LOG_FILE"
    else
        echo "❌ Error: $name Compilation Failed!" | tee -a "$LOG_FILE"
        exit 1
    fi
}

# ✅ Run all compilation scripts in parallel for faster execution
compile_contracts "$ALEO_COMPILE_SCRIPT" "Aleo" &
compile_contracts "$STELLAR_COMPILE_SCRIPT" "Stellar Soroban" &
compile_contracts "$EVM_COMPILE_SCRIPT" "EVM (Solidity)" &

# ✅ Wait for all compilation processes to complete
wait

echo "✅ All Compilations Completed Successfully!"
