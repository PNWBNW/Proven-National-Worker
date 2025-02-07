program compliance_tracking.aleo;

/// **Mappings**
mapping employer_farm_types: address => [u8];  // Stores allowed farm types per employer
mapping employer_certifications: address => [string];  // Stores verified farm certifications
mapping employer_max_worker_investment: address => u64;  // Maximum worker investment cap
mapping employer_current_worker_investment: address => u64;  // Tracks total worker investments
mapping employer_payroll_due: address => u64;  // Expected payroll contributions
mapping employer_payroll_paid: address => u64;  // Tracks payroll payments made
mapping compliance_violations: address => u64;  // Stores compliance violations per employer

/// **Function: verify_farm_type**
/// - Ensures a worker’s selected farm type is allowed by the employer.
function verify_farm_type(employer: address, farm_type: u8) -> bool {
    let allowed_farm_types = employer_agreement::get_farm_types(employer);
    assert!(contains(allowed_farm_types, farm_type), "Invalid farm type for this employer.");
    return true;
}

/// **Function: verify_certification**
/// - Ensures a farm’s certification is both registered and government-approved.
function verify_certification(employer: address, certification: string) -> bool {
    let registered_certs = employer_agreement::get_certifications(employer);
    assert!(contains(registered_certs, certification), "Certification not registered by employer.");
    
    let is_valid = employer_agreement::is_certification_valid(employer, certification);
    assert!(is_valid, "Certification not officially verified.");
    return true;
}

/// **Function: check_worker_investment_cap**
/// - Ensures a worker’s investment does not exceed the employer-set cap.
function check_worker_investment_cap(employer: address, investment_amount: u64) -> bool {
    let max_limit = employer_agreement::get_max_worker_investment(employer);
    let current_total = employer_current_worker_investment[employer];

    assert!(current_total + investment_amount <= max_limit, "Worker investment limit exceeded.");
    return true;
}

/// **Function: record_worker_investment**
/// - Updates compliance tracking when workers invest.
function record_worker_investment(employer: address, investment_amount: u64) -> bool {
    let is_within_limit = check_worker_investment_cap(employer, investment_amount);
    assert!(is_within_limit, "Investment exceeds employer's limit.");

    employer_current_worker_investment[employer] += investment_amount;
    return true;
}

/// **Function: reset_worker_investment_tracking**
/// - Resets worker investment totals after a harvest cycle.
function reset_worker_investment_tracking(employer: address) -> bool {
    let authorized: address = caller();
    assert!(authorized == employer, "Only the employer can reset investments.");

    employer_current_worker_investment[employer] = 0;
    return true;
}

/// **Function: set_payroll_due**
/// - Records expected payroll contributions for an employer.
function set_payroll_due(employer: address, amount: u64) -> bool {
    let authorized: address = caller();
    assert!(authorized == employer, "Only the employer can set payroll obligations.");

    employer_payroll_due[employer] = amount;
    return true;
}

/// **Function: record_payroll_payment**
/// - Logs payroll payments made by an employer.
function record_payroll_payment(employer: address, amount: u64) -> bool {
    let authorized: address = caller();
    assert!(authorized == employer, "Only the employer can record payroll payments.");

    employer_payroll_paid[employer] += amount;
    return true;
}

/// **Function: get_unpaid_payroll**
/// - Returns the employer’s unpaid payroll amount.
function get_unpaid_payroll(employer: address) -> u64 {
    let due = employer_payroll_due[employer];
    let paid = employer_payroll_paid[employer];

    return if paid >= due { 0 } else { due - paid };
}

/// **Function: check_payroll_compliance**
/// - Ensures employers meet payroll obligations.
function check_payroll_compliance(employer: address) -> bool {
    let unpaid = get_unpaid_payroll(employer);
    assert!(unpaid == 0, "Employer has unpaid payroll obligations.");
    return true;
}

/// **Function: record_compliance_violation**
/// - Logs compliance violations for employers who fail to meet payroll or investment limits.
function record_compliance_violation(employer: address) -> bool {
    compliance_violations[employer] += 1;
    return true;
}

/// **Function: get_compliance_violations**
/// - Returns the number of compliance violations for an employer.
function get_compliance_violations(employer: address) -> u64 {
    return compliance_violations[employer];
}
