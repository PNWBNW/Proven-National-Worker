import subprocess
import sys
import os

# Set variables for Aleo network and test directory paths
ALEO_NETWORK = "AleoTestnet"  # Use AleoMainnet for production testing
TEST_DIR = "./tests"  # Directory containing test files
TEST_RESULTS_DIR = "./test_results"  # Directory to store test logs
CONTRACTS = ["farm_investment", "worker_identity", "subdao"]  # List of contracts to test

# Ensure the test results directory exists
if not os.path.exists(TEST_RESULTS_DIR):
    os.makedirs(TEST_RESULTS_DIR)

def run_tests_for_contract(contract_name):
    """
    Function to run tests for a specific contract.
    """
    try:
        print(f"Running tests for contract: {contract_name} on {ALEO_NETWORK} network...")
        
        # Call the Aleo testing framework for the specific contract
        result = subprocess.run(
            ["aleo", "test", f"{TEST_DIR}/{contract_name}", "--network", ALEO_NETWORK],
            check=True,
            shell=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE
        )
        
        # Check if the tests were successful
        if result.returncode == 0:
            print(f"Tests passed for {contract_name}!")
            with open(f"{TEST_RESULTS_DIR}/{contract_name}-test-result.log", "w") as log_file:
                log_file.write(result.stdout.decode())
        else:
            print(f"Tests failed for {contract_name}!")
            with open(f"{TEST_RESULTS_DIR}/{contract_name}-test-result.log", "w") as log_file:
                log_file.write(result.stderr.decode())
            return False
    except subprocess.CalledProcessError as e:
        print(f"Error running tests for {contract_name}: {e}")
        return False

    return True

def run_all_tests():
    """
    Function to run tests for all contracts in the CONTRACTS list.
    """
    all_tests_passed = True
    for contract in CONTRACTS:
        tests_passed = run_tests_for_contract(contract)
        if not tests_passed:
            all_tests_passed = False
    
    if all_tests_passed:
        print("All tests passed!")
    else:
        print("Some tests failed. Check the test logs for details.")

if __name__ == "__main__":
    run_all_tests()
