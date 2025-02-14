import subprocess
import sys
import os

# Set Aleo network and contract directory paths
ALEO_NETWORK = "AleoTestnet"  # Use AleoMainnet for production deployments
CONTRACT_DIR = "./contracts"  # Path to the directory containing the .leo files
ALEO_CLIENT = "aleo-client"  # Assumed Aleo CLI command for deployment

def get_contract_files():
    """
    Retrieves all .leo contract files from the contract directory.
    """
    try:
        return [f for f in os.listdir(CONTRACT_DIR) if f.endswith(".leo")]
    except FileNotFoundError:
        print("❌ Error: Contract directory not found.")
        sys.exit(1)

def deploy_contract(contract_name):
    """
    Deploys a single contract to the Aleo network.
    """
    contract_path = os.path.join(CONTRACT_DIR, contract_name)
    print(f"🚀 Deploying contract: {contract_name} to {ALEO_NETWORK}...")

    try:
        result = subprocess.run(
            [ALEO_CLIENT, "deploy", contract_path, "--network", ALEO_NETWORK],
            check=False,
            capture_output=True,
            text=True
        )

        if result.returncode == 0:
            print(f"✅ {contract_name} deployed successfully!")
            print(result.stdout.strip())
            return True
        else:
            print(f"❌ Deployment failed for {contract_name}:\n{result.stderr.strip()}")
            return False
    except Exception as e:
        print(f"⚠️ Error deploying {contract_name}: {e}")
        return False

def deploy_all_contracts():
    """
    Deploys all .leo contracts found in the contract directory.
    """
    contracts = get_contract_files()

    if not contracts:
        print("⚠️ No contracts found to deploy.")
        return

    print(f"🚀 Deploying {len(contracts)} contracts to {ALEO_NETWORK}...")
    
    all_successful = True
    for contract in contracts:
        if not deploy_contract(contract):
            all_successful = False
    
    if all_successful:
        print("\n✅ All contracts deployed successfully!")
    else:
        print("\n⚠️ Some contracts failed to deploy. Check the logs.")

if __name__ == "__main__":
    deploy_all_contracts()
