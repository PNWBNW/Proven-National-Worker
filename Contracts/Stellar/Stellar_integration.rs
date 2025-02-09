// Stellar Integration for Direct Aleo → Stellar Payroll Transfers

use soroban_sdk::{contract, contractimpl, Address, Env, Symbol};

#[contract]
pub struct StellarBridge;

#[contractimpl]
impl StellarBridge {
    // Mapping: Aleo Worker Address → Stellar Wallet Address
    pub fn register_worker(env: Env, aleo_worker: Address, stellar_wallet: Address) {
        env.storage().instance().set(&aleo_worker, &stellar_wallet);
    }

    // Get the Stellar address of a registered worker
    pub fn get_worker_stellar_address(env: Env, aleo_worker: Address) -> Address {
        env.storage().instance().get(&aleo_worker).unwrap()
    }

    // Bridge payroll funds from Aleo to Stellar
    pub fn bridge_payroll(env: Env, employer: Address, aleo_worker: Address, amount: i128) -> bool {
        let stellar_wallet = env.storage().instance().get(&aleo_worker).unwrap();
        assert!(env.ledger().balance_of(&employer) >= amount, "Insufficient balance");

        // Transfer AleoUSDC from employer to bridge
        env.ledger().transfer(&employer, &env.current_contract_address(), amount);

        // Emit event for external bridge execution
        env.events().publish((Symbol::new("PayrollBridged"), employer, aleo_worker, stellar_wallet, amount));

        true
    }

    // Confirm Stellar payment has been executed
    pub fn confirm_stellar_payment(env: Env, aleo_worker: Address, amount: i128) -> bool {
        // Simulating an external confirmation mechanism
        env.events().publish((Symbol::new("PaymentConfirmed"), aleo_worker, amount));

        true
    }
}
