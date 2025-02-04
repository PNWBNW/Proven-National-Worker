// pncw_trust_pool.leo

import 0x01::pncw_payroll;
import 0x01::payroll;
import 0x01::worker_identity;
import 0x01::zk_verifier;
import 0x01::aleo_usdc;
import 0x01::kyc_verification;

// Structure to track PNcW trust pool contributions
struct PNcWTrustPool has store {
    worker_id: u64,
    total_contributed: u64,
    last_contribution_timestamp: u64,
}

// Mapping for storing worker trust pool balances
mapping pncw_trust_pool: u64 -> PNcWTrustPool;

// Function to contribute payroll funds to the PNcW trust pool
public fun contribute_to_trust_pool(worker_id: u64, contribution_amount: u64) -> bool {
    assert!(worker_identity::is_verified_worker(worker_id), 0);
    assert!(contribution_amount > 0, 0);

    let mut trust_record = match pncw_trust_pool.contains(worker_id) {
        true => pncw_trust_pool[worker_id],
        false => PNcWTrustPool {
            worker_id: worker_id,
            total_contributed: 0,
            last_contribution_timestamp: 0,
        },
    };

    trust_record.total_contributed += contribution_amount;
    trust_record.last_contribution_timestamp = timestamp();
    pncw_trust_pool[worker_id] = trust_record;

    return true;
}

// Function to check worker trust pool balance
public fun get_trust_pool_balance(worker_id: u64) -> u64 {
    let trust_record = pncw_trust_pool[worker_id];
    return trust_record.total_contributed;
}

// Function to allow children to redeem funds after turning 18 with KYC
public fun redeem_funds(child_id: u64, worker_id: u64, withdrawal_amount: u64) -> bool {
    let verified = kyc_verification::verify_age(child_id, 18);
    assert!(verified, 0); // Ensure child is 18 or older

    let mut trust_record = pncw_trust_pool[worker_id];
    assert!(trust_record.total_contributed >= withdrawal_amount, 0);
    assert!(withdrawal_amount > 0, 0);

    let success = aleo_usdc::transfer(child_id, withdrawal_amount);
    assert!(success, 0); // Ensure transfer succeeds

    trust_record.total_contributed -= withdrawal_amount;
    pncw_trust_pool[worker_id] = trust_record;

    return success;
}

// Function to allow partial withdrawal before 18 with approval from 3 other workers
public fun request_partial_withdrawal(worker_id: u64, withdrawal_amount: u64, approver1: u64, approver2: u64, approver3: u64) -> bool {
    assert!(worker_identity::is_verified_worker(approver1), 0);
    assert!(worker_identity::is_verified_worker(approver2), 0);
    assert!(worker_identity::is_verified_worker(approver3), 0);

    let mut trust_record = pncw_trust_pool[worker_id];
    assert!(trust_record.total_contributed >= withdrawal_amount, 0);
    assert!(withdrawal_amount > 0, 0);

    let approved = zk_verifier::verify_signatures(worker_id, [approver1, approver2, approver3]);
    assert!(approved, 0); // Ensure three workers approve the withdrawal

    let success = aleo_usdc::transfer(worker_id, withdrawal_amount);
    assert!(success, 0); // Ensure transfer succeeds

    trust_record.total_contributed -= withdrawal_amount;
    pncw_trust_pool[worker_id] = trust_record;

    return success;
}
