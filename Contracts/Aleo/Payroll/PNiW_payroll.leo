program pniw_payroll.aleo;

import mining_investment.leo;

// 🏷️ Mappings
mapping worker_category: public hashmap<address, string>; // Worker category flagging
mapping pto_balances: public hashmap<address, u64>;      // PTO balance per worker
mapping sick_balances: public hashmap<address, u64>;     // Sick leave balance per worker
mapping employer_pto_funds: public hashmap<address, u64>; // Employer-held PTO funds
mapping employer_sick_funds: public hashmap<address, u64>; // Employer-held Sick funds
mapping payroll_records: public hashmap<address, u64>;   // Worker payroll balances
mapping mining_rewards: public hashmap<address, u64>;    // Worker mining earnings
mapping trust_funds: public hashmap<address, u64>;       // Trust fund balances per worker
mapping farm_investments: public hashmap<address, u64>;  // Tracks PTO/Sick Pay used for farm investment
mapping minimum_usdc_pool: public hashmap<address, u64>; // Minimum required liquidity per employer

// 🔹 New ANS Mappings
mapping ans_registry: public hashmap<address, string>;  // Maps worker addresses to ANS names
mapping ans_reverse_lookup: public hashmap<string, address>;  // Maps ANS names to worker addresses

// 📦 Structs
struct WorkerPayroll {
    worker_address: address,
    employer: address,
    wage: u64,
    mining_income: u64,   // Added mining income field
    mining_to_trust: u64, // Mining income allocated to trust fund
    accrued_pto: u64,
    accrued_sick: u64,
    trust_fund_balance: u64,
    last_payroll_time: u64,
    ans_name: string,  // ANS for easier tracking
}

/// @dev Process payroll with PTO/Sick Pay accrual, trust fund contribution, and mining rewards
function process_payroll(worker: address, employer: address, wage: u64, hours_worked: u64, trust_contribution: u64, mining_to_trust: u64) {
    ensure!(verify_employer_funding(employer), "Employer has not funded PTO/Sick Pay reserves");
    ensure!(verify_usdc_pool(employer), "Employer USDC pool is below required minimum");

    let pto_rate = 1 / 20;  // 1 hour PTO per 20 hours worked
    let sick_rate = 1 / 40;  // Washington Sick Leave: 1 hour per 40 hours worked

    let pto_accrued = hours_worked * pto_rate;
    let sick_accrued = hours_worked * sick_rate;

    // Fetch mining income for this payroll cycle
    let mining_income = mining_rewards.get(worker).unwrap_or(0);
    
    // Validate trust allocation
    ensure!(mining_to_trust <= mining_income, "Cannot allocate more mining income than received.");

    // Allocate mining rewards
    mining_rewards[worker] -= mining_to_trust;
    trust_funds[worker] += mining_to_trust;

    // Update balances
    payroll_records[worker] += wage;
    pto_balances[worker] += pto_accrued;
    sick_balances[worker] += sick_accrued;
    trust_funds[worker] += trust_contribution;

    // Deduct from employer reserves
    employer_pto_funds[employer] -= pto_accrued;
    employer_sick_funds[employer] -= sick_accrued;

    // Store payroll record
    let payroll_entry = WorkerPayroll {
        worker_address: worker,
        employer: employer,
        wage: wage,
        mining_income: mining_income - mining_to_trust,
        mining_to_trust: mining_to_trust,
        accrued_pto: pto_accrued,
        accrued_sick: sick_accrued,
        trust_fund_balance: trust_contribution + mining_to_trust,
        last_payroll_time: env::block_time(),
        ans_name: ans_registry.get(worker).unwrap_or(""),
    };

    return true;
}

/// @dev Distributes mining rewards to workers
function distribute_mining_rewards(worker: address, amount: u64) -> bool {
    ensure!(amount > 0, "Mining reward must be greater than zero.");

    mining_rewards.insert(worker, mining_rewards.get(worker).unwrap_or(0) + amount);
    return true;
}

/// @dev Worker requests payroll withdrawal, including mining earnings
function withdraw_payroll(worker: address, amount: u64, include_pto: bool, include_sick: bool, include_mining: bool) -> bool {
    ensure!(verify_usdc_pool(worker), "Employer's USDC pool is insufficient for withdrawals");

    let mut total_balance = payroll_records[worker];

    if include_pto {
        total_balance += pto_balances[worker];
    }
    if include_sick {
        total_balance += sick_balances[worker];
    }
    if include_mining {
        total_balance += mining_rewards.get(worker).unwrap_or(0);
        mining_rewards[worker] = 0;  // Reset mining balance after withdrawal
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

/// @dev Worker requests payroll withdrawal using ANS
function withdraw_payroll_by_ans(ans_name: string, amount: u64, include_pto: bool, include_sick: bool, include_mining: bool) -> bool {
    let worker = lookup_worker_by_ans(ans_name);
    withdraw_payroll(worker, amount, include_pto, include_sick, include_mining);
}

/// @dev Utility function: Lookup a worker's ANS name by address
function lookup_worker_by_address(worker: address) -> string {
    ensure!(ans_registry.contains(worker), "Worker does not have an ANS name");
    return ans_registry[worker];
}

/// @dev Utility function: Lookup a worker's address by ANS name
function lookup_worker_by_ans(ans_name: string) -> address {
    ensure!(ans_reverse_lookup.contains(ans_name), "ANS name not found");
    return ans_reverse_lookup[ans_name];
}

/// @dev Verifies that employer PTO & Sick Pay reserves are funded
function verify_employer_funding(employer: address) -> bool {
    return employer_pto_funds.get(employer).unwrap_or(0) > 0 && employer_sick_funds.get(employer).unwrap_or(0) > 0;
}

/// @dev Verifies that employer has sufficient USDC liquidity pool
function verify_usdc_pool(employer: address) -> bool {
    return minimum_usdc_pool.get(employer).unwrap_or(0) > 0;
}
