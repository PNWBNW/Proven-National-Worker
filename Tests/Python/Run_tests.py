import subprocess
import os

# Set variables for Aleo network and test directory paths
ALEO_NETWORK = "AleoTestnet"  # Use "AleoMainnet" for production testing
TEST_DIR = "./tests"  # Directory containing test files
TEST_RESULTS_DIR = "./test_results"  # Directory to store test logs

# Ensure the test results directory exists
os.makedirs(TEST_RESULTS_DIR, exist_ok=True)

def get_contracts():
    """
    Dynamically retrieves all contract names from the test directory.
    Assumes each contract has its own subdirectory within the tests folder.
    """
    return [name for name in os.listdir(TEST_DIR) if os.path.isdir(os.path.join(TEST_DIR, name))]

def run_tests_for_contract(contract_name):
    """
    Function to run tests for a specific contract.
    """
    try:
        print(f"Running tests for contract: {contract_name} on {ALEO_NETWORK} network...")
        
        # Construct the test command
        test_command = ["aleo", "test", os.path.join(TEST_DIR, contract_name), "--network", ALEO_NETWORK]

        # Run the command
        result = subprocess.run(
            test_command,
            check=False,  # Allow checking output even on failure
            capture_output=True,
            text=True  # Ensures output is decoded properly
        )

        # Store the test results
        log_file_path = os.path.join(TEST_RESULTS_DIR, f"{contract_name}-test-result.log")
        with open(log_file_path, "w") as log_file:
            if result.returncode == 0:
                print(f"✅ Tests passed for {contract_name}!")
                log_file.write(result.stdout)
            else:
                print(f"❌ Tests failed for {contract_name}! Check the log: {log_file_path}")
                log_file.write(result.stderr)
                return False
    except Exception as e:
        print(f"⚠️ Error running tests for {contract_name}: {e}")
        return False

    return True

def run_all_tests():
    """
    Function to run tests for all contracts found in the test directory.
    """
    contracts = get_contracts()

    if not contracts:
        print("⚠️ No test directories found in the test folder!")
        return
    
    all_tests_passed = True
    for contract in contracts:
        if not run_tests_for_contract(contract):
            all_tests_passed = False
    
    if all_tests_passed:
        print("\n✅ All tests passed!")
    else:
        print("\n❌ Some tests failed. Check the test logs for details.")

if __name__ == "__main__":
    run_all_tests()
