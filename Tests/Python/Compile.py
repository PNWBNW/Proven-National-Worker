import subprocess
import os
import sys
import concurrent.futures

# 🚀 PNW System - Smart Contract Compilation Script (Python Version)
# ✅ Compiles contracts for Aleo, Stellar Soroban, and Noir.

# Compilation commands for each platform
COMPILE_COMMANDS = {
    "Aleo": ["aleo", "build"],
    "Stellar": ["soroban", "build"],
    "Noir": ["nargo", "build"]
}

LOG_FILE = "compilation.log"

# ✅ Clear previous logs
if os.path.exists(LOG_FILE):
    os.remove(LOG_FILE)

def log_message(message):
    """Writes a message to both console and log file."""
    print(message)
    with open(LOG_FILE, "a") as log:
        log.write(message + "\n")

def check_dependency(command):
    """Checks if a required dependency is installed."""
    try:
        subprocess.run([command, "--version"], check=True, capture_output=True, text=True)
        return True
    except FileNotFoundError:
        log_message(f"❌ Error: {command} is required but not installed.")
        sys.exit(1)
    except subprocess.CalledProcessError:
        log_message(f"⚠️ Warning: {command} found but may not be properly configured.")
        return False

def compile_contract(platform, command):
    """Compiles smart contracts for a specific platform."""
    log_message(f"🔹 Compiling {platform} Contracts...")

    try:
        result = subprocess.run(command, check=True, capture_output=True, text=True)
        log_message(f"✅ {platform} Compilation Successful!\n{result.stdout}")
    except subprocess.CalledProcessError as e:
        log_message(f"❌ Error: {platform} Compilation Failed!\n{e.stderr}")
        sys.exit(1)

def compile_all_contracts():
    """Runs all compilations in parallel."""
    # ✅ Check dependencies before compiling
    for platform in COMPILE_COMMANDS:
        check_dependency(COMPILE_COMMANDS[platform][0])

    log_message("🚀 Starting PNW Contract Compilation...")

    # ✅ Run compilations in parallel
    with concurrent.futures.ThreadPoolExecutor() as executor:
        futures = {executor.submit(compile_contract, platform, cmd): platform for platform, cmd in COMPILE_COMMANDS.items()}
        
        for future in concurrent.futures.as_completed(futures):
            platform = futures[future]
            try:
                future.result()  # This will raise any exceptions that occurred during execution
            except Exception as e:
                log_message(f"⚠️ Error compiling {platform}: {e}")

    log_message("✅ All Compilations Completed Successfully!")

if __name__ == "__main__":
    compile_all_contracts()
