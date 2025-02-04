// process_tax_compliance.leo

import 0x01::payroll;
import 0x01::pncw_payroll;
import 0x01::pniw_payroll;
import 0x01::merkle_helper;

// Structure to track employer tax compliance
struct EmployerTaxRecord has store {
    employer_id: u64,
    total_tax_paid: u64,
    last_payment_timestamp: u64,
    is_compliant: bool,
}

// Mapping for employer tax records
mapping employer_tax: u64 -> EmployerTaxRecord;

// Function to process tax compliance for PNcW and PNiW payrolls
public fun process_tax_compliance(employer_id: u64, payroll_type: u8) -> bool {
    let mut tax_due: u64 = 0;

    // Determine tax obligations based on payroll type
    match payroll_type {
        0 => tax_due = pncw_payroll::calculate_tax_due(employer_id),
        1 => tax_due = pniw_payroll::calculate_tax_due(employer_id),
        _ => return false, // Invalid payroll type
    };

    let employer_record = employer_tax[employer_id];
    if employer_record.total_tax_paid >= tax_due {
        employer_record.is_compliant = true;
    } else {
        employer_record.is_compliant = false;
    }

    employer_tax[employer_id] = employer_record;
    return employer_record.is_compliant;
}

// Function for employers to pay taxes
public fun pay_taxes(employer_id: u64, amount: u64) {
    let mut employer_record = employer_tax[employer_id];
    employer_record.total_tax_paid += amount;
    employer_record.last_payment_timestamp = timestamp();
    employer_record.is_compliant = process_tax_compliance(employer_id, 0) || process_tax_compliance(employer_id, 1);

    employer_tax[employer_id] = employer_record;
}

// Function to check employer compliance status
public fun check_compliance(employer_id: u64) -> bool {
    let employer_record = employer_tax[employer_id];
    return employer_record.is_compliant;
}
