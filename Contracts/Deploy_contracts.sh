#!/bin/bash

# Set variables for Aleo network deployment
ALEO_NETWORK="AleoTestnet"  # Change to Aleo mainnet when ready for production
CONTRACT_DIR="./contracts"  # Directory containing the .leo files
CONTRACTS=("farm_investment.leo" "worker_identity.leo" "subdao.leo")  # List of contract files to deploy

# Deploy each contract
for contract in "${CONTRACTS[@]}"
do
  echo "Deploying contract: $contract to $ALEO_NETWORK"
  
  # Command to deploy the contract using Aleo CLI
  aleo deploy "$CONTRACT_DIR/$contract" --network "$ALEO_NETWORK"
  
  # Check if the deployment was successful
  if [ $? -ne 0 ]; then
    echo "Failed to deploy contract: $contract"
    exit 1  # Exit the script if deployment fails for any contract
  fi
done

echo "All contracts deployed successfully."
