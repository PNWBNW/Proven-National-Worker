// pncw_governance.leo

import 0x01::payroll;
import 0x01::worker_identity;
import 0x01::employer_agreement;
import 0x01::subdao_governance;

// Structure for tracking PNcW governance data
struct PNcWGovernance has store {
    worker_id: u64,
    subdao_id: u64,
    voting_power: u64,
}

// Mapping to track PNcW governance records
mapping pncw_governance_registry: u64 -> PNcWGovernance;

// Function to add a new worker to the PNcW governance system
public fun add_worker(worker_id: u64) -> bool {
    assert!(worker_identity::is_verified_worker(worker_id), 0); // Ensure worker is verified

    let subdao_id = subdao_governance::assign_subdao(worker_id);
    let new_governance_record = PNcWGovernance {
        worker_id: worker_id,
        subdao_id: subdao_id,
        voting_power: 1,
    };

    pncw_governance_registry[worker_id] = new_governance_record;
    return true;
}

// Function to cast a vote in PNcW governance
public fun cast_vote(worker_id: u64, proposal_id: u64, vote_choice: bool) -> bool {
    let governance_record = pncw_governance_registry[worker_id];
    return subdao_governance::vote(governance_record.subdao_id, worker_id, proposal_id, vote_choice);
}

// Function to check worker voting power
public fun get_voting_power(worker_id: u64) -> u64 {
    let governance_record = pncw_governance_registry[worker_id];
    return governance_record.voting_power;
}

// Function to flag non-compliant employers within PNcW governance
public fun flag_non_compliance(employer_id: u64) {
    subdao_governance::flag_non_compliance(employer_id);
}
