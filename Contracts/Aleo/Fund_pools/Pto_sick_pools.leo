program pto_sick_pools.aleo;

// 🏷️ PTO & Sick Leave Mappings (Per SubDAO)
mapping pto_sick_pool_balances: public hashmap<string, u64>;  // SubDAO PTO/Sick leave funds (ANS-based)
mapping worker_pto_balances: public hashmap<address, u64>;  // Worker PTO balances
mapping worker_sick_balances: public hashmap<address, u64>;  // Worker Sick Leave balances
mapping employer_pto_sick_funds: public hashmap<address, u64>;  // Employer pre-funded PTO/Sick reserves

// 🔹 ANS & ZPass Mappings
mapping ans_registry: public hashmap<address, string>;  // Maps worker addresses to ANS names
mapping ans_reverse_lookup: public hashmap<string, address>;  // Maps ANS names to worker addresses
mapping worker_zpass_verified: public hashmap<address, bool>;  // Worker ZPass verification status

/// @dev Deposits employer funds into a SubDAO PTO/Sick Leave pool
function deposit_pto_sick_fund(public employer: address, public subdao_ans: string, public amount: u64) -> bool {
    let current_employer_balance = employer_pto_sick_funds.get_or_use(employer, 0u64);
    employer_pto_sick_funds.insert(employer, current_employer_balance + amount);

    let current_pool_balance = pto_sick_pool_balances.get_or_use(subdao_ans, 0u64);
    pto_sick_pool_balances.insert(subdao_ans, current_pool_balance + amount);

    return true;
}

/// @dev Deposits into a SubDAO PTO/Sick Leave pool using ANS
function deposit_pto_sick_fund_by_ans(public employer: address, public subdao_ans: string, public amount: u64) -> bool {
    deposit_pto_sick_fund(employer, subdao_ans, amount);
    return true;
}

/// @dev Allocates PTO & Sick Leave based on hours worked
function accrue_pto_sick_leave(public worker: address, public subdao_ans: string, public hours_worked: u64) -> bool {
    let pto_rate = 1 / 20;  // 1 hour PTO per 20 hours worked
    let sick_rate = 1 / 40;  // 1 hour Sick Leave per 40 hours worked

    let pto_accrued = hours_worked * pto_rate;
    let sick_accrued = hours_worked * sick_rate;

    let current_pto_balance = worker_pto_balances.get_or_use(worker, 0u64);
    let current_sick_balance = worker_sick_balances.get_or_use(worker, 0u64);

    worker_pto_balances.insert(worker, current_pto_balance + pto_accrued);
    worker_sick_balances.insert(worker, current_sick_balance + sick_accrued);

    let current_pool_balance = pto_sick_pool_balances.get_or_use(subdao_ans, 0u64);
    pto_sick_pool_balances.insert(subdao_ans, current_pool_balance - (pto_accrued + sick_accrued));

    return true;
}

/// @dev Withdraws PTO or Sick Leave (Worker Chooses Type) - **ZPass & ANS Required**
function withdraw_pto_sick_leave(public worker: address, public subdao_ans: string, public amount: u64, public type: string) -> bool {
    ensure(worker_zpass_verified.get_or_use(worker, false), "ZPass verification required to withdraw funds");
    ensure(ans_registry.contains(worker), "ANS registration required to withdraw funds");
    ensure(type == "PTO" || type == "Sick", "Invalid leave type. Must be PTO or Sick");

    let mut balance = if type == "PTO" {
        worker_pto_balances.get_or_use(worker, 0u64)
    } else {
        worker_sick_balances.get_or_use(worker, 0u64)
    };

    ensure(balance >= amount, "Insufficient balance");

    if type == "PTO" {
        worker_pto_balances.insert(worker, balance - amount);
    } else {
        worker_sick_balances.insert(worker, balance - amount);
    }

    let current_pool_balance = pto_sick_pool_balances.get_or_use(subdao_ans, 0u64);
    pto_sick_pool_balances.insert(subdao_ans, current_pool_balance - amount);

    return true;
}

/// @dev Withdraws PTO or Sick Leave using ANS - **ZPass & ANS Required**
function withdraw_pto_sick_leave_by_ans(public worker_ans: string, public subdao_ans: string, public amount: u64, public type: string) -> bool {
    let worker = lookup_worker_by_ans(worker_ans);
    withdraw_pto_sick_leave(worker, subdao_ans, amount, type);
    return true;
}

/// @dev Allows a worker to invest PTO or Sick Leave into farm investments - **ZPass & ANS Required**
function invest_pto_sick_leave(public worker: address, public subdao_ans: string, public amount: u64, public type: string) -> bool {
    ensure(worker_zpass_verified.get_or_use(worker, false), "ZPass verification required to invest funds");
    ensure(ans_registry.contains(worker), "ANS registration required to invest funds");
    ensure(type == "PTO" || type == "Sick", "Invalid leave type. Must be PTO or Sick");

    let mut balance = if type == "PTO" {
        worker_pto_balances.get_or_use(worker, 0u64)
    } else {
        worker_sick_balances.get_or_use(worker, 0u64)
    };

    ensure(balance >= amount, "Insufficient balance");

    if type == "PTO" {
        worker_pto_balances.insert(worker, balance - amount);
    } else {
        worker_sick_balances.insert(worker, balance - amount);
    }

    let current_pool_balance = pto_sick_pool_balances.get_or_use(subdao_ans, 0u64);
    pto_sick_pool_balances.insert(subdao_ans, current_pool_balance - amount);

    return true;
}

/// @dev Allows a worker to invest PTO or Sick Leave using ANS - **ZPass & ANS Required**
function invest_pto_sick_leave_by_ans(public worker_ans: string, public subdao_ans: string, public amount: u64, public type: string) -> bool {
    let worker = lookup_worker_by_ans(worker_ans);
    invest_pto_sick_leave(worker, subdao_ans, amount, type);
    return true;
}

/// @dev Gets a worker's PTO balance
function get_worker_pto_balance(public worker: address) -> u64 {
    return worker_pto_balances.get_or_use(worker, 0u64);
}

/// @dev Gets a worker's PTO balance using ANS
function get_worker_pto_balance_by_ans(public worker_ans: string) -> u64 {
    let worker = lookup_worker_by_ans(worker_ans);
    return get_worker_pto_balance(worker);
}

/// @dev Gets a worker's Sick Leave balance
function get_worker_sick_balance(public worker: address) -> u64 {
    return worker_sick_balances.get_or_use(worker, 0u64);
}

/// @dev Gets a worker's Sick Leave balance using ANS
function get_worker_sick_balance_by_ans(public worker_ans: string) -> u64 {
    let worker = lookup_worker_by_ans(worker_ans);
    return get_worker_sick_balance(worker);
}

/// @dev Gets the total balance of a SubDAO's PTO/Sick Leave pool
function get_subdao_pto_sick_balance(public subdao_ans: string) -> u64 {
    return pto_sick_pool_balances.get_or_use(subdao_ans, 0u64);
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
