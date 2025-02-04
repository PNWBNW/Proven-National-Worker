// government_api.leo

import 0x01::payroll;
import 0x01::compliance_tracking;
import 0x01::pncw_payroll;
import 0x01::pniw_payroll;

// Structure for storing verified tax data
struct TaxVerificationRecord has store {
    employer_id: u64,
    last_verified_amount: u64,
    last_verification_timestamp: u64,
    is_compliant: bool,
}

// Mapping for employer tax verification records
mapping tax_verifications: u64 -> TaxVerificationRecord;

// Function to verify employer tax compliance with government API
public fun verify_tax_compliance(employer_id: u64) -> bool {
    let mut record = tax_verifications[employer_id];

    // Retrieve tax obligations
    let tax_due = pncw_payroll::calculate_tax_due(employer_id) + pniw_payroll::calculate_tax_due(employer_id);

    // Call external API (mocked for on-chain execution)
    let gov_verified_amount = gov_api_call(employer_id); // Simulated API call

    // Compare verified amount with tax obligations
    if gov_verified_amount >= tax_due {
        record.is_compliant = true;
    } else {
        record.is_compliant = false;
    }

    record.last_verified_amount = gov_verified_amount;
    record.last_verification_timestamp = timestamp();
    tax_verifications[employer_id] = record;

    return record.is_compliant;
}

// Function to verify payroll records with government API before payouts
public fun verify_payroll(employer_id: u64, payroll_amount: u64) -> bool {
    let record = tax_verifications[employer_id];

    // Ensure employer is tax-compliant before payroll execution
    if !record.is_compliant {
        return false;
    }

    // Validate payroll against expected compliance thresholds
    let max_payroll_limit = record.last_verified_amount * 3; // Employers can only pay 3x their tax contributions
    return payroll_amount <= max_payroll_limit;
}

// Mock function simulating an external government API call
private fun gov_api_call(employer_id: u64) -> u64 {
    return payroll::get_reported_taxes(employer_id); // Placeholder for off-chain API request
}
