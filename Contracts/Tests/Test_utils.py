import subprocess
import json
import os

# Set variables for Aleo network and the contract paths
ALEO_NETWORK = "AleoTestnet"  # Modify as necessary for testing on the appropriate network
CONTRACT_DIR = "./contracts"  # Directory containing your .leo contracts
TEST_DIR = "./tests"  # Directory containing your test files
ALEO_CLIENT = "aleo-client"  # Assumed Aleo client CLI

def get_contract_state(contract_name):
    """
    Function to get the current state of a specific contract from the Aleo network.
    """
    try:
        print(f"Fetching current state for contract: {contract_name} on {ALEO_NETWORK} network...")
        
        # Execute the Aleo CLI command to get the state of the contract
        result = subprocess.run(
            [ALEO_CLIENT, "view", f"{contract_name}", "--network", ALEO_NETWORK],
            check=True,
            shell=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE
        )
        
        if result.returncode == 0:
            state = json.loads(result.stdout.decode())
            return state
        else:
            print(f"Failed to fetch contract state for {contract_name}!")
            return None
    except subprocess.CalledProcessError as e:
        print(f"Error fetching contract state: {e}")
        return None


def validate_contract_state(contract_name, expected_state):
    """
    Function to validate the state of a contract by comparing it to the expected state.
    """
    state = get_contract_state(contract_name)
    if state is None:
        print(f"Failed to validate contract state for {contract_name}.")
        return False
    
    # Compare the current state with the expected state
    if state == expected_state:
        print(f"Contract state for {contract_name} matches expected state.")
        return True
    else:
        print(f"Contract state for {contract_name} does NOT match expected state.")
        return False


def send_transaction(tx_data):
    """
    Function to send a transaction to the Aleo network.
    """
    try:
        print("Sending transaction to the Aleo network...")
        
        # Execute the Aleo CLI command to send the transaction
        result = subprocess.run(
            [ALEO_CLIENT, "send", tx_data, "--network", ALEO_NETWORK],
            check=True,
            shell=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE
        )
        
        if result.returncode == 0:
            print("Transaction sent successfully!")
            return True
        else:
            print(f"Failed to send transaction: {result.stderr.decode()}")
            return False
    except subprocess.CalledProcessError as e:
        print(f"Error sending transaction: {e}")
        return False


def validate_transaction_status(transaction_id):
    """
    Function to validate the status of a sent transaction.
    """
    try:
        print(f"Validating status of transaction: {transaction_id}...")
        
        # Execute Aleo CLI command to check transaction status
        result = subprocess.run(
            [ALEO_CLIENT, "status", transaction_id, "--network", ALEO_NETWORK],
            check=True,
            shell=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE
        )
        
        if result.returncode == 0:
            status = result.stdout.decode()
            if "Success" in status:
                print(f"Transaction {transaction_id} was successful.")
                return True
            else:
                print(f"Transaction {transaction_id} failed. Status: {status}")
                return False
        else:
            print(f"Failed to validate transaction status for {transaction_id}.")
            return False
    except subprocess.CalledProcessError as e:
        print(f"Error validating transaction status: {e}")
        return False
