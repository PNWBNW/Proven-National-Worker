// worker_identity.leo

import 0x01::pncw_governance;
import 0x01::pniw_governance;
import 0x01::payroll;
import 0x01::zk_verifier;

// Structure for storing worker identity data
struct WorkerIdentity has store {
    worker_id: u64,
    worker_type: u8,    // 0 = PNcW, 1 = PNiW
    industry_type: u64, // Industry-specific verification
    is_verified: bool,
}

// Mapping for storing worker identities
mapping worker_registry: u64 -> WorkerIdentity;

// Function to register a new worker
public fun register_worker(worker_id: u64, worker_type: u8, industry_type: u64) -> bool {
    let verified = zk_verifier::verify_identity(worker_id);
    assert!(verified, 0); // Ensure identity proof is valid

    let new_worker = WorkerIdentity {
        worker_id: worker_id,
        worker_type: worker_type,
        industry_type: industry_type,
        is_verified: true,
    };

    worker_registry[worker_id] = new_worker;

    match worker_type {
        0 => pncw_governance::add_worker(worker_id),
        1 => pniw_governance::add_worker(worker_id),
        _ => return false,
    };

    return true;
}

// Function to check if a worker is verified
public fun is_verified_worker(worker_id: u64) -> bool {
    let worker = worker_registry[worker_id];
    return worker.is_verified;
}

// Function to retrieve worker classification
public fun get_worker_type(worker_id: u64) -> u8 {
    let worker = worker_registry[worker_id];
    return worker.worker_type;
}

// Function to update a worker's industry classification (e.g., for job changes)
public fun update_industry(worker_id: u64, new_industry: u64) -> bool {
    let mut worker = worker_registry[worker_id];
    assert!(worker.is_verified, 0); // Only verified workers can update

    worker.industry_type = new_industry;
    worker_registry[worker_id] = worker;
    return true;
}

// Function to verify if a worker meets payroll requirements
public fun verify_for_payroll(worker_id: u64) -> bool {
    let worker = worker_registry[worker_id];
    return payroll::validate_worker(worker_id, worker.worker_type);
}
