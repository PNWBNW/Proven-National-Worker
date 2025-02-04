// compliance_tracking.leo

import 0x01::payroll;
import 0x01::pncw_payroll;
import 0x01::pniw_payroll;
import 0x01::subdao_governance;
import 0x01::gov_api_verification;

// Structure for tracking employer compliance history
struct EmployerComplianceRecord has store {
    employer_id: u64,
    missed_tax_payments: u8,
    last_verification_timestamp: u64,
    is_blacklisted: bool,
}

// Mapping to store employer compliance records
mapping employer_compliance: u64 -> EmployerComplianceRecord;

// Function to track employer tax compliance
public fun track_compliance(employer_id: u64) -> bool {
    let mut compliance_record = employer_compliance[employer_id];

    // Verify tax payment via government API
    let gov_verified = gov_api_verification::verify_tax_compliance(employer_id);
    if !gov_verified {
        compliance_record.missed_tax_payments += 1;
    } else {
        compliance_record.missed_tax_payments = 0; // Reset missed payments on successful compliance
    }

    compliance_record.last_verification_timestamp = timestamp();

    // Check if employer should be blacklisted
    if compliance_record.missed_tax_payments >= 3 {
        compliance_record.is_blacklisted = true;
        subdao_governance::initiate_blacklist_vote(employer_id);
    }

    employer_compliance[employer_id] = compliance_record;
    return !compliance_record.is_blacklisted;
}

// Function to allow blacklisted employers to pay a reinstatement fine
public fun pay_reinstatement_fine(employer_id: u64, fine_amount: u64) {
    let mut compliance_record = employer_compliance[employer_id];

    // Ensure employer is blacklisted before allowing fine payment
    assert!(compliance_record.is_blacklisted, 0);

    let total_due = payroll::calculate_unpaid_taxes(employer_id) + (fine_amount * 125 / 100); // Unpaid taxes + 25% fine
    payroll::process_employer_payment(employer_id, total_due);

    // Reset compliance status after fine payment
    compliance_record.is_blacklisted = false;
    compliance_record.missed_tax_payments = 0;
    employer_compliance[employer_id] = compliance_record;
}

// Function to check employer compliance history
public fun get_compliance_record(employer_id: u64) -> EmployerComplianceRecord {
    return employer_compliance[employer_id];
}
