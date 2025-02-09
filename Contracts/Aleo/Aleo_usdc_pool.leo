program aleo_usdc_pool.aleo;

mapping employer_balances:
    key address as field;
    value u64 as field;

mapping employer_obligations:
    key address as field;
    value u64 as field;

mapping restricted_employers:
    key address as field;
    value bool as field;

function deposit_aleo_usdc(public employer: address, public amount: u64) -> bool {
    let current_balance = employer_balances.get_or_use(employer, 0u64);
    employer_balances.insert(employer, current_balance + amount);
    return true;
}

function set_employer_obligation(public employer: address, public obligation: u64) -> bool {
    employer_obligations.insert(employer, obligation);
    return true;
}

function withdraw_for_payroll(public employer: address, public amount: u64) -> bool {
    let current_balance = employer_balances.get_or_use(employer, 0u64);
    let employer_obligation = employer_obligations.get_or_use(employer, 0u64);

    // Calculate required balance (25% more than total employer obligations)
    let required_balance = employer_obligation * 125u64 / 100u64;
    ensure(current_balance >= required_balance, "AleoUSDC Pool is below the required threshold");

    ensure(current_balance >= amount, "Insufficient AleoUSDC balance");
    employer_balances.insert(employer, current_balance - amount);
    return true;
}

function restrict_employer(public employer: address) -> bool {
    restricted_employers.insert(employer, true);
    return true;
}

function reinstate_employer(public employer: address) -> bool {
    ensure(restricted_employers.contains(employer), "Employer is not restricted");
    restricted_employers.insert(employer, false);
    return true;
}

function get_employer_balance(public employer: address) -> u64 {
    return employer_balances.get_or_use(employer, 0u64);
}

function get_required_pool_balance(public employer: address) -> u64 {
    let employer_obligation = employer_obligations.get_or_use(employer, 0u64);
    return employer_obligation * 125u64 / 100u64;
}

function is_employer_restricted(public employer: address) -> bool {
    return restricted_employers.get_or_use(employer, false);
}
