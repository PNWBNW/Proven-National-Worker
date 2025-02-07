program employer_agreement.aleo;

/// **Mappings**
mapping employer_farm_types: address => [u8];  // Stores allowed farm types per employer
mapping employer_certifications: address => [string];  // Stores farm certifications
mapping employer_max_worker_investment: address => u64;  // Maximum worker investment cap per employer
mapping employer_current_worker_investment: address => u64;  // Tracks total worker investment per employer

/// **Farm Type Categories**
/// 1 = Organic, 2 = Sustainable, 3 = Produce, 4 = Dairy, 5 = Poultry, 6 = Pork, 7 = Beef, 8 = Fish,
/// 9 = Grains, 10 = Coffee, 11 = Spices, 12 = Teas
mapping farm_type_labels: u8 => string = {
    1 => "Organic",
    2 => "Sustainable",
    3 => "Produce",
    4 => "Dairy",
    5 => "Poultry",
    6 => "Pork",
    7 => "Beef",
    8 => "Fish",
    9 => "Grains",
    10 => "Coffee",
    11 => "Spices",
    12 => "Teas"
};

/// **Function: set_farm_types**
/// - Employers define the farm types they produce.
/// - Workers can only invest in these allowed types.
/// - Prevents investing in unsupported farm categories.
function set_farm_types(farm_types: [u8]) -> bool {
    let employer: address = caller();
    
    // Validate farm types (1-12)
    for farm_type in farm_types {
        assert!(farm_type >= 1 && farm_type <= 12, "Invalid farm type.");
    }

    // Store allowed farm types for this employer
    employer_farm_types[employer] = farm_types;
    
    return true;
}

/// **Function: get_farm_types**
/// - Returns the approved farm types for a specific employer.
function get_farm_types(employer: address) -> [u8] {
    return employer_farm_types[employer];
}

/// **Function: set_max_worker_investment**
/// - Employers can set a cap on total worker investment.
/// - Prevents excessive worker investment from disrupting agreed-upon purchase deals.
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
/// - Employers submit their farm certifications for approval.
/// - Examples: USDA Organic, Certified Humane, Non-GMO, Wild-Caught.
function register_certifications(certifications: [string]) -> bool {
    let employer: address = caller();
    
    // Ensure certifications are within allowed categories
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

/// **Function: is_farm_type_allowed**
/// - Checks if an employer allows a specific farm type.
function is_farm_type_allowed(employer: address, farm_type: u8) -> bool {
    let allowed_types = employer_farm_types[employer];
    return contains(allowed_types, farm_type);
}

/// **Function: is_certification_valid**
/// - Ensures a certification is both registered and verified.
function is_certification_valid(employer: address, certification: string) -> bool {
    let certs = employer_certifications[employer];
    return contains(certs, certification) && is_certification_approved(certification);
}

/// **Function: update_worker_investment**
/// - Updates the total investment amount made by workers.
/// - Ensures the cap is not exceeded.
function update_worker_investment(employer: address, amount: u64) -> bool {
    let current_total = employer_current_worker_investment[employer];
    let max_limit = employer_max_worker_investment[employer];

    assert!(current_total + amount <= max_limit, "Worker investment limit exceeded.");
    
    employer_current_worker_investment[employer] += amount;
    
    return true;
}

/// **Function: reset_worker_investment**
/// - Resets worker investment tracking (called after each harvest cycle).
function reset_worker_investment(employer: address) -> bool {
    let authorized: address = caller();
    assert!(authorized == employer, "Only the employer can reset investments.");

    employer_current_worker_investment[employer] = 0;
    
    return true;
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
