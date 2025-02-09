program employer_agreement.leo;

import aleo_usdc_pool.leo;
import certification_verifier.leo;
import farm_investment.leo;

mapping employer_balances: public hashmap<address, u64>;  // Employer payroll funds
mapping employer_status: public hashmap<address, bool>;   // Employer compliance status
mapping worker_assignments: public hashmap<address, address>;  // Worker → Employer mapping
mapping worker_hourly_wages: public hashmap<address, u64>;  // Worker-specific hourly wages
mapping employer_hourly_buffer: public hashmap<address, u64>;  // Minimum required hourly payroll reserve
mapping employer_farm_types: public hashmap<address, array<string>>;  // Allowed farm types per employer
mapping employer_certifications: public hashmap<address, array<string>>;  // Certifications per employer
mapping employer_investment_limits: public hashmap<address, u64>;  // Limits on worker investments per employer
mapping employer_farm_investment_agreement: public hashmap<address, bool>;  // Employer agreement to negotiable worker farm investment

/// @dev Registers a new employer with funding, farm types, and compliance
function register_employer(employer: address, initial_deposit: u64, farm_types: array<string>) -> bool {
    ensure(initial_deposit >= required_deposit(), "Insufficient initial deposit.");
    
    employer_balances.insert(employer, initial_deposit);
    employer_status.insert(employer, true);
    employer_farm_types.insert(employer, farm_types);
    employer_farm_investment_agreement.insert(employer, true);  // Employer agrees to negotiable worker farm investment

    return true;
}

/// @dev Assigns a worker to an employer for contracted work or hourly work
function assign_worker(worker: address, employer: address, hourly: bool, wage: u64) -> bool {
    ensure(employer_status.get(employer).unwrap_or(false), "Employer is non-compliant; hiring is paused.");
    ensure(employer_farm_investment_agreement.get(employer).unwrap_or(false), "Employer has not agreed to negotiable farm investment.");

    worker_assignments.insert(worker, employer);
    if hourly {
        worker_hourly_wages.insert(worker, wage);
    }

    return true;
}

/// @dev Registers a farm certification for an employer (API-based verification required)
function register_farm_certification(employer: address, certification: string) -> bool {
    let is_valid = certification_verifier.verify_certification(employer, certification);
    ensure(is_valid, "Certification verification failed.");

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

    ensure(employer_balance >= required_balance, "Insufficient employer payroll funds.");
    return true;
}

/// @dev Allows a worker to clock in for hourly work
function clock_in(worker: address) -> bool {
    enforce_hourly_funding(worker);
    return true;
}

/// @dev Ensures contract workers are fully funded before assignment, with a 25% buffer
function enforce_contract_funding(worker: address, employer: address, contract_amount: u64) -> bool {
    let required_funding = contract_amount + (contract_amount * 25 / 100);
    let employer_balance = employer_balances.get(employer).unwrap_or(0);

    ensure(employer_balance >= required_funding, "Insufficient employer payroll funds for contract work.");
    return true;
}

/// @dev Employers must agree to allow workers to negotiate their farm investments
function employer_agree_to_farm_investment(employer: address) -> bool {
    employer_farm_investment_agreement.insert(employer, true);
    return true;
}

/// @dev Funds an employer’s payroll balance
function fund_employer(employer: address, amount: u64) -> bool {
    let success = aleo_usdc_pool.deposit(employer, amount);
    ensure(success, "Failed to deposit funds.");

    let current_balance = employer_balances.get(employer).unwrap_or(0);
    employer_balances.insert(employer, current_balance + amount);
    return true;
}

/// @dev Computes the required employer payroll balance for compliance
function required_payroll_balance(employer: address) -> u64 {
    let buffer_hours = employer_hourly_buffer.get(employer).unwrap_or(24);
    let total_workers = worker_assignments.iter().filter(|(_, e)| **e == employer).count() as u64;
    let avg_hourly_wage = worker_hourly_wages.iter().filter(|(w, _)| worker_assignments.get(w).unwrap_or(address(0)) == employer)
        .map(|(_, wage)| *wage).sum::<u64>() / total_workers;

    return total_workers * avg_hourly_wage * buffer_hours;
}

/// @dev Handles employer penalties for repeated non-compliance
function enforce_penalties(employer: address) -> bool {
    let missed_payments = employer_status.get(employer).unwrap_or(false);
    if !missed_payments {
        return true;  // No penalties needed if employer is compliant
    }

    let overdue_amount = required_payroll_balance(employer);
    let penalty_fee = overdue_amount + (overdue_amount * 25 / 100);

    let success = aleo_usdc_pool.withdraw(employer, penalty_fee);
    ensure(success, "Penalty payment required for reinstatement.");

    employer_status.insert(employer, true);
    return true;
}

/// @dev Allows employers to withdraw unused funds, but only if they fully close their contract
function request_employer_withdrawal(employer: address) -> bool {
    ensure(!employer_status.get(employer).unwrap_or(true), "Employer contract must be closed before withdrawal.");
    
    let employer_balance = employer_balances.get(employer).unwrap_or(0);
    ensure(employer_balance > 0, "No funds available for withdrawal.");

    let success = aleo_usdc_pool.withdraw(employer, employer_balance);
    ensure(success, "Withdrawal failed.");

    employer_balances.insert(employer, 0);
    return true;
}

/// @dev Closes an employer contract with PNW, allowing potential refund
function close_employer_contract(employer: address) -> bool {
    ensure(employer_status.get(employer).unwrap_or(true), "Employer is still active. Resolve all commitments first.");

    employer_status.insert(employer, false);
    return true;
}
