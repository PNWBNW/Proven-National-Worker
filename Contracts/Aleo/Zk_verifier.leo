// zk_verifier.leo

import 0x01::worker_identity;
import 0x01::merkle_helper; // For Merkle tree verification
import 0x01::subdao_citizen_payroll; // For SubDAO payroll integration

// Function to generate and verify ZK proof for worker payroll
public fun generate_zk_proof(worker_id: u64, amount: u64): string {
    let worker = borrow_global<worker_identity::Worker>(worker_id);
    assert(worker.verified, 0); // Ensure the worker is verified

    // Generate the ZK proof for this worker's payroll based on the amount
    let proof = merkle_helper::generate_zk_proof(worker_id, amount);
    return proof;
}

// Function to verify the ZK proof before executing payroll
public fun verify_zk_proof(proof: string, worker_id: u64, amount: u64): bool {
    let worker = borrow_global<worker_identity::Worker>(worker_id);
    assert(worker.verified, 0); // Ensure the worker is verified

    // Verify the ZK proof using Merkle tree validation
    let is_valid = merkle_helper::verify_zk_proof(proof, worker_id, amount);
    return is_valid;
}

// Function to validate worker's payroll data before payout
public fun validate_worker_payroll(worker_id: u64, amount: u64): bool {
    let worker = borrow_global<worker_identity::Worker>(worker_id);
    
    if (worker.verified) {
        // Generate ZK proof for payroll verification
        let proof = generate_zk_proof(worker_id, amount);
        
        // Verify ZK proof for payroll execution
        let is_verified = verify_zk_proof(proof, worker_id, amount);
        if (is_verified) {
            return true;
        } else {
            return false;
        }
    } else {
        return false; // Worker not verified
    }
}

// Function to validate entire SubDAO payroll using ZK proof
public fun validate_subdao_payroll(subdao_id: u64): bool {
    let subdao = borrow_global<subdao_citizen_payroll::SubDAO>(subdao_id);
    
    // Iterate over all SubDAO workers to validate each worker's payroll
    let mut all_verified = true;
    for (worker_id in subdao.members) {
        let worker = borrow_global<worker_identity::Worker>(worker_id);
        let amount = subdao.payroll / vector::length(&subdao.members);
        
        let proof_is_valid = validate_worker_payroll(worker_id, amount);
        
        if (!proof_is_valid) {
            all_verified = false;
            break;
        }
    }
    
    return all_verified;
}

// Function to process payroll for verified SubDAO members after ZK validation
public fun process_subdao_payroll_after_zk(subdao_id: u64) {
    let subdao = borrow_global_mut<subdao_citizen_payroll::SubDAO>(subdao_id);
    
    if (validate_subdao_payroll(subdao_id)) {
        // Process payroll for all verified workers in SubDAO
        let amount_per_worker = subdao.payroll / vector::length(&subdao.members);
        
        for (worker_id in subdao.members) {
            worker_identity::send_payment(worker_id, amount_per_worker);  // Assuming `send_payment` exists
        }
        
        subdao.payroll = 0;  // Reset SubDAO payroll after execution
    } else {
        // If ZK validation fails, log error or handle denial process
        eprintln("ZK proof validation failed. Payroll not processed.");
    }
}

// Function to execute farm investment payout after ZK validation
public fun process_farm_investment_payout_with_zk(subdao_id: u64) {
    let subdao = borrow_global_mut<subdao_citizen_payroll::SubDAO>(subdao_id);
    
    if (validate_subdao_payroll(subdao_id)) {
        let payout_amount = subdao.farm_investment_payout / vector::length(&subdao.members);
        
        for (worker_id in subdao.members) {
            worker_identity::send_payment(worker_id, payout_amount);  // Assuming `send_payment` exists
        }
        
        subdao.farm_investment_payout = 0;  // Reset farm investment payout after processing
    } else {
        // If ZK validation fails, log error or handle denial process
        eprintln("ZK proof validation failed. Farm investment payout not processed.");
    }
}
