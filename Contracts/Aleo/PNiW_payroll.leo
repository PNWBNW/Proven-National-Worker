program pniw_payroll.leo;

mapping employer_balances:
    key address as field;
    value u64 as field;

mapping payroll_history:
    key address as field;
    value (address, u64, bool) as record; // (Worker, Amount, Processed)

mapping restricted_employers:
    key address as field;
    value bool as field;

mapping employer_obligations:
    key address as field;
    value u64 as field;

function process_payroll(public employer: address, public worker: address, public amount: u64) -> bool {
    ensure(!restricted_employers.get_or_use(employer, false), "Employer is restricted");

    let fiat_balance = FiatUSDCPool.get_fiat_balance(employer);
    let aleo_balance = aleo_usdc_pool.get_employer_balance(employer);
    let required_balance = aleo_usdc_pool.get_required_pool_balance(employer);

    ensure(aleo_balance >= required_balance, "AleoUSDC Pool balance below 25% threshold");

    if fiat_balance >= amount {
        FiatUSDCPool.withdraw_for_payroll(employer, amount);
        payroll_history.insert(worker, (employer, amount, true));
        return true;
    } else {
        let shortfall = amount - fiat_balance;
        ensure(aleo_balance >= shortfall, "Insufficient AleoUSDC to cover payroll shortfall");

        aleo_usdc_pool.withdraw_for_payroll(employer, shortfall);
        payroll_history.insert(worker, (employer, amount, true));
        return true;
    }
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

function get_payroll_status(public worker: address) -> (address, u64, bool) {
    return payroll_history.get_or_use(worker, (0address, 0u64, false));
}

function update_employer_obligation(public employer: address, public obligation: u64) -> bool {
    employer_obligations.insert(employer, obligation);
    return true;
}

function get_employer_obligation(public employer: address) -> u64 {
    return employer_obligations.get_or_use(employer, 0u64);
}
