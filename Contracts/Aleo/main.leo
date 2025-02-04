// main.leo

import 0x01::worker_identity;
import 0x01::subdao_citizen_payroll;
import 0x01::merkle_helper;  // For Merkle-based validation

// Structures to represent the updated worker systems

// Worker structure for Proven National Workers (PNcW and PNiW)
struct Worker has store {
    worker_id: u64,  // Unique worker ID
    nationality: string,  // Nationality (for determining citizenship status)
    role: string,  // Worker role in the system
    verified: bool,  // Worker verification status
    nft_type: string,  // Either "PNcW" or "PNiW" based on citizenship
    farm_investment: u64,  // Farm investment amount
}

// Structure for SubDAO (Citizenship-based SubDAOs)
struct SubDAO has store {
    subdao_id: u64,  // SubDAO unique ID
    name: string,  // SubDAO name
    members: vector<u64>,  // Member list, worker IDs
    payroll: u64,  // Payroll amount to be distributed
    farm_investment_payout: u64,  // Farm investment payout
    verified_workers: vector<u64>,  // Workers who have completed verification
}

// Function to create a new worker
public fun create_worker(worker_id: u64, nationality: string, role: string, nft_type: string): Worker {
    let worker = Worker {
        worker_id: worker_id,
        nationality: nationality,
        role: role,
        verified: false,
        nft_type: nft_type,
        farm_investment: 0,
    };
    move_to(worker, worker_id);
    return worker;
}

// Function to update worker verification status
public fun update_worker_verification(worker_id: u64, verified: bool) {
    let worker = borrow_global_mut<Worker>(worker_id);
    worker.verified = verified;
}

// Function to create a new SubDAO
public fun create_subdao(subdao_id: u64, name: string, members: vector<u64>): SubDAO {
    let subdao = SubDAO {
        subdao_id: subdao_id,
        name: name,
        members: members,
        payroll: 0,
        farm_investment_payout: 0,
        verified_workers: vector::empty<u64>(),
    };
    move_to(subdao, subdao_id);
    return subdao;
}

// Function to add worker to SubDAO
public fun add_worker_to_subdao(subdao_id: u64, worker_id: u64) {
    let subdao = borrow_global_mut<SubDAO>(subdao_id);
    vector::push_back(&mut subdao.members, worker_id);
}

// Function to set SubDAO payroll amount
public fun set_subdao_payroll(subdao_id: u64, payroll_amount: u64) {
    let subdao = borrow_global_mut<SubDAO>(subdao_id);
    subdao.payroll = payroll_amount;
}

// Function to approve worker as verified in SubDAO
public fun approve_worker_in_subdao(subdao_id: u64, worker_id: u64) {
    let subdao = borrow_global_mut<SubDAO>(subdao_id);
    if (worker_identity::is_verified(worker_id)) {
        vector::push_back(&mut subdao.verified_workers, worker_id);
    }
}

// Function to process the farm investment payout for SubDAO
public fun process_farm_investment_payout(subdao_id: u64) {
    let subdao = borrow_global_mut<SubDAO>(subdao_id);
    let payout_amount = subdao.farm_investment_payout / vector::length(&subdao.verified_workers);
    // Distribute payout to verified workers
    for (worker_id in subdao.verified_workers) {
        worker_identity::send_payment(worker_id, payout_amount);  // Assuming send_payment exists
    }
}

// Function to execute payroll distribution for SubDAO
public fun execute_subdao_payroll(subdao_id: u64) {
    let subdao = borrow_global_mut<SubDAO>(subdao_id);
    let payout_per_worker = subdao.payroll / vector::length(&subdao.members);
    let mut total_paid = 0;
    // Iterate through the workers and distribute payments
    for (worker_id in subdao.members) {
        total_paid = total_paid + payout_per_worker;
        worker_identity::send_payment(worker_id, payout_per_worker);  // Assuming send_payment exists
    }
    subdao.payroll = 0;  // Reset payroll after execution
}

// Function to get SubDAO details (for audit or display)
public fun get_subdao_details(subdao_id: u64): SubDAO {
    borrow_global<SubDAO>(subdao_id)
}

// Function to get worker details
public fun get_worker_details(worker_id: u64): Worker {
    borrow_global<Worker>(worker_id)
}

// Function to initialize a Merkle validation (for verifying farm investment and payroll data)
public fun initialize_merkle_verification(subdao_id: u64): bool {
    let subdao = borrow_global<SubDAO>(subdao_id);
    let workers_data = vector::map(
        &subdao.members,
        fun(worker_id) => worker_identity::get_worker_data(worker_id),
    );
    // Assuming Merkle helper has a function to validate Merkle tree for batch data
    merkle_helper::validate_merkle_tree(workers_data)
}
