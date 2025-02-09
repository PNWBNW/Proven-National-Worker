program pncw_trust_pool.leo;

mapping worker_balances:
    key address as field;
    value u64 as field;

mapping last_withdrawal:
    key address as field;
    value u64 as field; // Stores timestamp of last withdrawal

mapping worker_children:
    key address as field;
    value address as field; // Child beneficiary

function deposit_trust_fund(public worker: address, public amount: u64) -> bool {
    let current_balance = worker_balances.get_or_use(worker, 0u64);
    worker_balances.insert(worker, current_balance + amount);
    return true;
}

function register_beneficiary(public worker: address, public child: address) -> bool {
    worker_children.insert(worker, child);
    return true;
}

function withdraw_funds(public worker: address, public amount: u64, public current_time: u64) -> bool {
    let last_time = last_withdrawal.get_or_use(worker, 0u64);
    ensure(current_time >= last_time + 2592000u64, "Withdrawals allowed only once per month");

    let current_balance = worker_balances.get_or_use(worker, 0u64);
    ensure(current_balance >= amount, "Insufficient balance");

    worker_balances.insert(worker, current_balance - amount);
    last_withdrawal.insert(worker, current_time);

    return true;
}

function claim_funds_as_child(public child: address, public worker: address, public age: u64) -> bool {
    ensure(worker_children.get_or_use(worker, 0address) == child, "Not the registered beneficiary");
    ensure(age >= 18u64, "Child must be at least 18 years old to claim funds");

    let balance = worker_balances.get_or_use(worker, 0u64);
    worker_balances.insert(worker, 0u64);

    return true;
}

function get_worker_balance(public worker: address) -> u64 {
    return worker_balances.get_or_use(worker, 0u64);
}

function get_worker_beneficiary(public worker: address) -> address {
    return worker_children.get_or_use(worker, 0address);
}

function get_last_withdrawal(public worker: address) -> u64 {
    return last_withdrawal.get_or_use(worker, 0u64);
}
