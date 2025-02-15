program employer_agreement.aleo;

import aleo_usdc_pool.leo;
import certification_verifier.leo;
import farm_investment.leo;
import compliance_tracking.leo;
import aztec_payroll.noir;

// 🏷️ Employer Payroll Fund Tracking
mapping employer_balances: public hashmap<address, u64>;  // Employer payroll funds (Aleo)
mapping employer_aztec_balances: public hashmap<address, u64>;  // Employer payroll funds (Aztec)
mapping employer_status: public hashmap<address, bool>;   // Employer compliance status
mapping worker_assignments: public hashmap<address, address>;  // Worker → Employer mapping

// 🔹 Worker-Specific Payroll Preferences
mapping worker_hourly_wages: public hashmap<address, u64>;  // Worker-specific hourly wages
mapping employer_hourly_buffer: public hashmap<address, u64>;  // Minimum required hourly payroll reserve
mapping worker_aztec_enabled: public hashmap<address, bool>;  // Worker preference for Aztec payroll

// 🔹 Farm & Investment Restrictions
mapping employer_farm_types: public hashmap<address, array<string>>;  // Allowed farm types per employer
mapping employer_certifications: public hashmap<address, array<string>>;  // Certifications per employer
mapping employer_investment_limits: public hashmap<address, u64>;  // Limits on worker investments per employer
mapping employer_farm_investment_agreement: public hashmap<address, bool>;  // Employer agreement to negotiable worker farm investment

// 🔹 New ANS Mappings
mapping ans_registry: public hashmap<address, string>;  // Maps worker addresses to ANS names
mapping ans_reverse_lookup: public hashmap<string, address>;  // Maps ANS names to worker addresses

// 🔹 Employer Mining Contributions
mapping employer_mining_contribution: public hashmap<address, u64>;  // Tracks mining power submitted by each employer
mapping grant_mining_rig_eligibility: public hashmap<address, bool>;  // Tracks which employers receive grant-funded rigs

// 🔹 Multi-Chain Payroll Compliance
mapping employer_subdao_fees: public hashmap<address, u64>;  // SubDAO contributions required for Aztec payroll

/// @dev Allows employers to apply for a grant-funded mining rig
function apply_for_grant_mining_rig(employer: address) -> bool {
    ensure!(employer_status.get(employer).unwrap_or(false), "Employer is non-compliant.");
    ensure!(!grant_mining_rig_eligibility.contains(employer), "Employer has already received a grant-funded rig.");
    
    grant_mining_rig_eligibility.insert(employer, true);
    return true;
}

/// @dev Verifies mining contribution for on-chain compliance tracking
function verify_mining_contribution(employer: address, mining_power: u64) -> bool {
    ensure!(employer_status.get(employer).unwrap_or(false), "Employer is non-compliant.");
    ensure!(mining_power > 0, "Mining contribution must be greater than zero.");
    
    employer_mining_contribution.insert(employer, mining_power);
    compliance_tracking.update_mining_proof(employer, mining_power);

    return true;
}

/// @dev Registers a new employer with payroll funding on Aleo & Aztec
function register_employer(employer: address, initial_deposit_aleo: u64, initial_deposit_aztec: u64, farm_types: array<string>) -> bool {
    ensure!(initial_deposit_aleo >= required_deposit(), "Insufficient Aleo deposit.");
    ensure!(initial_deposit_aztec >= required_deposit(), "Insufficient Aztec deposit.");
    
    employer_balances.insert(employer, initial_deposit_aleo);
    employer_aztec_balances.insert(employer, initial_deposit_aztec);
    employer_status.insert(employer, true);
    employer_farm_types.insert(employer, farm_types);
    employer_farm_investment_agreement.insert(employer, true);

    return true;
}

/// @dev Assigns a worker to an employer using ANS
function assign_worker_by_ans(worker_ans: string, employer: address, hourly: bool, wage: u64) -> bool {
    let worker = lookup_worker_by_ans(worker_ans);
    assign_worker(worker, employer, hourly, wage);
}

/// @dev Registers a farm certification for an employer (API-based verification required)
function register_farm_certification(employer: address, certification: string) -> bool {
    let is_valid = certification_verifier.verify_certification(employer, certification);
    ensure!(is_valid, "Certification verification failed.");

    let mut certs = employer_certifications.get(employer).unwrap_or(vec![]);
    certs.push(certification);
    employer_certifications.insert(employer, certs);

    return true;
}

/// @dev Enforces real-time payroll funding for hourly workers before they clock in
function enforce_hourly_funding(worker: address) -> bool {
    let employer = worker_assignments.get(worker).unwrap_or_else(|| panic!("Worker is not assigned to an employer."));
    let hourly_wage = worker_hourly_wages.get(worker).unwrap_or(0);
    let buffer_hours = employer_hourly_buffer.get(employer).unwrap_or(24);  

    let total_workers = worker_assignments.iter().filter(|(_, e)| **e == employer).count() as u64;
    let required_balance = total_workers * hourly_wage * buffer_hours;
    let employer_balance = employer_balances.get(employer).unwrap_or(0);

    ensure!(employer_balance >= required_balance, "Insufficient employer payroll funds.");
    return true;
}

/// @dev Ensures employer compliance before processing Aleo or Aztec payroll
function enforce_employer_compliance(employer: address) -> bool {
    let compliant = compliance_tracking.check_employer_compliance(employer);
    ensure!(compliant, "Employer is not compliant with payroll, taxes, or SubDAO obligations.");

    return true;
}

/// @dev Funds an employer’s payroll balance on Aleo or Aztec
function fund_employer(employer: address, amount: u64, use_aztec: bool) -> bool {
    if use_aztec {
        let success = aztec_payroll.deposit(employer, amount);
        ensure!(success, "Failed to deposit funds on Aztec.");
        employer_aztec_balances.insert(employer, employer_aztec_balances.get(employer).unwrap_or(0) + amount);
    } else {
        let success = aleo_usdc_pool.deposit(employer, amount);
        ensure!(success, "Failed to deposit funds on Aleo.");
        employer_balances.insert(employer, employer_balances.get(employer).unwrap_or(0) + amount);
    }
    return true;
}

/// @dev Allows employers to withdraw unused funds but only after closing their contract
function request_employer_withdrawal(employer: address) -> bool {
    ensure!(!employer_status.get(employer).unwrap_or(true), "Employer contract must be closed before withdrawal.");
    
    let employer_balance = employer_balances.get(employer).unwrap_or(0);
    ensure!(employer_balance > 0, "No funds available for withdrawal.");

    let success = aleo_usdc_pool.withdraw(employer, employer_balance);
    ensure!(success, "Withdrawal failed.");

    employer_balances.insert(employer, 0);
    return true;
}

/// @dev Utility function: Lookup a worker's address by ANS name
function lookup_worker_by_ans(ans_name: string) -> address {
    ensure!(ans_reverse_lookup.contains(ans_name), "ANS name not found");
    return ans_reverse_lookup[ans_name];
}
