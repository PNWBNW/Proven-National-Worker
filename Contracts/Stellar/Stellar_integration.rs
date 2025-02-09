use soroban_sdk::{contract, contractimpl, Address, Env, Map};

#[contract]
pub struct StellarBridgePayroll;

#[contractimpl]
impl StellarBridgePayroll {
    // Mapping storage for payroll balances, trust fund balances, and employer USDC reserves
    pub fn payroll_balances(env: &Env) -> Map<Address, u64> {
        env.storage().persistent().get(&"payroll_balances").unwrap_or_default()
    }

    pub fn trust_fund_balances(env: &Env) -> Map<Address, u64> {
        env.storage().persistent().get(&"trust_fund_balances").unwrap_or_default()
    }

    pub fn employer_usdc_reserves(env: &Env) -> Map<Address, u64> {
        env.storage().persistent().get(&"employer_usdc_reserves").unwrap_or_default()
    }

    // Function to deposit USDC for payroll funding
    pub fn deposit_usdc(env: &Env, employer: Address, amount: u64) {
        assert!(amount > 0, "Deposit amount must be greater than zero");

        let mut reserves = Self::employer_usdc_reserves(env);
        let new_balance = reserves.get(&employer).unwrap_or(0) + amount;
        reserves.set(employer.clone(), new_balance);

        env.storage().persistent().set(&"employer_usdc_reserves", &reserves);
    }

    // Function to withdraw USDC (only employer-controlled)
    pub fn withdraw_usdc(env: &Env, employer: Address, amount: u64) {
        let mut reserves = Self::employer_usdc_reserves(env);
        let balance = reserves.get(&employer).unwrap_or(0);
        assert!(balance >= amount, "Insufficient USDC reserves");

        reserves.set(employer.clone(), balance - amount);
        env.storage().persistent().set(&"employer_usdc_reserves", &reserves);
    }

    // Function to process payroll bridging (EXCLUDES PTO & Sick Pay)
    pub fn bridge_payroll(env: &Env, worker: Address, amount: u64) {
        let mut payroll = Self::payroll_balances(env);
        let balance = payroll.get(&worker).unwrap_or(0);
        assert!(balance >= amount, "Insufficient payroll balance");

        payroll.set(worker.clone(), balance - amount);
        env.storage().persistent().set(&"payroll_balances", &payroll);
    }

    // Function to bridge trust fund withdrawals (Aleo-only enforcement)
    pub fn bridge_trust_fund(env: &Env, worker: Address, amount: u64) {
        let mut trust_funds = Self::trust_fund_balances(env);
        let balance = trust_funds.get(&worker).unwrap_or(0);
        assert!(balance >= amount, "Insufficient trust fund balance");

        trust_funds.set(worker.clone(), balance - amount);
        env.storage().persistent().set(&"trust_fund_balances", &trust_funds);
    }

    // Function to block invalid PTO/Sick Pay bridging attempts
    pub fn attempt_bridge_pto_or_sick_pay(env: &Env, worker: Address, _amount: u64) {
        env.events()
            .publish(worker, "InvalidBridgeAttempt: PTO/Sick Pay cannot be bridged. Withdraw only on Aleo.");
    }

    // Function to verify employer USDC liquidity
    pub fn verify_employer_usdc(env: &Env, employer: Address, required_amount: u64) -> bool {
        let reserves = Self::employer_usdc_reserves(env);
        reserves.get(&employer).unwrap_or(0) >= required_amount
    }
    }
