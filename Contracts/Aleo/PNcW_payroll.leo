program pncw_payroll.aleo;

mapping worker_category: mapping(address, string); // Worker category flagging
mapping pto_balances: mapping(address, u64);      // PTO balance per worker
mapping sick_balances: mapping(address, u64);     // Sick leave balance per worker
mapping employer_pto_funds: mapping(address, u64); // Employer-held PTO funds
mapping employer_sick_funds: mapping(address, u64); // Employer-held Sick funds
mapping payroll_records: mapping(address, u64);   // Worker payroll balances

mapping farm_investments: mapping(address, u64); // Tracks PTO/Sick Pay used for farm investment
mapping trust_funds: mapping(address, u64); // Trust fund balances per worker
mapping minimum_usdc_pool: mapping(address, u64); // Minimum required liquidity per employer

// Struct to track worker payroll and benefits
struct WorkerPayroll {
    worker_address: address,
    employer: address,
    wage: u64,
    accrued_pto: u64,
    accrued_sick: u64,
    trust_fund_balance: u64,
    last_payroll_time: u64,
}

// Process payroll with PTO/Sick Pay accrual and trust fund contribution
function process_payroll(worker: address, employer: address, wage: u64, hours_worked: u64, trust_contribution: u64) {
    ensure!(verify_employer_funding(employer), "Employer has not funded PTO/Sick Pay reserves");
    ensure!(verify_usdc_pool(employer), "Employer USDC pool is below required minimum");

    let pto_rate = 1 / 20;  // 1 hour PTO per 20 hours worked
    let sick_rate = 1 / 40;  // Washington Sick Leave: 1 hour per 40 hours worked

    let pto_accrued = hours_worked * pto_rate;
    let sick_accrued = hours_worked * sick_rate;

    // Update balances
    payroll_records[worker] += wage;
    pto_balances[worker] += pto_accrued;
    sick_balances[worker] += sick_accrued;
    trust_funds[worker] += trust_contribution;

    // Deduct from employer reserves
    employer_pto_funds[employer] -= pto_accrued;
    employer_sick_funds[employer] -= sick_accrued;
}

// Ensure employer maintains the required USDC liquidity
function verify_usdc_pool(employer: address) -> bool {
    let required_usdc = minimum_usdc_pool[employer];
    let employer_balance = get_usdc_balance(employer);

    ensure!(employer_balance >= required_usdc, "Employer USDC pool is insufficient");
    return true;
}

// Employer deposits USDC into payroll pool
function employer_deposit_usdc(employer: address, amount: u64) {
    let current_balance = get_usdc_balance(employer);
    set_usdc_balance(employer, current_balance + amount);
}

// Employer penalties for failing to maintain minimum liquidity
function enforce_usdc_penalty(employer: address) {
    let required_usdc = minimum_usdc_pool[employer];
    let employer_balance = get_usdc_balance(employer);

    if employer_balance < required_usdc {
        let penalty = (required_usdc - employer_balance) / 10; // 10% penalty for underfunding
        employer_penalty(employer, penalty);
    }
}

// Worker requests payroll withdrawal (including PTO/Sick Pay, excluding trust funds)
function withdraw_payroll(worker: address, amount: u64, include_pto: bool, include_sick: bool) -> bool {
    ensure!(verify_usdc_pool(worker), "Employer's USDC pool is insufficient for withdrawals");

    let total_balance = payroll_records[worker];

    if include_pto {
        total_balance += pto_balances[worker];
    }
    if include_sick {
        total_balance += sick_balances[worker];
    }

    ensure!(total_balance >= amount, "Insufficient balance");

    // Deduct from respective balances
    if include_pto {
        pto_balances[worker] -= amount;
    } else {
        payroll_records[worker] -= amount;
    }
    
    if include_sick {
        sick_balances[worker] -= amount;
    }

    // Send funds to worker
    transfer_private worker amount;
    return true;
}

// Worker invests PTO/Sick Pay into farm investment (Only for Agricultural workers)
function invest_pto_sick_pay(worker: address, amount: u64, source: string) -> bool {
    let category = worker_category[worker];

    // Restrict farm investment to Agricultural workers only
    ensure!(category == "Agricultural", "Only workers in the Agricultural industry can invest in farm projects");

    ensure!(source == "PTO" || source == "Sick", "Invalid source; must be PTO or Sick Pay");

    if source == "PTO" {
        ensure!(pto_balances[worker] >= amount, "Insufficient PTO balance");
        pto_balances[worker] -= amount;
    } else {
        ensure!(sick_balances[worker] >= amount, "Insufficient Sick Pay balance");
        sick_balances[worker] -= amount;
    }

    // Allocate funds to farm investment
    farm_investments[worker] += amount;

    return true;
}

// Ensure employer has properly funded PTO/Sick Pay pools
function verify_employer_funding(employer: address) -> bool {
    ensure!(employer_pto_funds[employer] >= 0, "Employer PTO fund deficit detected");
    ensure!(employer_sick_funds[employer] >= 0, "Employer Sick Pay fund deficit detected");
    return true;
}

// Employer penalties for noncompliance
function employer_penalty(employer: address, penalty_amount: u64) {
    ensure!(penalty_amount > 0, "Penalty must be greater than zero");
    
    // Deduct from employer funds
    employer_pto_funds[employer] -= penalty_amount / 2;
    employer_sick_funds[employer] -= penalty_amount / 2;
    
    // Distribute penalties to a worker protection pool or DAO fund
    transfer_private dao_treasury penalty_amount;
}

// SubDAO function to check employer compliance
function subdao_check_compliance(employer: address) -> bool {
    let pto_funding = employer_pto_funds[employer];
    let sick_funding = employer_sick_funds[employer];

    if pto_funding < 0 || sick_funding < 0 {
        employer_penalty(employer, 500); // Example: $500 penalty for noncompliance
        return false;
    }

    enforce_usdc_penalty(employer); // Also enforce USDC liquidity rules
    return true;
}

// Utility function to get employer's USDC balance
function get_usdc_balance(employer: address) -> u64 {
    return employer_usdc_pool[employer];
}

// Utility function to update employer's USDC balance
function set_usdc_balance(employer: address, amount: u64) {
    employer_usdc_pool[employer] = amount;
}}
