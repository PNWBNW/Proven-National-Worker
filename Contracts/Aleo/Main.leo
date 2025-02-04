// main.leo

import 0x01::worker_identity;
import 0x01::employer_agreement;
import 0x01::payroll;
import 0x01::pncw_payroll;
import 0x01::pniw_payroll;
import 0x01::process_tax_compliance;
import 0x01::government_api;
import 0x01::subdao_governance;
import 0x01::farm_investment;
import 0x01::merkle_decision_maker;
import 0x01::zk_verifier;

// Structure for tracking system-wide payroll and compliance
struct SystemState has store {
    total_pncw_workers: u64,
    total_pniw_workers: u64,
    total_employers: u64,
    total_tax_collected: u64,
    total_farm_investment: u64,
}

// Global system state mapping
mapping system_state: SystemState;

// Function to register a worker into the system
public fun register_worker(worker_id: u64, worker_type: u8) -> bool {
    let mut state = system_state[];

    match worker_type {
        0 => {
            let registered = pncw_payroll::add_worker(worker_id);
            if registered {
                state.total_pncw_workers += 1;
            }
        }
        1 => {
            let registered = pniw_payroll::add_worker(worker_id);
            if registered {
                state.total_pniw_workers += 1;
            }
        }
        _ => return false,
    };

    system_state[] = state;
    return true;
}

// Function to register an employer into the system
public fun register_employer(employer_id: u64) -> bool {
    let mut state = system_state[];

    let registered = employer_agreement::register_employer(employer_id);
    if registered {
        state.total_employers += 1;
    }

    system_state[] = state;
    return registered;
}

// Function to process payroll for a given employer
public fun process_payroll(employer_id: u64, payroll_type: u8) -> bool {
    let mut state = system_state[];

    // Verify employer tax compliance
    let compliant = government_api::verify_tax_compliance(employer_id);
    if !compliant {
        return false;
    }

    // Execute payroll based on worker category
    match payroll_type {
        0 => pncw_payroll::execute_payroll(employer_id),
        1 => pniw_payroll::execute_payroll(employer_id),
        _ => return false,
    };

    system_state[] = state;
    return true;
}

// Function to process farm investments
public fun process_farm_investment(investor_id: u64, amount: u64, investment_type: u8) -> bool {
    let mut state = system_state[];

    let success = match investment_type {
        0 => pncw_farm_investment::add_investment(investor_id, amount),
        1 => pniw_farm_investment::add_investment(investor_id, amount),
        _ => return false,
    };

    if success {
        state.total_farm_investment += amount;
    }

    system_state[] = state;
    return success;
}

// Function to verify employer compliance
public fun check_employer_compliance(employer_id: u64) -> bool {
    return process_tax_compliance::check_compliance(employer_id);
}

// Function to flag an employer for non-compliance
public fun flag_non_compliant_employer(employer_id: u64) {
    subdao_governance::flag_non_compliance(employer_id);
}
