program compliance_tracking.aleo;

mapping employer_compliance:
    key: address;
    value: (u64, u64, u8, bool); // (total_taxes_paid, last_payment_timestamp, missed_payments, blacklisted)

mapping worker_reports:
    key: address;
    value: u64; // Number of complaints filed against the employer

mapping blacklisted_employers:
    key: address;
    value: bool; // True if the employer is banned

function record_tax_payment(employer: address, amount: u64) -> bool {
    let timestamp = get_block_height();

    if employer_compliance.contains(employer) {
        let (total_paid, _, missed, blacklisted) = employer_compliance[employer];

        employer_compliance[employer] = (total_paid + amount, timestamp, 0, blacklisted);
    } else {
        employer_compliance[employer] = (amount, timestamp, 0, false);
    }

    return true;
}

function flag_missed_payment(employer: address) -> bool {
    if !employer_compliance.contains(employer) {
        return false;
    }

    let (total_paid, last_payment, missed, blacklisted) = employer_compliance[employer];

    let new_missed = missed + 1;
    let new_blacklist = if new_missed >= 3 { true } else { blacklisted };

    employer_compliance[employer] = (total_paid, last_payment, new_missed, new_blacklist);

    if new_blacklist {
        blacklisted_employers[employer] = true;
    }

    return true;
}

function report_employer(worker: address, employer: address) -> bool {
    if !worker_reports.contains(employer) {
        worker_reports[employer] = 1;
    } else {
        worker_reports[employer] += 1;
    }

    return true;
}

function is_blacklisted(employer: address) -> bool {
    return blacklisted_employers[employer];
}

function pay_reinstatement_fine(employer: address, fine_amount: u64) -> bool {
    if !is_blacklisted(employer) {
        return false;
    }

    let (total_paid, last_payment, missed, _) = employer_compliance[employer];

    employer_compliance[employer] = (total_paid + fine_amount, last_payment, 0, false);
    blacklisted_employers.remove(employer);

    return true;
}
