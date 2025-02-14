program main.leo;

// 🏷️ Mappings
mapping worker_category: mapping(address, string); // Worker category classification
mapping pto_balances: mapping(address, u64);      // PTO balance per worker
mapping sick_balances: mapping(address, u64);     // Sick leave balance per worker
mapping employer_pto_funds: mapping(address, u64); // Employer-held PTO funds
mapping employer_sick_funds: mapping(address, u64); // Employer-held Sick funds

mapping last_accrual_time: mapping(address, u64); // Last time PTO/Sick Pay was accrued
mapping sick_leave_used: mapping(address, u64); // Tracks sick leave used in the current year
mapping farm_investments: mapping(address, u64); // Tracks PTO/Sick Pay used for farm investment
mapping worker_zpass_verified: mapping(address, bool); // Worker ZPass verification status

// 🔹 ANS Mappings
mapping ans_registry: mapping(address, string);  // Maps worker addresses to ANS names
mapping ans_reverse_lookup: mapping(string, address);  // Maps ANS names to worker addresses
mapping subDAO_ans_registry: mapping(address, string); // Maps SubDAO addresses to ANS names
mapping subDAO_reverse_lookup: mapping(string, address); // Maps ANS names to SubDAOs

// 📦 Structs
struct WorkerPTO {
    worker_address: address,
    category: string,
    accrued_pto: u64,
    accrued_sick: u64,
    last_updated: u64, // Timestamp of last accrual update
}

// ✅ Function: Assign category to worker (set by employer)
function set_worker_category(worker: address, category: string) {
    ensure!(category == "General" || category == "Skilled" || category == "Agricultural" || category == "Healthcare",
            "Invalid category");

    worker_category[worker] = category;
}

// ✅ Function: Assign category to worker using ANS
function set_worker_category_by_ans(worker_ans: string, category: string) {
    let worker = lookup_worker_by_ans(worker_ans);
    set_worker_category(worker, category);
}

// ✅ Function: Accrue PTO and Sick Pay for a worker during payroll processing
function accrue_pto_sick_pay(worker: address, employer: address, hours_worked: u64) {
    ensure(worker_zpass_verified.get_or_use(worker, false), "Worker must be ZPass verified for PTO/Sick Pay accrual");

    let category = worker_category[worker];

    // Adjust accrual rates based on worker category
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

// ✅ Function: Assign workers to SubDAOs using ANS
function assign_worker_to_subDAO_by_ans(worker_ans: string, subDAO_ans: string) {
    let worker = lookup_worker_by_ans(worker_ans);
    let subDAO = lookup_subDAO_by_ans(subDAO_ans);
    subDAO_members[worker] = subDAO;
}

// ✅ Function: Worker requests PTO payout
function request_pto(worker: address, amount: u64) -> bool {
    ensure!(worker_zpass_verified.get_or_use(worker, false), "Worker must be ZPass verified to request PTO");
    ensure!(pto_balances[worker] >= amount, "Insufficient PTO balance");

    pto_balances[worker] -= amount;
    
    // Send payout to worker
    transfer_private worker amount;
    return true;
}

// ✅ Function: Worker requests PTO payout using ANS
function request_pto_by_ans(worker_ans: string, amount: u64) -> bool {
    let worker = lookup_worker_by_ans(worker_ans);
    request_pto(worker, amount);
    
    return true;
}

// ✅ Function: Worker requests Sick Pay payout
function request_sick_pay(worker: address, amount: u64, verified: bool) -> bool {
    ensure!(worker_zpass_verified.get_or_use(worker, false), "Worker must be ZPass verified to request Sick Pay");
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

// ✅ Function: Verify employer has properly funded PTO/Sick Pay pools
function verify_employer_funding(employer: address) -> bool {
    ensure!(employer_pto_funds[employer] >= 0, "Employer PTO fund deficit detected");
    ensure!(employer_sick_funds[employer] >= 0, "Employer Sick Pay fund deficit detected");
    return true;
}

// ✅ Function: Lookup a worker's address by ANS name
function lookup_worker_by_ans(ans_name: string) -> address {
    ensure!(ans_reverse_lookup.contains(ans_name), "Worker ANS name not found");
    return ans_reverse_lookup[ans_name];
}

// ✅ Function: Lookup a SubDAO's address by ANS name
function lookup_subDAO_by_ans(ans_name: string) -> address {
    ensure!(subDAO_reverse_lookup.contains(ans_name), "ANS name not found");
    return subDAO_reverse_lookup[ans_name];
}
