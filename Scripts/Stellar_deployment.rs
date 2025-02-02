#!/bin/bash  

# Stellar Soroban Contract Deployment Script  
# Deploys the Stellar payroll verification smart contract  

# Configuration  
NETWORK="testnet"  
WASM_FILE="stellar_verifier.wasm"  
CONTRACT_ID_FILE="stellar_contract_id.txt"  

echo "🚀 Starting Stellar Soroban contract deployment..."  

# Ensure Soroban CLI is installed  
if ! command -v soroban &> /dev/null  
then  
    echo "❌ Soroban CLI not found. Install it first: https://soroban.stellar.org/"  
    exit 1  
fi  

# Check if WASM file exists  
if [ ! -f "$WASM_FILE" ]; then  
    echo "❌ WASM file not found: $WASM_FILE"  
    exit 1  
fi  

# Deploy contract to Stellar network  
echo "📡 Deploying contract to Stellar $NETWORK..."  
CONTRACT_ID=$(soroban contract deploy --wasm "$WASM_FILE" --network "$NETWORK")  

if [ $? -ne 0 ]; then  
    echo "❌ Contract deployment failed."  
    exit 1  
fi  

# Store contract ID for later use  
echo "$CONTRACT_ID" > "$CONTRACT_ID_FILE"  
echo "✅ Deployment successful! Contract ID: $CONTRACT_ID"  
echo "🔹 Contract ID saved to $CONTRACT_ID_FILE"  

# Verify contract deployment  
echo "🔍 Verifying contract deployment..."  
soroban contract invoke --id "$CONTRACT_ID" --network "$NETWORK" --fn test_deploy  

if [ $? -ne 0 ]; then  
    echo "❌ Contract verification failed."  
    exit 1  
fi  

echo "🎉 Stellar Soroban contract deployed and verified successfully!"
