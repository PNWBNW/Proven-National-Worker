program employer_agreement.aleo;

/// **Mappings**
mapping employer_farm_types: address => [u8];  // Stores allowed farm types per employer
mapping employer_certifications: address => [string];  // Stores farm certifications
mapping employer_max_worker_investment: address => u64;  // Maximum worker investment cap per employer
mapping employer_current_worker_investment: address => u64;  // Tracks total worker investments
mapping employer_payroll_due: address => u64;  // Expected payroll contributions
mapping employer_payroll_paid: address => u64;  // Tracks payroll payments made
mapping compliance_violations: address => u64;  // Stores compliance violations per employer

/// **Function: set_farm_types**
/// - Employers define the farm types they produce.
/// - Workers can only invest in these allowed types.
function set_farm_types(farm_types: [u8]) -> bool {
    let employer: address = caller();
    
    for farm_type in farm_types {
        assert!(farm_type >= 1 && farm_type <= 12, "Invalid farm type.");
    }

    employer_farm_types[employer] = farm_types;
    
    return true;
}

/// **Function: get_farm_types**
/// - Returns the approved farm types for a specific employer.
function get_farm_types(employer: address) -> [u8] {
    return employer_farm_types[employer];
}

/// **Function: set_max_worker_investment**
/// - Employers set a cap on total worker investments.
function set_max_worker_investment(max_investment: u64) -> bool {
    let employer: address = caller();
    employer_max_worker_investment[employer] = max_investment;
    return true;
}

/// **Function: get_max_worker_investment**
/// - Returns the investment cap for a specific employer.
function get_max_worker_investment(employer: address) -> u64 {
    return employer_max_worker_investment[employer];
}

/// **Function: register_certifications**
/// - Employers submit certifications for approval.
function register_certifications(certifications: [string]) -> bool {
    let employer: address = caller();
    
    for cert in certifications {
        assert!(is_valid_certification(cert), "Invalid certification.");
        assert!(is_certification_approved(cert), "Certification not verified.");
    }

    employer_certifications[employer] = certifications;
    
    return true;
}

/// **Function: get_certifications**
/// - Returns the certifications for a specific employer.
function get_certifications(employer: address) -> [string] {
    return employer_certifications[employer];
}

/// **Function: update_worker_investment**
/// - Ensures worker investments do not exceed employer-set limits.
function update_worker_investment(employer: address, amount: u64) -> bool {
    let current_total = employer_current_worker_investment[employer];
    let max_limit = employer_max_worker_investment[employer];

    assert!(current_total + amount <= max_limit, "Worker investment limit exceeded.");
    
    employer_current_worker_investment[employer] += amount;
    
    return true;
}

/// **Function: reset_worker_investment**
/// - Resets worker investment tracking after each harvest cycle.
function reset_worker_investment(employer: address) -> bool {
    let authorized: address = caller();
    assert!(authorized == employer, "Only the employer can reset investments.");

    employer_current_worker_investment[employer] = 0;
    
    return true;
}

/// **Function: set_payroll_due**
/// - Employers must define their expected payroll contributions.
function set_payroll_due(amount: u64) -> bool {
    let employer: address = caller();
    employer_payroll_due[employer] = amount;
    
    return true;
}

/// **Function: record_payroll_payment**
/// - Employers log payroll payments.
function record_payroll_payment(amount: u64) -> bool {
    let employer: address = caller();
    employer_payroll_paid[employer] += amount;
    
    return true;
}

/// **Function: get_unpaid_payroll**
/// - Returns the amount of payroll still owed by the employer.
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
/// - Logs compliance violations for employers who fail payroll or investment limits.
function record_compliance_violation(employer: address) -> bool {
    compliance_violations[employer] += 1;
    
    return true;
}

/// **Function: get_compliance_violations**
/// - Returns the number of compliance violations for an employer.
function get_compliance_violations(employer: address) -> u64 {
    return compliance_violations[employer];
}

/// **Helper Function: is_valid_certification**
/// - Ensures only recognized certifications can be registered.
function is_valid_certification(cert: string) -> bool {
    let valid_certs = ["USDA Organic", "Certified Humane", "Non-GMO", "Wild-Caught", 
                       "Farm-Raised", "Gluten-Free", "Sustainable"];
    return contains(valid_certs, cert);
}

/// **Helper Function: is_certification_approved**
/// - Calls `Certification_Verifier.leo` to check if a certification is officially approved.
function is_certification_approved(certification: string) -> bool {
    return certification_verifier::is_certification_approved(certification);
}
