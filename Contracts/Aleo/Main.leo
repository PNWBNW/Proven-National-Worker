program main.leo;

mapping worker_category: mapping(address, string); // Worker category flagging
mapping pto_balances: mapping(address, u64);      // PTO balance per worker
mapping sick_balances: mapping(address, u64);     // Sick leave balance per worker
mapping employer_pto_funds: mapping(address, u64); // Employer-held PTO funds
mapping employer_sick_funds: mapping(address, u64); // Employer-held Sick funds

mapping last_accrual_time: mapping(address, u64); // Last time PTO/Sick Pay was accrued
mapping sick_leave_used: mapping(address, u64); // Tracks sick leave used in current year
mapping farm_investments: mapping(address, u64); // Tracks PTO/Sick Pay used for farm investment

// Struct to track worker PTO and Sick Pay status
struct WorkerPTO {
    worker_address: address,
    category: string,
    accrued_pto: u64,
    accrued_sick: u64,
    last_updated: u64, // Timestamp of last accrual update
}

// Assign category to worker (set by employer)
function set_worker_category(worker: address, category: string) {
    ensure!(category == "General" || category == "Skilled" || category == "Agricultural" || category == "Healthcare",
            "Invalid category");

    worker_category[worker] = category;
}

// Accrue PTO and Sick Pay for a worker during payroll processing
function accrue_pto_sick_pay(worker: address, employer: address, hours_worked: u64) {
    let category = worker_category[worker];
    
    // Adjust accrual rates based on worker category (if needed)
    let sick_rate = if category == "Healthcare" { 1 } else { 1 / 40 };
    let pto_rate = if category == "Agricultural" { 1 / 30 } else { 1 / 20 };

    let sick_accrued = hours_worked * sick_rate;
    let pto_accrued = hours_worked * pto_rate;

    // Track last accrual update
    last_accrual_time[worker] = get_current_time();

    // Update worker balances
    sick_balances[worker] += sick_accrued;
    pto_balances[worker] += pto_accrued;

    // Enforce carryover limit (40 hours sick leave)
    if sick_balances[worker] > 40 {
        sick_balances[worker] = 40;
    }

    // Deduct from employer PTO/Sick Pay reserves
    employer_sick_funds[employer] -= sick_accrued;
    employer_pto_funds[employer] -= pto_accrued;
}

// Worker requests PTO payout
function request_pto(worker: address, amount: u64) -> bool {
    ensure!(pto_balances[worker] >= amount, "Insufficient PTO balance");
    pto_balances[worker] -= amount;
    
    // Send payout to worker
    transfer_private worker amount;
    return true;
}

// Worker requests Sick Pay payout
function request_sick_pay(worker: address, amount: u64, verified: bool) -> bool {
    ensure!(sick_balances[worker] >= amount, "Insufficient Sick Pay balance");

    // Ensure sick pay usage does not exceed 40 hours per year if unverified
    let used_sick_leave = sick_leave_used[worker];
    if verified == false {
        ensure!(used_sick_leave + amount <= 40, "Unverified sick pay requests limited to 40 hours per year");
    }

    // Deduct requested amount
    sick_balances[worker] -= amount;
    sick_leave_used[worker] += amount;

    // Send payout to worker
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

// Employer deposits PTO/Sick Pay reserves
function employer_deposit_funds(employer: address, pto_amount: u64, sick_amount: u64) {
    employer_pto_funds[employer] += pto_amount;
    employer_sick_funds[employer] += sick_amount;
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
    return true;
}

// Utility function to get the current timestamp
function get_current_time() -> u64 {
    return env::block_timestamp();
}
