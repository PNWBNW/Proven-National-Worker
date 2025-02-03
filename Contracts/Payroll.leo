program payroll.aleo;

mapping payroll_balances:
    key: address;  // Worker address
    value: u64;    // Wages available

mapping employer_contributions:
    key: address;  // Employer address
    value: u64;    // Funds set aside for worker payments

// New: Function to allocate wages toward farm ownership
function allocate_wages(worker: address, farm: address, amount: u64) -> bool {
    assert(amount > 0, "Allocation amount must be greater than zero");

    let worker_balance = payroll_balances.get(worker);
    assert(worker_balance >= amount, "Insufficient wages");

    // Deduct from worker's payroll balance
    let new_balance = worker_balance - amount;
    payroll_balances.insert(worker, new_balance);

    // Call farm investment contract
    let new_share = farm_investment::invest_in_farm(worker, farm, amount);
    
    return new_share > 0;
}

// Function: Process payroll for workers
function process_payroll(employer: address, worker: address, amount: u64) -> bool {
    assert(amount > 0, "Payment amount must be greater than zero");

    let employer_balance = employer_contributions.get(employer);
    assert(employer_balance >= amount, "Employer has insufficient funds");

    // Deduct from employer's balance
    let new_employer_balance = employer_balance - amount;
    employer_contributions.insert(employer, new_employer_balance);

    // Credit worker's payroll balance
    let worker_balance = payroll_balances.get_or_use(worker, 0);
    let new_worker_balance = worker_balance + amount;
    payroll_balances.insert(worker, new_worker_balance);

    return true;
}

// Function: Workers withdraw available wages
function withdraw_wages(worker: address, amount: u64) -> u64 {
    assert(amount > 0, "Withdrawal amount must be greater than zero");

    let worker_balance = payroll_balances.get(worker);
    assert(worker_balance >= amount, "Insufficient funds");

    let new_balance = worker_balance - amount;
    payroll_balances.insert(worker, new_balance);

    return amount;  // Worker receives their withdrawn wages
}
