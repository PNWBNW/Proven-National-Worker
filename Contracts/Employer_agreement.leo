program employer_agreement.aleo;

mapping employer_registry:
    key: address;
    value: (u64, u64, u64, bool); // (prepaid_wages, prepaid_taxes, last_payment_timestamp, is_blacklisted)

mapping employer_tax_fund:
    key: address;
    value: u64; // Employer's tax fund balance

mapping blacklisted_employers:
    key: address;
    value: u64; // Timestamp of blacklist entry

function register_employer(employer: address, initial_wages: u64, initial_taxes: u64) -> bool {
    if employer_registry.contains(employer) {
        return false; // Employer already registered
    }

    employer_registry[employer] = (initial_wages, initial_taxes, get_block_height(), false);
    employer_tax_fund[employer] = initial_taxes;

    return true;
}

function top_up_funds(employer: address, wages: u64, taxes: u64) -> bool {
    if !employer_registry.contains(employer) {
        return false; // Employer not registered
    }

    let (current_wages, current_taxes, last_payment, is_blacklisted) = employer_registry[employer];
    if is_blacklisted {
        return false; // Blacklisted employers cannot top up
    }

    employer_registry[employer] = (current_wages + wages, current_taxes + taxes, get_block_height(), false);
    employer_tax_fund[employer] += taxes;

    return true;
}

function process_payroll(employer: address, amount: u64) -> bool {
    if !employer_registry.contains(employer) {
        return false; // Employer not registered
    }

    let (current_wages, current_taxes, last_payment, is_blacklisted) = employer_registry[employer];
    if is_blacklisted || current_wages < amount {
        return false; // Insufficient funds or blacklisted employer
    }

    employer_registry[employer] = (current_wages - amount, current_taxes, get_block_height(), false);
    
    return true;
}

function pay_employer_taxes(employer: address) -> bool {
    if !employer_registry.contains(employer) {
        return false; // Employer not registered
    }

    let (current_wages, current_taxes, last_payment, is_blacklisted) = employer_registry[employer];
    if is_blacklisted || current_taxes == 0 {
        return false; // No taxes owed or employer is blacklisted
    }

    employer_registry[employer] = (current_wages, 0, get_block_height(), false);
    employer_tax_fund[employer] = 0;

    return true;
}

function blacklist_employer(employer: address) -> bool {
    if !employer_registry.contains(employer) {
        return false; // Employer not registered
    }

    let (current_wages, current_taxes, last_payment, _) = employer_registry[employer];
    employer_registry[employer] = (current_wages, current_taxes, last_payment, true);
    blacklisted_employers[employer] = get_block_height();

    return true;
}

function reinstate_employer(employer: address, fine_amount: u64) -> bool {
    if !blacklisted_employers.contains(employer) {
        return false; // Employer is not blacklisted
    }

    let (current_wages, current_taxes, last_payment, _) = employer_registry[employer];
    let total_fine = (current_taxes * 125) / 100; // Unpaid taxes + 25% penalty
    let subdao_fund_bonus = (current_taxes * 25) / 100; // Additional 25% to SubDAO fund

    if fine_amount < total_fine {
        return false; // Insufficient fine payment
    }

    employer_registry[employer] = (current_wages, 0, get_block_height(), false);
    blacklisted_employers.remove(employer);

    return true;
}
