#!/bin/bash

# PNW System Smart Contract Deployment Script
# Deploys contracts for Aleo, Stellar Soroban, and EVM-based chains.

echo "Starting PNW Contract Deployment..."

# Set deployment variables
ALEO_DEPLOY_SCRIPT="./deploy_scripts/deploy_aleo.sh"
STELLAR_DEPLOY_SCRIPT="./deploy_scripts/deploy_stellar.sh"
EVM_DEPLOY_SCRIPT="./deploy_scripts/deploy_evm.sh"

LOG_FILE="deployment.log"

# Clear previous logs
rm -f $LOG_FILE

# Function to check for required dependencies
check_dependency() {
    command -v $1 >/dev/null 2>&1 || { echo >&2 "Error: $1 is required but not installed."; exit 1; }
}

# Check for dependencies
check_dependency "aleo"
check_dependency "stellar"
check_dependency "solc"
check_dependency "foundry"

# Deploy Aleo Smart Contracts
echo "🔹 Deploying Aleo Contracts..."
sh $ALEO_DEPLOY_SCRIPT | tee -a $LOG_FILE

# Deploy Stellar Soroban Smart Contracts
echo "🔹 Deploying Stellar Contracts..."
sh $STELLAR_DEPLOY_SCRIPT | tee -a $LOG_FILE

# Deploy EVM (Solidity) Smart Contracts
echo "🔹 Deploying EVM Contracts..."
sh $EVM_DEPLOY_SCRIPT | tee -a $LOG_FILE

echo "✅ Deployment Completed Successfully."
