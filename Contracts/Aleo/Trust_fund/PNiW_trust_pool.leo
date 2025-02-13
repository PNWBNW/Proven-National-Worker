program pniw_trust_pool.leo;

// 🏷️ Mappings
mapping worker_balances:
    key address as field;
    value u64 as field;

mapping last_withdrawal:
    key address as field;
    value u64 as field; // Stores timestamp of last withdrawal

mapping worker_children:
    key address as field;
    value address as field; // Child beneficiary

mapping worker_zpass_verified:
    key address as field;
    value bool as field; // ZPass verification status

// 🔹 New ANS Mappings
mapping ans_registry:
    key address as field;
    value string as field;  // Maps worker addresses to ANS names

mapping ans_reverse_lookup:
    key string as field;
    value address as field;  // Maps ANS names to worker addresses

// ✅ Function: Deposit funds into a worker's trust fund
function deposit_trust_fund(public worker: address, public amount: u64) -> bool {
    ensure(worker_zpass_verified.get_or_use(worker, false), "Worker must be ZPass verified to deposit funds");

    let current_balance = worker_balances.get_or_use(worker, 0u64);
    worker_balances.insert(worker, current_balance + amount);
    
    return true;
}

// ✅ Function: Deposit trust fund using ANS
function deposit_trust_fund_by_ans(public worker_ans: string, public amount: u64) -> bool {
    let worker = lookup_worker_by_ans(worker_ans);
    deposit_trust_fund(worker, amount);
    
    return true;
}

// ✅ Function: Register a child as the worker’s trust fund beneficiary
function register_beneficiary(public worker: address, public child: address) -> bool {
    ensure(worker_zpass_verified.get_or_use(worker, false), "Worker must be ZPass verified to register a beneficiary");

    worker_children.insert(worker, child);
    
    return true;
}

// ✅ Function: Register a child as a beneficiary using ANS
function register_beneficiary_by_ans(public worker_ans: string, public child: address) -> bool {
    let worker = lookup_worker_by_ans(worker_ans);
    register_beneficiary(worker, child);
    
    return true;
}

// ✅ Function: Withdraw funds from a worker's trust fund (only once per month)
function withdraw_funds(public worker: address, public amount: u64, public current_time: u64) -> bool {
    ensure(worker_zpass_verified.get_or_use(worker, false), "Worker must be ZPass verified to withdraw funds");

    let last_time = last_withdrawal.get_or_use(worker, 0u64);
    ensure(current_time >= last_time + 2592000u64, "Withdrawals allowed only once per month");

    let current_balance = worker_balances.get_or_use(worker, 0u64);
    ensure(current_balance >= amount, "Insufficient balance");

    worker_balances.insert(worker, current_balance - amount);
    last_withdrawal.insert(worker, current_time);

    return true;
}

// ✅ Function: Withdraw trust funds using ANS
function withdraw_funds_by_ans(public worker_ans: string, public amount: u64, public current_time: u64) -> bool {
    let worker = lookup_worker_by_ans(worker_ans);
    withdraw_funds(worker, amount, current_time);
    
    return true;
}

// ✅ Function: Claim funds as a child beneficiary (only if 18+)
function claim_funds_as_child(public child: address, public worker: address, public age: u64) -> bool {
    ensure(worker_children.get_or_use(worker, 0address) == child, "Not the registered beneficiary");
    ensure(age >= 18u64, "Child must be at least 18 years old to claim funds");

    let balance = worker_balances.get_or_use(worker, 0u64);
    worker_balances.insert(worker, 0u64);

    return true;
}

// ✅ Function: Claim funds as a child using ANS
function claim_funds_as_child_by_ans(public child: address, public worker_ans: string, public age: u64) -> bool {
    let worker = lookup_worker_by_ans(worker_ans);
    claim_funds_as_child(child, worker, age);
    
    return true;
}

// ✅ Function: Get the worker's trust fund balance
function get_worker_balance(public worker: address) -> u64 {
    return worker_balances.get_or_use(worker, 0u64);
}

// ✅ Function: Get the worker's trust fund balance using ANS
function get_worker_balance_by_ans(public worker_ans: string) -> u64 {
    let worker = lookup_worker_by_ans(worker_ans);
    return get_worker_balance(worker);
}

// ✅ Function: Get the worker’s registered child beneficiary
function get_worker_beneficiary(public worker: address) -> address {
    return worker_children.get_or_use(worker, 0address);
}

// ✅ Function: Get the worker’s registered child beneficiary using ANS
function get_worker_beneficiary_by_ans(public worker_ans: string) -> address {
    let worker = lookup_worker_by_ans(worker_ans);
    return get_worker_beneficiary(worker);
}

// ✅ Function: Get the last withdrawal timestamp
function get_last_withdrawal(public worker: address) -> u64 {
    return last_withdrawal.get_or_use(worker, 0u64);
}

// ✅ Function: Get the last withdrawal timestamp using ANS
function get_last_withdrawal_by_ans(public worker_ans: string) -> u64 {
    let worker = lookup_worker_by_ans(worker_ans);
    return get_last_withdrawal(worker);
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
