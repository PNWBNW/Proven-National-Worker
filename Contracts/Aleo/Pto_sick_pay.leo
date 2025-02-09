program pto_sick_pay.leo;

mapping owner as address; // Worker who owns the PTO/Sick Leave
mapping employer as address; // Employer responsible for funding
mapping accrued_pto as u32; // Total accrued PTO hours
mapping accrued_sick as u32; // Total accrued Sick Leave hours
mapping last_cashout as u64; // Timestamp of last PTO cashout
mapping employer_contributions as u64; // Tracks employer wage contributions
mapping subdao_fund as u64; // SubDAO-managed pooled sick leave fund

function accrue_pto(worker: address, hours_worked: u32) -> u32 {
    let earned_pto = hours_worked / 40; // 1 PTO hour for every 40 hours worked
    accrued_pto[worker] += earned_pto;
    return accrued_pto[worker];
}

function accrue_sick_leave(worker: address, hours_worked: u32) -> u32 {
    let earned_sick = hours_worked / 40; // 1 Sick Leave hour for every 40 hours worked
    accrued_sick[worker] += earned_sick;
    return accrued_sick[worker];
}

function request_pto(worker: address, hours_requested: u32) -> bool {
    ensure accrued_pto[worker] >= hours_requested;
    accrued_pto[worker] -= hours_requested;
    return true;
}

function request_sick_leave(worker: address, hours_requested: u32) -> bool {
    ensure accrued_sick[worker] >= hours_requested;
    accrued_sick[worker] -= hours_requested;
    return true;
}

function cashout_pto(worker: address, request_time: u64) -> u64 {
    let last_cashout_time = last_cashout[worker];
    let time_elapsed = request_time - last_cashout_time;
    
    ensure time_elapsed >= 1296000; // 15 days in seconds (15 * 24 * 60 * 60)
    
    let max_cashout = accrued_pto[worker] / 4; // 25% of accrued PTO
    accrued_pto[worker] -= max_cashout;
    
    last_cashout[worker] = request_time;
    
    return max_cashout;
}

function employer_contribute(employer: address, amount: u64) -> bool {
    employer_contributions[employer] += amount;
    return true;
}

function suspend_employer(employer: address) -> bool {
    ensure employer_contributions[employer] == 0;
    // Logic to prevent hiring new workers until resolved
    return true;
}

function override_cashout_delay(subdao: address, worker: address) -> bool {
    ensure subdao_fund[subdao] > 0; // Ensure the SubDAO has available funds
    last_cashout[worker] = 0; // Reset cashout cooldown for emergency cases
    return true;
}
