program employer_agreement.leo;

import aleo_usdc_pool.leo;
import certification_verifier.leo;
import farm_investment.leo;

mapping employer_balances: public hashmap<address, u64>;  // Tracks each employer's Aleo USDC balance
mapping employer_status: public hashmap<address, bool>;   // Tracks if an employer is in good standing
mapping worker_assignments: public hashmap<address, address>;  // Worker → Employer mapping
mapping employer_penalties: public hashmap<address, u64>;  // Penalty tracking for non-compliance
mapping employer_farm_types: public hashmap<address, array<string>>;  // Allowed farm types per employer
mapping employer_certifications: public hashmap<address, array<string>>;  // Certifications per employer
mapping employer_investment_limits: public hashmap<address, u64>;  // Limits on worker investments per employer

/// @dev Registers a new employer and ensures they meet funding & farm type requirements
function register_employer(employer: address, initial_deposit: u64, farm_types: array<string>) -> bool {
    // Ensure employer deposits sufficient Aleo USDC into the pool
    ensure(initial_deposit >= required_deposit(), "Insufficient initial deposit.");
    
    // Store employer balance and mark them as compliant
    employer_balances.insert(employer, initial_deposit);
    employer_status.insert(employer, true);
    employer_farm_types.insert(employer, farm_types);

    return true;
}

/// @dev Assigns a worker to an employer, verifying employer compliance
function assign_worker(worker: address, employer: address) -> bool {
    // Ensure employer is compliant before assigning workers
    ensure(employer_status.get(employer).unwrap_or(false), "Employer is non-compliant; hiring is paused.");

    // Register worker under employer
    worker_assignments.insert(worker, employer);

    return true;
}

/// @dev Checks an employer's status and pauses work if obligations are unmet
function enforce_compliance(employer: address) -> bool {
    let balance = employer_balances.get(employer).unwrap_or(0);

    // Check if employer has enough Aleo USDC for payroll & taxes
    if balance < required_balance(employer) {
        employer_status.insert(employer, false);  // Mark employer as non-compliant

        // Pause all assigned workers
        for (worker, emp) in worker_assignments.iter() {
            if emp == employer {
                pause_worker(worker);
            }
        }
        return false;
    } else {
        employer_status.insert(employer, true);  // Employer is compliant
        return true;
    }
}

/// @dev Registers a farm certification for an employer (requires API verification)
function register_farm_certification(employer: address, certification: string) -> bool {
    // Verify certification via API before approving
    let is_valid = certification_verifier.verify_certification(employer, certification);
    ensure(is_valid, "Certification verification failed.");

    // Store certification under employer
    let mut certs = employer_certifications.get(employer).unwrap_or(vec![]);
    certs.push(certification);
    employer_certifications.insert(employer, certs);

    return true;
}

/// @dev Pauses a specific worker's ability to work (internal function)
function pause_worker(worker: address) {
    // Logic to pause worker’s ability to clock hours, submit work, or receive payments
}

/// @dev Allows an employer to top up funds and resume operations
function fund_employer(employer: address, amount: u64) -> bool {
    // Ensure the employer is paying into the Aleo USDC Pool
    let success = aleo_usdc_pool.deposit(employer, amount);
    ensure(success, "Failed to deposit funds.");

    // Update employer balance
    let current_balance = employer_balances.get(employer).unwrap_or(0);
    employer_balances.insert(employer, current_balance + amount);

    // Re-evaluate compliance status
    if employer_balances.get(employer).unwrap_or(0) >= required_balance(employer) {
        employer_status.insert(employer, true);

        // Resume all paused workers under this employer
        for (worker, emp) in worker_assignments.iter() {
            if emp == employer {
                resume_worker(worker);
            }
        }
    }

    return true;
}

/// @dev Resumes a paused worker (internal function)
function resume_worker(worker: address) {
    // Logic to allow worker to continue labor, submit tasks, and receive payments
}

/// @dev Computes the required balance for an employer to remain compliant
function required_balance(employer: address) -> u64 {
    let worker_count = worker_assignments.iter().filter(|(_, e)| **e == employer).count() as u64;
    let tax_obligation = aleo_usdc_pool.calculate_taxes(employer);
    
    return (worker_count * base_wage()) + tax_obligation;
}

/// @dev Returns the required employer deposit amount upon registration
function required_deposit() -> u64 {
    return 10_000;  // Example minimum employer deposit
}

/// @dev Handles penalty enforcement for employers with 3+ missed payments
function enforce_penalties(employer: address) -> bool {
    let missed_payments = employer_penalties.get(employer).unwrap_or(0);

    if missed_payments >= 3 {
        let penalty_fee = calculate_penalty(employer);
        
        // Employer must pay the penalty before resuming operations
        let success = aleo_usdc_pool.withdraw(employer, penalty_fee);
        ensure(success, "Penalty payment required for reinstatement.");

        // Reset employer penalties upon successful payment
        employer_penalties.insert(employer, 0);
    }

    return true;
}

/// @dev Computes the penalty amount for a non-compliant employer
function calculate_penalty(employer: address) -> u64 {
    let overdue_amount = required_balance(employer);
    return overdue_amount + (overdue_amount * 25 / 100);  // 25% penalty
}

/// @dev Limits worker investments per employer
function set_employer_investment_limit(employer: address, limit: u64) -> bool {
    employer_investment_limits.insert(employer, limit);
    return true;
}

/// @dev Verifies if a worker investment complies with employer limits
function verify_investment(worker: address, amount: u64) -> bool {
    let employer = worker_assignments.get(worker).unwrap_or_else(|| panic!("Worker is not assigned to an employer."));
    let limit = employer_investment_limits.get(employer).unwrap_or(0);

    ensure(amount <= limit, "Investment exceeds employer-set limit.");

    return true;
}
