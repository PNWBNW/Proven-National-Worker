program certification_verifier.aleo;

/// **Mappings**
mapping approved_certifications: string => bool;  // Stores approved certifications
mapping certifying_agencies: address => bool;  // Stores authorized certifying entities

/// **Function: register_certifying_agency**
/// - Adds an entity (government, regulator) to the approved list.
/// - Only an admin-level entity can call this function.
function register_certifying_agency(agency: address) -> bool {
    let admin: address = caller();
    assert!(is_system_admin(admin), "Unauthorized access.");

    certifying_agencies[agency] = true;
    return true;
}

/// **Function: approve_certification**
/// - Called via API by authorized government or regulatory entities.
/// - Approves a farm certification.
function approve_certification(certification: string) -> bool {
    let agency: address = caller();
    assert!(certifying_agencies[agency], "Unauthorized entity.");

    approved_certifications[certification] = true;
    return true;
}

/// **Function: revoke_certification**
/// - Allows revoking a previously approved certification.
/// - Ensures fraudulent or expired certifications are removed.
function revoke_certification(certification: string) -> bool {
    let agency: address = caller();
    assert!(certifying_agencies[agency], "Unauthorized entity.");

    approved_certifications[certification] = false;
    return true;
}

/// **Function: is_certification_approved**
/// - Checks if a certification is officially verified.
function is_certification_approved(certification: string) -> bool {
    return approved_certifications[certification];
}

/// **Function: is_system_admin**
/// - Ensures only admin-level entities can register certifying agencies.
function is_system_admin(entity: address) -> bool {
    let admin_list = [/* List of system admin addresses */];
    return contains(admin_list, entity);
}
