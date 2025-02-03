program payroll.aleo;

mapping worker_data:
    address as worker -> (u64, u8);  // (wages, industry_flag)

mapping farm_investments:
    address as farm -> u64;  // Tracks total investment per farm

mapping worker_farms:
    address as worker -> address as farm;  // Maps workers to farms

mapping pending_payments:
    address as worker -> u64;  // Pending payments per worker

// Processes wages for a worker, applying the payroll amount to their account.
function process_payroll(worker: address, amount: u64) -> bool {
    if !worker_data.contains(worker) {
        return false;  // Worker not registered
    }

    let (current_wages, industry_flag) = worker_data.get(worker);

    // Update worker's wages
    worker_data.update(worker, (current_wages + amount, industry_flag));

    // Add any pending payment amounts
    if pending_payments.contains(worker) {
        let pending = pending_payments.get(worker);
        worker_data.update(worker, (worker_data.get(worker).0 + pending, industry_flag));
        pending_payments.remove(worker);
    }

    return true;
}

// Allows agricultural workers to invest in a farm
function invest_in_farm(worker: address, amount: u64) -> bool {
    if !worker_data.contains(worker) {
        return false;  // Worker not registered
    }

    let (_, industry_flag) = worker_data.get(worker);

    // Check if worker has AG industry flag (must be agricultural worker)
    if industry_flag & 0b01 == 0 {
        return false;  // Must have AG role (bitmask check)
    }

    // Ensure the worker is assigned to a farm
    let farm = worker_farms.get(worker);
    if farm == address(0) {
        return false;  // Worker must be assigned to a farm
    }

    // Update farm investment
    farm_investments.update(farm, farm_investments.get(farm) + amount);
    return true;
}

// Worker can add funds to their pending payments
function add_pending_payment(worker: address, amount: u64) -> bool {
    if !worker_data.contains(worker) {
        return false;  // Worker not registered
    }

    // Add amount to pending payments
    if pending_payments.contains(worker) {
        let current_pending = pending_payments.get(worker);
        pending_payments.update(worker, current_pending + amount);
    } else {
        pending_payments.insert(worker, amount);
    }

    return true;
}

// Worker can withdraw from their pending payments (if any).
function withdraw_pending_payment(worker: address, amount: u64) -> bool {
    if !worker_data.contains(worker) {
        return false;  // Worker not registered
    }

    // Ensure worker has sufficient pending funds
    if !pending_payments.contains(worker) || pending_payments.get(worker) < amount {
        return false;  // Insufficient pending funds
    }

    // Reduce pending payment
    let current_pending = pending_payments.get(worker);
    pending_payments.update(worker, current_pending - amount);
    return true;
}

// Assign a worker to a farm. Only permitted for agricultural workers.
function assign_worker_to_farm(worker: address, farm: address) -> bool {
    if !worker_data.contains(worker) {
        return false;  // Worker not registered
    }

    // Get industry flag to confirm if it's an agricultural worker
    let (_, industry_flag) = worker_data.get(worker);
    if industry_flag & 0b01 == 0 {
        return false;  // Worker must have AG role
    }

    // Assign worker to the farm
    worker_farms.insert(worker, farm);
    return true;
}
