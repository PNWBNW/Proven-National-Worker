#!/bin/bash

# Set variables for Aleo network and contract testing
ALEO_NETWORK="AleoTestnet"  # Change to Aleo mainnet when testing in production
CONTRACT_DIR="./contracts"  # Directory containing the .leo files
TEST_DIR="./tests"  # Directory containing the test files
CONTRACTS=("farm_investment" "worker_identity" "subdao")  # List of contract names to test
TEST_RESULTS_DIR="./test_results"  # Directory to store test results

# Ensure the test results directory exists
mkdir -p "$TEST_RESULTS_DIR"

# Loop through each contract and run the corresponding tests
for contract in "${CONTRACTS[@]}"
do
  echo "Running tests for contract: $contract on $ALEO_NETWORK"

  # Command to execute the tests using Aleo's testing framework (or a custom test command)
  aleo test "$TEST_DIR/$contract" --network "$ALEO_NETWORK" > "$TEST_RESULTS_DIR/$contract-test-result.log"
  
  # Check if the tests were successful
  if [ $? -ne 0 ]; then
    echo "Tests failed for contract: $contract"
    exit 1  # Exit the script if any test fails
  else
    echo "Tests passed for contract: $contract"
  fi
done

# Summarize the test results
echo "All tests completed. Check the '$TEST_RESULTS_DIR' directory for detailed logs."
