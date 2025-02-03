import subprocess
import sys
import os

# Set Aleo network and contract directory paths
ALEO_NETWORK = "AleoTestnet"  # Use AleoMainnet for production deployments
CONTRACT_DIR = "./contracts"  # Path to the directory containing the .leo files
DEPLOY_SCRIPT = "./deploy_all.sh"  # The shell script to run for deployment

def deploy_contracts():
    """
    Function to deploy contracts using the deploy_all.sh script.
    """
    try:
        # Make sure the Aleo network is set to the desired value
        print(f"Deploying contracts to {ALEO_NETWORK} network...")
        
        # Run the shell script to deploy all contracts
        result = subprocess.run([DEPLOY_SCRIPT], check=True, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        
        # Check if deployment was successful
        if result.returncode == 0:
            print("All contracts deployed successfully!")
            print(result.stdout.decode())
        else:
            print("Deployment failed!")
            print(result.stderr.decode())
    except subprocess.CalledProcessError as e:
        print(f"Error deploying contracts: {e}")
        sys.exit(1)

if __name__ == "__main__":
    deploy_contracts()
