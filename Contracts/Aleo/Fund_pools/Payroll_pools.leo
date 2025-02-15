program payroll_pools.leo;

// 🏷️ Payroll Pool Mappings (Per SubDAO)
mapping payroll_balances: public hashmap<string, u64>;  // SubDAO payroll fund pools (ANS-based)
mapping employer_obligations: public hashmap<address, u64>;  // Employer payroll obligations
mapping restricted_employers: public hashmap<address, bool>;  // Employer restriction for non-compliance

/// @dev Deposits USDC into a specific SubDAO payroll pool
function deposit_aleo_usdc(public employer: address, public subdao_ans: string, public amount: u64) -> bool {
    let current_balance = payroll_balances.get_or_use(subdao_ans, 0u64);
    payroll_balances.insert(subdao_ans, current_balance + amount);
    return true;
}

/// @dev Withdraws USDC from a SubDAO payroll pool for payroll processing
function withdraw_for_payroll(public employer: address, public subdao_ans: string, public amount: u64) -> bool {
    let current_balance = payroll_balances.get_or_use(subdao_ans, 0u64);
    let employer_obligation = employer_obligations.get_or_use(employer, 0u64);

    // Ensure employer maintains 25% more than total obligations
    let required_balance = employer_obligation * 125u64 / 100u64;
    ensure!(current_balance >= required_balance, "SubDAO Payroll Pool is below the required threshold");
    ensure!(current_balance >= amount, "Insufficient USDC balance in payroll pool");

    payroll_balances.insert(subdao_ans, current_balance - amount);
    return true;
}

/// @dev Sets the required employer payroll obligation
function set_employer_obligation(public employer: address, public obligation: u64) -> bool {
    employer_obligations.insert(employer, obligation);
    return true;
}

/// @dev Restricts an employer from using payroll funds due to non-compliance
function restrict_employer(public employer: address) -> bool {
    restricted_employers.insert(employer, true);
    return true;
}

/// @dev Reinstates a previously restricted employer
function reinstate_employer(public employer: address) -> bool {
    ensure!(restricted_employers.contains(employer), "Employer is not restricted");
    restricted_employers.insert(employer, false);
    return true;
}

/// @dev Gets the payroll balance of a specific SubDAO payroll pool
function get_subdao_payroll_balance(public subdao_ans: string) -> u64 {
    return payroll_balances.get_or_use(subdao_ans, 0u64);
}

/// @dev Gets the required minimum balance for a SubDAO payroll pool
function get_required_pool_balance(public employer: address) -> u64 {
    let employer_obligation = employer_obligations.get_or_use(employer, 0u64);
    return employer_obligation * 125u64 / 100u64;
}

/// @dev Checks if an employer is restricted from payroll access
function is_employer_restricted(public employer: address) -> bool {
    return restricted_employers.get_or_use(employer, false);
}
