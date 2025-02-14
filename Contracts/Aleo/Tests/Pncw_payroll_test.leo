program pncw_payroll_test.leo;

// ✅ Test: Process payroll with PTO, Sick Pay, and Trust Fund contributions
function test_process_payroll(worker: address, employer: address) -> bool {
    employer_pto_funds[employer] = 1000;
    employer_sick_funds[employer] = 1000;
    minimum_usdc_pool[employer] = 500;
    
    let success = process_payroll(worker, employer, 100, 40, 20, 10);
    
    ensure!(success == true, "Payroll processing failed");
    ensure!(payroll_records[worker] == 100, "Payroll wage balance incorrect");
    ensure!(pto_balances[worker] > 0, "PTO accrual failed");
    ensure!(sick_balances[worker] > 0, "Sick Pay accrual failed");
    ensure!(trust_funds[worker] == 30, "Trust fund allocation incorrect");
    return true;
}

// ✅ Test: Distribute mining rewards to a worker
function test_distribute_mining_rewards(worker: address) -> bool {
    let success = distribute_mining_rewards(worker, 50);

    ensure!(success == true, "Mining reward distribution failed");
    ensure!(mining_rewards[worker] == 50, "Mining reward balance incorrect");
    return true;
}

// ✅ Test: Process payroll with mining rewards allocated to trust fund
function test_process_payroll_with_mining(worker: address, employer: address) -> bool {
    employer_pto_funds[employer] = 1000;
    employer_sick_funds[employer] = 1000;
    minimum_usdc_pool[employer] = 500;
    mining_rewards[worker] = 60;

    let success = process_payroll(worker, employer, 200, 40, 30, 40);

    ensure!(success == true, "Payroll processing with mining failed");
    ensure!(payroll_records[worker] == 200, "Payroll wage balance incorrect");
    ensure!(trust_funds[worker] == 70, "Trust fund allocation with mining incorrect");
    return true;
}

// ✅ Test: Worker payroll withdrawal (excluding mining)
function test_withdraw_payroll(worker: address) -> bool {
    payroll_records[worker] = 200;
    let success = withdraw_payroll(worker, 100, false, false, false);

    ensure!(success == true, "Payroll withdrawal failed");
    ensure!(payroll_records[worker] == 100, "Payroll balance incorrect after withdrawal");
    return true;
}

// ✅ Test: Worker payroll withdrawal including PTO and Sick Pay
function test_withdraw_payroll_with_pto_sick(worker: address) -> bool {
    payroll_records[worker] = 100;
    pto_balances[worker] = 50;
    sick_balances[worker] = 50;

    let success = withdraw_payroll(worker, 150, true, true, false);

    ensure!(success == true, "Payroll withdrawal with PTO/Sick failed");
    ensure!(payroll_records[worker] == 100, "Payroll balance unchanged when PTO/Sick used");
    ensure!(pto_balances[worker] == 0, "PTO balance incorrect after withdrawal");
    ensure!(sick_balances[worker] == 0, "Sick balance incorrect after withdrawal");
    return true;
}

// ✅ Test: Worker payroll withdrawal including mining rewards
function test_withdraw_payroll_with_mining(worker: address) -> bool {
    payroll_records[worker] = 100;
    mining_rewards[worker] = 50;

    let success = withdraw_payroll(worker, 150, false, false, true);

    ensure!(success == true, "Payroll withdrawal with mining failed");
    ensure!(payroll_records[worker] == 100, "Payroll balance unchanged when mining used");
    ensure!(mining_rewards[worker] == 0, "Mining balance incorrect after withdrawal");
    return true;
}

// ✅ Test: Withdraw payroll using ANS lookup
function test_withdraw_payroll_by_ans(worker: address, ans_name: string) -> bool {
    ans_registry[worker] = ans_name;
    ans_reverse_lookup[ans_name] = worker;
    payroll_records[worker] = 200;

    let success = withdraw_payroll_by_ans(ans_name, 100, false, false, false);

    ensure!(success == true, "ANS payroll withdrawal failed");
    ensure!(payroll_records[worker] == 100, "Payroll balance incorrect after ANS withdrawal");
    return true;
}

// ✅ Test: Verify employer funding before payroll processing
function test_verify_employer_funding(employer: address) -> bool {
    employer_pto_funds[employer] = 1000;
    employer_sick_funds[employer] = 1000;
    
    let success = verify_employer_funding(employer);

    ensure!(success == true, "Employer funding verification failed");
    return true;
}

// ✅ Test: Verify employer minimum USDC pool before payroll execution
function test_verify_usdc_pool(employer: address) -> bool {
    minimum_usdc_pool[employer] = 1000;
    
    let success = verify_usdc_pool(employer);

    ensure!(success == true, "Employer USDC liquidity verification failed");
    return true;
}

// ✅ Test: Lookup worker ANS by address
function test_lookup_worker_by_address(worker: address, ans_name: string) -> bool {
    ans_registry[worker] = ans_name;

    let retrieved_ans = lookup_worker_by_address(worker);

    ensure!(retrieved_ans == ans_name, "Worker ANS lookup by address failed");
    return true;
}

// ✅ Test: Lookup worker address by ANS
function test_lookup_worker_by_ans(ans_name: string, worker: address) -> bool {
    ans_reverse_lookup[ans_name] = worker;

    let retrieved_worker = lookup_worker_by_ans(ans_name);

    ensure!(retrieved_worker == worker, "Worker ANS lookup by name failed");
    return true;
}
