program certification_verifier.leo;

/// **Mappings**
mapping approved_certifications: string => bool;  // Stores approved certifications
mapping certifying_agencies: address => bool;  // Stores authorized certifying entities
mapping certification_requests: string => address;  // Tracks pending certifications submitted by employers

/// **Function: register_certifying_agency**
/// - Grants an entity (government, regulator) the right to approve certifications.
/// - Only an admin-level entity can call this function.
function register_certifying_agency(agency: address) -> bool {
    let admin: address = caller();
    assert!(is_system_admin(admin), "Unauthorized access.");

    certifying_agencies[agency] = true;
    return true;
}

/// **Function: request_certification**
/// - Employers submit certification requests for approval.
/// - Requires verification from an approved certifying agency.
function request_certification(certification: string) -> bool {
    let employer: address = caller();

    // Ensure the certification is valid before requesting approval
    assert!(is_valid_certification(certification), "Invalid certification request.");

    certification_requests[certification] = employer;
    return true;
}

/// **Function: approve_certification**
/// - Approves a certification request for an employer.
/// - Only an authorized certifying agency can call this function.
function approve_certification(certification: string) -> bool {
    let agency: address = caller();
    assert!(certifying_agencies[agency], "Unauthorized entity.");

    // Ensure the certification request exists
    let employer = certification_requests[certification];
    assert!(employer != 0, "No pending certification request found.");

    approved_certifications[certification] = true;

    // Remove from pending requests
    delete certification_requests[certification];

    return true;
}

/// **Function: revoke_certification**
/// - Removes an approved certification if it becomes invalid or fraudulent.
/// - Only an authorized certifying agency can revoke certifications.
function revoke_certification(certification: string) -> bool {
    let agency: address = caller();
    assert!(certifying_agencies[agency], "Unauthorized entity.");

    approved_certifications[certification] = false;
    return true;
}

/// **Function: is_certification_approved**
/// - Checks if a certification is officially verified and valid.
function is_certification_approved(certification: string) -> bool {
    return approved_certifications[certification];
}

/// **Helper Function: is_valid_certification**
/// - Ensures only recognized certification names can be submitted.
function is_valid_certification(cert: string) -> bool {
    let valid_certs = ["USDA Organic", "Certified Humane", "Non-GMO", "Wild-Caught", 
                       "Farm-Raised", "Gluten-Free", "Sustainable"];
    return contains(valid_certs, cert);
}

/// **Helper Function: is_system_admin**
/// - Ensures only admin-level entities can register certifying agencies.
function is_system_admin(entity: address) -> bool {
    let admin_list = [/* List of system admin addresses */];
    return contains(admin_list, entity);
}
