#![no_std]

use soroban_sdk::{contract, contractimpl, Env, Address, Symbol, Vec, Map, BytesN};

#[contract]
pub struct FarmInvestmentContract;

#[derive(Clone)]
pub struct Investment {
    investor: Address,
    amount: u64,
    approved: bool,
    investment_timestamp: u64,
}

#[contractimpl]
impl FarmInvestmentContract {
    // Store farm investments
    pub fn add_investment(env: Env, investor: Address, amount: u64) -> bool {
        assert!(amount > 0, "Investment amount must be greater than zero");

        let mut investments: Map<Address, Investment> = env.storage().persistent().get().unwrap_or_default();
        investments.set(investor.clone(), Investment {
            investor: investor.clone(),
            amount,
            approved: false,
            investment_timestamp: env.ledger().timestamp(),
        });

        env.storage().persistent().set(&investments);
        true
    }

    // Approve an investment based on Merkle validation
    pub fn approve_investment(env: Env, investor: Address, merkle_proof: BytesN<32>) -> bool {
        let mut investments: Map<Address, Investment> = env.storage().persistent().get().unwrap_or_default();
        let investment = investments.get(&investor).expect("Investment not found");

        // Call Merkle verification logic (assuming separate contract integration)
        let valid = FarmInvestmentContract::validate_merkle(env.clone(), investor.clone(), merkle_proof);
        if !valid {
            return false;
        }

        let approved_investment = Investment {
            investor: investment.investor.clone(),
            amount: investment.amount,
            approved: true,
            investment_timestamp: investment.investment_timestamp,
        };

        investments.set(investor, approved_investment);
        env.storage().persistent().set(&investments);
        true
    }

    // Process investment payout after approval
    pub fn process_payout(env: Env, investor: Address) -> bool {
        let mut investments: Map<Address, Investment> = env.storage().persistent().get().unwrap_or_default();
        let investment = investments.get(&investor).expect("Investment not found");

        assert!(investment.approved, "Investment is not approved");

        // Call Aleo payroll bridge for fund transfer
        let success = FarmInvestmentContract::execute_payout(env.clone(), investor.clone(), investment.amount);
        if success {
            investments.remove(&investor);
            env.storage().persistent().set(&investments);
        }

        success
    }

    // Dummy function for Merkle validation (to be implemented properly)
    pub fn validate_merkle(env: Env, investor: Address, merkle_proof: BytesN<32>) -> bool {
        // Placeholder logic for now
        true
    }

    // Dummy function for executing payouts (integrate Aleo bridge)
    pub fn execute_payout(env: Env, investor: Address, amount: u64) -> bool {
        // Placeholder logic for now
        true
    }
}
