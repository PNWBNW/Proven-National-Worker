#!/bin/bash

# Set variables for deployment
STELLAR_NETWORK="testnet"
CONTRACT_PATH="./contracts/stellar/stellar_integration.wasm"
DEPLOYER_SECRET="your-stellar-secret-key"
DEPLOYER_ADDRESS="your-stellar-public-key"

echo "Deploying Stellar Soroban contract to $STELLAR_NETWORK..."

# Build the contract
soroban contract build --wasm $CONTRACT_PATH

# Deploy the contract
soroban contract deploy \
    --wasm $CONTRACT_PATH \
    --network $STELLAR_NETWORK \
    --source $DEPLOYER_SECRET \
    --address $DEPLOYER_ADDRESS

# Output contract address
CONTRACT_ADDRESS=$(soroban contract address --network $STELLAR_NETWORK --source $DEPLOYER_SECRET)
echo "Contract deployed at: $CONTRACT_ADDRESS"
