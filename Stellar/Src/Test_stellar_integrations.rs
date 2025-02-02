#![cfg(test)]

use super::*;
use soroban_sdk::{testutils::Ledger, Env, Symbol};

#[test]
fn test_stellar_payment_processing() {
    let env = Env::default();
    let contract_id = env.register_contract(None, StellarIntegration);
    let client = StellarIntegrationClient::new(&env, &contract_id);

    // Mock worker details
    let worker_id = Symbol::new(&env, "worker_123");
    let payment_amount = 1000u64;

    // Call function to initiate payment
    let result = client.process_stellar_payment(&worker_id, payment_amount);

    // Validate expected success response
    assert!(result.is_ok());
    assert_eq!(result.unwrap(), Symbol::new(&env, "payment_success"));
}

#[test]
fn test_invalid_worker_payment() {
    let env = Env::default();
    let contract_id = env.register_contract(None, StellarIntegration);
    let client = StellarIntegrationClient::new(&env, &contract_id);

    // Mock invalid worker
    let worker_id = Symbol::new(&env, "");
    let payment_amount = 500u64;

    // Expect payment failure
    let result = client.process_stellar_payment(&worker_id, payment_amount);

    assert!(result.is_err());
}
