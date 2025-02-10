// government_api.leo

import 0x01::payroll;
import 0x01::compliance_tracking;
import 0x01::pncw_payroll;
import 0x01::pniw_payroll;
import 0x01::worker_identity;

// 🏷️ Mappings
mapping tax_verifications:
    key u64 as field;
    value TaxVerificationRecord as record; // Employer tax compliance records

mapping employer_zpass_verified:
    key u64 as field;
    value bool as field; // Employer ZPass verification status

// 🔹 New ANS Mappings
mapping ans_registry:
    key u64 as field;
    value string as field;  // Maps employer IDs to ANS names

mapping ans_reverse_lookup:
    key string as field;
    value u64 as field;  // Maps ANS names to employer IDs

// 📦 Structs
struct TaxVerificationRecord has store {
    employer_id: u64,
    last_verified_amount: u64,
    last_verification_timestamp: u64,
    is_compliant: bool,
}

// ✅ Function: Verify employer tax compliance with government API
public fun verify_tax_compliance(employer_id: u64) -> bool {
    ensure!(employer_zpass_verified.get_or_use(employer_id, false), "Employer must be ZPass verified for tax verification");

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

// ✅ Function: Verify employer tax compliance using ANS
public fun verify_tax_compliance_by_ans(employer_ans: string) -> bool {
    let employer_id = lookup_employer_by_ans(employer_ans);
    return verify_tax_compliance(employer_id);
}

// ✅ Function: Verify payroll records with government API before payouts
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

// ✅ Function: Verify payroll using ANS
public fun verify_payroll_by_ans(employer_ans: string, payroll_amount: u64) -> bool {
    let employer_id = lookup_employer_by_ans(employer_ans);
    return verify_payroll(employer_id, payroll_amount);
}

// ✅ Function: Mock function simulating an external government API call
private fun gov_api_call(employer_id: u64) -> u64 {
    return payroll::get_reported_taxes(employer_id); // Placeholder for off-chain API request
}

// ✅ Function: Get employer's last tax verification record
public fun get_tax_verification(employer_id: u64) -> TaxVerificationRecord {
    return tax_verifications.get_or_use(employer_id, TaxVerificationRecord {
        employer_id: employer_id,
        last_verified_amount: 0u64,
        last_verification_timestamp: 0u64,
        is_compliant: false
    });
}

// ✅ Function: Get employer's last tax verification record using ANS
public fun get_tax_verification_by_ans(employer_ans: string) -> TaxVerificationRecord {
    let employer_id = lookup_employer_by_ans(employer_ans);
    return get_tax_verification(employer_id);
}

// ✅ Utility function: Lookup an employer's ANS name by ID
public fun lookup_employer_by_id(employer_id: u64) -> string {
    ensure!(ans_registry.contains(employer_id), "Employer does not have an ANS name");
    return ans_registry[employer_id];
}

// ✅ Utility function: Lookup an employer's ID by ANS name
public fun lookup_employer_by_ans(ans_name: string) -> u64 {
    ensure!(ans_reverse_lookup.contains(ans_name), "ANS name not found");
    return ans_reverse_lookup[ans_name];
}
