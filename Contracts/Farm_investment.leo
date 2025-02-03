program farm_investment.aleo;

mapping owner_shares:
    key: address;  // Worker address
    value: u64;    // Ownership percentage (e.g., 500 = 5.00%)

mapping farm_balances:
    key: address;  // Farm address
    value: u64;    // Total funds allocated to the farm

mapping pending_profits:
    key: address;  // Worker address
    value: u64;    // Earned but not yet withdrawn profits

// Function: Workers allocate wages to invest in farm ownership
function invest_in_farm(worker: address, farm: address, amount: u64) -> u64 {
    assert(amount > 0, "Investment must be greater than zero");
    
    // Deduct from worker payroll (handled externally via payroll.leo)
    // Add to farm investment pool
    let farm_total = farm_balances.get_or_use(farm, 0);
    let new_farm_total = farm_total + amount;
    farm_balances.insert(farm, new_farm_total);
    
    // Assign ownership proportionally
    let worker_share = owner_shares.get_or_use(worker, 0);
    let new_share = worker_share + amount;
    owner_shares.insert(worker, new_share);

    return new_share;  // Return updated ownership percentage
}

// Function: Farms report sales revenue, triggering profit distribution
function report_sales(farm: address, revenue: u64) {
    assert(revenue > 0, "Revenue must be greater than zero");
    
    let farm_total = farm_balances.get_or_use(farm, 0);
    assert(farm_total > 0, "No investment funds exist for this farm");

    for (worker in owner_shares.keys()) {
        let worker_share = owner_shares.get(worker);
        let share_ratio = worker_share / farm_total;
        let worker_profit = revenue * share_ratio;
        
        let pending = pending_profits.get_or_use(worker, 0);
        pending_profits.insert(worker, pending + worker_profit);
    }
}

// Function: Workers withdraw profits from farm earnings
function withdraw_profits(worker: address) -> u64 {
    let profits = pending_profits.get_or_use(worker, 0);
    assert(profits > 0, "No profits available for withdrawal");

    pending_profits.remove(worker);
    return profits;  // Worker receives their earnings
}
