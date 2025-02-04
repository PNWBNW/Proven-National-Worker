// pniw_payroll.leo

import 0x01::payroll;
import 0x01::worker_identity;
import 0x01::employer_agreement;
import 0x01::process_tax_compliance;
import 0x01::government_api;

// Structure to track PNiW payroll records
struct PNiWPayroll has store {
    worker_id: u64,
    employer_id: u64,
    amount: u64,
    processed: bool,
}

// Mapping to store payroll data
mapping pniw_payroll_records: u64 -> PNiWPayroll;

// Function to add a payroll entry
public fun add_payroll(worker_id: u64, employer_id: u64, amount: u64) -> bool {
    assert!(worker_identity::is_verified_worker(worker_id), 0);
    assert!(employer_agreement::is_compliant_employer(employer_id), 0);
    assert!(amount > 0, 0);

    let new_payroll = PNiWPayroll {
        worker_id: worker_id,
        employer_id: employer_id,
        amount: amount,
        processed: false,
    };

    pniw_payroll_records[worker_id] = new_payroll;
    return true;
}

// Function to process payroll for a worker
public fun process_payroll(worker_id: u64) -> bool {
    let mut payroll_entry = pniw_payroll_records[worker_id];

    // Ensure employer is compliant before processing
    let compliant = process_tax_compliance::check_compliance(payroll_entry.employer_id);
    assert!(compliant, 0);

    let success = payroll::execute_payroll(payroll_entry.worker_id, payroll_entry.amount);
    if success {
        payroll_entry.processed = true;
        pniw_payroll_records[worker_id] = payroll_entry;
    }

    return success;
}

// Function to check if payroll has been processed
public fun is_payroll_processed(worker_id: u64) -> bool {
    let payroll_entry = pniw_payroll_records[worker_id];
    return payroll_entry.processed;
}
