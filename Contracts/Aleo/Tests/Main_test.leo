program main_test.leo;

// ✅ Test: Assign category to worker (direct address)
function test_set_worker_category(worker: address) -> bool {
    set_worker_category(worker, "Healthcare");
    let category = worker_category[worker];

    ensure!(category == "Healthcare", "Worker category assignment failed");
    return true;
}

// ✅ Test: Assign category to worker using ANS
function test_set_worker_category_by_ans(worker_ans: string) -> bool {
    set_worker_category_by_ans(worker_ans, "Skilled");
    let worker = lookup_worker_by_ans(worker_ans);
    let category = worker_category[worker];

    ensure!(category == "Skilled", "Worker category assignment via ANS failed");
    return true;
}

// ✅ Test: Accrue PTO/Sick Pay for a worker
function test_accrue_pto_sick_pay(worker: address, employer: address) -> bool {
    worker_zpass_verified[worker] = true;
    worker_category[worker] = "General";

    let prev_pto = pto_balances.get_or_use(worker, 0);
    let prev_sick = sick_balances.get_or_use(worker, 0);
    
    accrue_pto_sick_pay(worker, employer, 40); // Simulate 40 hours worked
    
    let new_pto = pto_balances[worker];
    let new_sick = sick_balances[worker];

    ensure!(new_pto > prev_pto, "PTO accrual failed");
    ensure!(new_sick > prev_sick, "Sick Pay accrual failed");
    return true;
}

// ✅ Test: Request PTO payout
function test_request_pto(worker: address) -> bool {
    pto_balances[worker] = 20;
    
    let prev_balance = pto_balances[worker];
    let success = request_pto(worker, 10);

    let new_balance = pto_balances[worker];
    ensure!(success == true, "PTO request failed");
    ensure!(new_balance == prev_balance - 10, "PTO balance not deducted correctly");
    return true;
}

// ✅ Test: Request PTO using ANS
function test_request_pto_by_ans(worker_ans: string) -> bool {
    let worker = lookup_worker_by_ans(worker_ans);
    pto_balances[worker] = 20;

    let prev_balance = pto_balances[worker];
    let success = request_pto_by_ans(worker_ans, 10);

    let new_balance = pto_balances[worker];
    ensure!(success == true, "ANS PTO request failed");
    ensure!(new_balance == prev_balance - 10, "PTO balance not deducted correctly via ANS");
    return true;
}

// ✅ Test: Request Sick Pay (Verified)
function test_request_sick_pay_verified(worker: address) -> bool {
    worker_zpass_verified[worker] = true;
    sick_balances[worker] = 30;

    let prev_balance = sick_balances[worker];
    let success = request_sick_pay(worker, 10, true);

    let new_balance = sick_balances[worker];
    ensure!(success == true, "Sick Pay request failed");
    ensure!(new_balance == prev_balance - 10, "Sick Pay balance not deducted correctly");
    return true;
}

// ✅ Test: Request Sick Pay (Unverified, should be capped)
function test_request_sick_pay_unverified(worker: address) -> bool {
    worker_zpass_verified[worker] = false;
    sick_balances[worker] = 50;
    sick_leave_used[worker] = 35; // 35 hours already used

    let success = request_sick_pay(worker, 10, false);
    ensure!(success == false, "Unverified sick pay request exceeded 40-hour cap");
    return true;
}

// ✅ Test: Verify employer PTO/Sick Pay funding
function test_verify_employer_funding(employer: address) -> bool {
    employer_pto_funds[employer] = 100;
    employer_sick_funds[employer] = 100;
    
    let success = verify_employer_funding(employer);
    ensure!(success == true, "Employer funding verification failed");
    return true;
}

// ✅ Test: Assign worker to SubDAO using ANS
function test_assign_worker_to_subDAO_by_ans(worker_ans: string, subDAO_ans: string) -> bool {
    assign_worker_to_subDAO_by_ans(worker_ans, subDAO_ans);

    let worker = lookup_worker_by_ans(worker_ans);
    let subDAO = lookup_subDAO_by_ans(subDAO_ans);

    ensure!(subDAO_members[worker] == subDAO, "ANS-based worker to SubDAO assignment failed");
    return true;
}

// ✅ Test: Lookup worker by ANS
function test_lookup_worker_by_ans(worker_ans: string) -> bool {
    let worker = lookup_worker_by_ans(worker_ans);
    ensure!(worker != null, "Worker ANS lookup failed");
    return true;
}

// ✅ Test: Lookup SubDAO by ANS
function test_lookup_subDAO_by_ans(subDAO_ans: string) -> bool {
    let subDAO = lookup_subDAO_by_ans(subDAO_ans);
    ensure!(subDAO != null, "SubDAO ANS lookup failed");
    return true;
}
