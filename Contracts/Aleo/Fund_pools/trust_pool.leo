program trust_pools.aleo;

// 🏷️ Trust Fund Pool Mappings (Per SubDAO)
mapping trust_pool_balances: public hashmap<string, u64>;  // SubDAO trust pools (ANS-based)
mapping worker_balances: public hashmap<address, u64>;  // Individual worker trust balances
mapping last_withdrawal: public hashmap<address, u64>;  // Last withdrawal timestamps
mapping worker_children: public hashmap<address, address>;  // Child beneficiaries
mapping worker_zpass_verified: public hashmap<address, bool>;  // Worker ZPass verification status

// 🔹 ANS Mappings
mapping ans_registry: public hashmap<address, string>;  // Maps worker addresses to ANS names
mapping ans_reverse_lookup: public hashmap<string, address>;  // Maps ANS names to worker addresses

/// @dev Deposits USDC into a worker’s trust fund within the correct SubDAO trust pool
function deposit_trust_fund(public worker: address, public subdao_ans: string, public amount: u64) -> bool {
    ensure(worker_zpass_verified.get_or_use(worker, false), "Worker must be ZPass verified to deposit funds");

    let current_worker_balance = worker_balances.get_or_use(worker, 0u64);
    worker_balances.insert(worker, current_worker_balance + amount);

    let current_pool_balance = trust_pool_balances.get_or_use(subdao_ans, 0u64);
    trust_pool_balances.insert(subdao_ans, current_pool_balance + amount);
    
    return true;
}

/// @dev Deposits into a worker’s trust fund using ANS
function deposit_trust_fund_by_ans(public worker_ans: string, public subdao_ans: string, public amount: u64) -> bool {
    let worker = lookup_worker_by_ans(worker_ans);
    deposit_trust_fund(worker, subdao_ans, amount);
    return true;
}

/// @dev Registers a child as the worker’s trust fund beneficiary
function register_beneficiary(public worker: address, public child: address) -> bool {
    ensure(worker_zpass_verified.get_or_use(worker, false), "Worker must be ZPass verified to register a beneficiary");
    worker_children.insert(worker, child);
    return true;
}

/// @dev Registers a child as a beneficiary using ANS
function register_beneficiary_by_ans(public worker_ans: string, public child: address) -> bool {
    let worker = lookup_worker_by_ans(worker_ans);
    register_beneficiary(worker, child);
    return true;
}

/// @dev Withdraws funds from a worker's trust fund (Only once per month)
function withdraw_funds(public worker: address, public subdao_ans: string, public amount: u64, public current_time: u64) -> bool {
    ensure(worker_zpass_verified.get_or_use(worker, false), "Worker must be ZPass verified to withdraw funds");

    let last_time = last_withdrawal.get_or_use(worker, 0u64);
    ensure(current_time >= last_time + 2592000u64, "Withdrawals allowed only once per month");

    let current_balance = worker_balances.get_or_use(worker, 0u64);
    ensure(current_balance >= amount, "Insufficient balance");

    worker_balances.insert(worker, current_balance - amount);
    last_withdrawal.insert(worker, current_time);

    let current_pool_balance = trust_pool_balances.get_or_use(subdao_ans, 0u64);
    trust_pool_balances.insert(subdao_ans, current_pool_balance - amount);

    return true;
}

/// @dev Withdraws trust funds using ANS
function withdraw_funds_by_ans(public worker_ans: string, public subdao_ans: string, public amount: u64, public current_time: u64) -> bool {
    let worker = lookup_worker_by_ans(worker_ans);
    withdraw_funds(worker, subdao_ans, amount, current_time);
    return true;
}

/// @dev Claims funds as a child beneficiary (Only if 18+)
function claim_funds_as_child(public child: address, public worker: address, public subdao_ans: string, public age: u64) -> bool {
    ensure(worker_children.get_or_use(worker, 0address) == child, "Not the registered beneficiary");
    ensure(age >= 18u64, "Child must be at least 18 years old to claim funds");

    let balance = worker_balances.get_or_use(worker, 0u64);
    ensure(balance > 0, "No funds available");

    worker_balances.insert(worker, 0u64);

    let current_pool_balance = trust_pool_balances.get_or_use(subdao_ans, 0u64);
    trust_pool_balances.insert(subdao_ans, current_pool_balance - balance);

    return true;
}

/// @dev Claims funds as a child using ANS
function claim_funds_as_child_by_ans(public child: address, public worker_ans: string, public subdao_ans: string, public age: u64) -> bool {
    let worker = lookup_worker_by_ans(worker_ans);
    claim_funds_as_child(child, worker, subdao_ans, age);
    return true;
}

/// @dev Gets the worker’s trust fund balance
function get_worker_balance(public worker: address) -> u64 {
    return worker_balances.get_or_use(worker, 0u64);
}

/// @dev Gets the worker’s trust fund balance using ANS
function get_worker_balance_by_ans(public worker_ans: string) -> u64 {
    let worker = lookup_worker_by_ans(worker_ans);
    return get_worker_balance(worker);
}

/// @dev Gets the trust pool balance for a SubDAO
function get_subdao_trustpool_balance(public subdao_ans: string) -> u64 {
    return trust_pool_balances.get_or_use(subdao_ans, 0u64);
}

/// @dev Gets the worker’s registered child beneficiary
function get_worker_beneficiary(public worker: address) -> address {
    return worker_children.get_or_use(worker, 0address);
}

/// @dev Gets the worker’s registered child beneficiary using ANS
function get_worker_beneficiary_by_ans(public worker_ans: string) -> address {
    let worker = lookup_worker_by_ans(worker_ans);
    return get_worker_beneficiary(worker);
}

/// @dev Gets the last withdrawal timestamp
function get_last_withdrawal(public worker: address) -> u64 {
    return last_withdrawal.get_or_use(worker, 0u64);
}

/// @dev Gets the last withdrawal timestamp using ANS
function get_last_withdrawal_by_ans(public worker_ans: string) -> u64 {
    let worker = lookup_worker_by_ans(worker_ans);
    return get_last_withdrawal(worker);
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
