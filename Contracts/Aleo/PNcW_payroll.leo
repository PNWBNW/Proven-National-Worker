program pncw_payroll.leo;

// 🏷️ Mappings
mapping worker_category: mapping(address, string); // Worker category flagging
mapping pto_balances: mapping(address, u64);      // PTO balance per worker
mapping sick_balances: mapping(address, u64);     // Sick leave balance per worker
mapping employer_pto_funds: mapping(address, u64); // Employer-held PTO funds
mapping employer_sick_funds: mapping(address, u64); // Employer-held Sick funds
mapping payroll_records: mapping(address, u64);   // Worker payroll balances
mapping farm_investments: mapping(address, u64);  // Tracks PTO/Sick Pay used for farm investment
mapping trust_funds: mapping(address, u64);       // Trust fund balances per worker
mapping minimum_usdc_pool: mapping(address, u64); // Minimum required liquidity per employer

// 🔹 New ANS Mappings
mapping ans_registry: mapping(address, string);  // Maps worker addresses to ANS names
mapping ans_reverse_lookup: mapping(string, address);  // Maps ANS names to worker addresses

// 📦 Structs
struct WorkerPayroll {
    worker_address: address,
    employer: address,
    wage: u64,
    accrued_pto: u64,
    accrued_sick: u64,
    trust_fund_balance: u64,
    last_payroll_time: u64,
    ans_name: string,  // New field for ANS
}

// ✅ Process payroll with PTO/Sick Pay accrual and trust fund contribution
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

// ✅ Function: Process payroll using ANS (instead of wallet address)
function process_payroll_by_ans(ans_name: string, employer: address, wage: u64, hours_worked: u64, trust_contribution: u64) {
    let worker = lookup_worker_by_ans(ans_name);  // Convert ANS to wallet address
    process_payroll(worker, employer, wage, hours_worked, trust_contribution);
}

// ✅ Ensure employer maintains the required USDC liquidity
function verify_usdc_pool(employer: address) -> bool {
    let required_usdc = minimum_usdc_pool[employer];
    let employer_balance = get_usdc_balance(employer);

    ensure!(employer_balance >= required_usdc, "Employer USDC pool is insufficient");
    return true;
}

// ✅ Employer deposits USDC into payroll pool
function employer_deposit_usdc(employer: address, amount: u64) {
    let current_balance = get_usdc_balance(employer);
    set_usdc_balance(employer, current_balance + amount);
}

// ✅ Employer penalties for failing to maintain minimum liquidity
function enforce_usdc_penalty(employer: address) {
    let required_usdc = minimum_usdc_pool[employer];
    let employer_balance = get_usdc_balance(employer);

    if employer_balance < required_usdc {
        let penalty = (required_usdc - employer_balance) / 10; // 10% penalty for underfunding
        employer_penalty(employer, penalty);
    }
}

// ✅ Worker requests payroll withdrawal (Supports ANS-based transactions)
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

// ✅ Worker requests payroll withdrawal using ANS
function withdraw_payroll_by_ans(ans_name: string, amount: u64, include_pto: bool, include_sick: bool) -> bool {
    let worker = lookup_worker_by_ans(ans_name);
    withdraw_payroll(worker, amount, include_pto, include_sick);
}

// ✅ Worker invests PTO/Sick Pay into farm investment (Only for Agricultural workers)
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

// ✅ Ensure employer has properly funded PTO/Sick Pay pools
function verify_employer_funding(employer: address) -> bool {
    ensure!(employer_pto_funds[employer] >= 0, "Employer PTO fund deficit detected");
    ensure!(employer_sick_funds[employer] >= 0, "Employer Sick Pay fund deficit detected");
    return true;
}

// ✅ Employer penalties for noncompliance
function employer_penalty(employer: address, penalty_amount: u64) {
    ensure!(penalty_amount > 0, "Penalty must be greater than zero");
    
    // Deduct from employer funds
    employer_pto_funds[employer] -= penalty_amount / 2;
    employer_sick_funds[employer] -= penalty_amount / 2;
    
    // Distribute penalties to a worker protection pool or DAO fund
    transfer_private dao_treasury penalty_amount;
}

// ✅ Utility function: Lookup a worker's ANS name by address
function lookup_worker_by_address(worker: address) -> string {
    ensure!(ans_registry.contains(worker), "Worker does not have an ANS name");
    return ans_registry[worker];
}

// ✅ Utility function: Lookup a worker's address by ANS name
function lookup_worker_by_ans(ans_name: string) -> address {
    ensure!(ans_reverse_lookup.contains(ans_name), "ANS name not found");
    return ans_reverse_lookup[ans_name];
}

// ✅ Utility function: Get employer's USDC balance
function get_usdc_balance(employer: address) -> u64 {
    return employer_usdc_pool[employer];
}

// ✅ Utility function: Update employer's USDC balance
function set_usdc_balance(employer: address, amount: u64) {
    employer_usdc_pool[employer] = amount;
}
