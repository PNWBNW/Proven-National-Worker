// process_tax_compliance.leo

import 0x01::payroll;
import 0x01::pncw_payroll;
import 0x01::pniw_payroll;
import 0x01::merkle_helper;
import 0x01::government_api;

// 🏷️ Mappings
mapping employer_tax:
    key u64 as field;
    value EmployerTaxRecord as record; // Employer tax compliance records

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
struct EmployerTaxRecord has store {
    employer_id: u64,
    total_tax_paid: u64,
    last_payment_timestamp: u64,
    is_compliant: bool,
}

// ✅ Function: Process tax compliance for PNcW and PNiW payrolls
public fun process_tax_compliance(employer_id: u64, payroll_type: u8) -> bool {
    ensure!(employer_zpass_verified.get_or_use(employer_id, false), "Employer must be ZPass verified for tax compliance");

    let mut tax_due: u64 = 0;

    // Determine tax obligations based on payroll type
    match payroll_type {
        0 => tax_due = pncw_payroll::calculate_tax_due(employer_id),
        1 => tax_due = pniw_payroll::calculate_tax_due(employer_id),
        _ => return false, // Invalid payroll type
    };

    let mut employer_record = employer_tax.get_or_use(employer_id, EmployerTaxRecord {
        employer_id: employer_id,
        total_tax_paid: 0u64,
        last_payment_timestamp: 0u64,
        is_compliant: false,
    });

    // Update compliance status
    employer_record.is_compliant = employer_record.total_tax_paid >= tax_due;
    employer_tax[employer_id] = employer_record;

    return employer_record.is_compliant;
}

// ✅ Function: Process tax compliance using ANS
public fun process_tax_compliance_by_ans(employer_ans: string, payroll_type: u8) -> bool {
    let employer_id = lookup_employer_by_ans(employer_ans);
    return process_tax_compliance(employer_id, payroll_type);
}

// ✅ Function: Employers pay taxes
public fun pay_taxes(employer_id: u64, amount: u64) {
    ensure!(employer_zpass_verified.get_or_use(employer_id, false), "Employer must be ZPass verified to pay taxes");

    let mut employer_record = employer_tax.get_or_use(employer_id, EmployerTaxRecord {
        employer_id: employer_id,
        total_tax_paid: 0u64,
        last_payment_timestamp: 0u64,
        is_compliant: false,
    });

    employer_record.total_tax_paid += amount;
    employer_record.last_payment_timestamp = timestamp();
    employer_record.is_compliant = process_tax_compliance(employer_id, 0) || process_tax_compliance(employer_id, 1);

    employer_tax[employer_id] = employer_record;
}

// ✅ Function: Employers pay taxes using ANS
public fun pay_taxes_by_ans(employer_ans: string, amount: u64) {
    let employer_id = lookup_employer_by_ans(employer_ans);
    pay_taxes(employer_id, amount);
}

// ✅ Function: Check employer tax compliance status
public fun check_compliance(employer_id: u64) -> bool {
    let employer_record = employer_tax.get_or_use(employer_id, EmployerTaxRecord {
        employer_id: employer_id,
        total_tax_paid: 0u64,
        last_payment_timestamp: 0u64,
        is_compliant: false,
    });

    return employer_record.is_compliant;
}

// ✅ Function: Check employer tax compliance using ANS
public fun check_compliance_by_ans(employer_ans: string) -> bool {
    let employer_id = lookup_employer_by_ans(employer_ans);
    return check_compliance(employer_id);
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
