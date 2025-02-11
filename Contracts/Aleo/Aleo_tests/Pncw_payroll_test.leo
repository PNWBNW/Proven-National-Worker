// 📌 PNcW Payroll Test Suite

import pncw_payroll.leo;

test "Process Payroll for ZPass Verified Worker" {
    let worker = address("aleo1workerxyz456");
    let employer = address("aleo1employerabc123");
    let wage = 3000;
    let hours_worked = 40;
    let trust_contribution = 200;

    // Ensure worker is ZPass verified
    assert!(pncw_payroll::worker_zpass_verified[worker] == true);

    // Process payroll
    assert!(pncw_payroll::process_payroll(worker, employer, wage, hours_worked, trust_contribution) == true);

    // Verify payroll balances
    assert!(pncw_payroll::payroll_records[worker] == wage);
    assert!(pncw_payroll::pto_balances[worker] > 0);
    assert!(pncw_payroll::sick_balances[worker] > 0);
    assert!(pncw_payroll::trust_funds[worker] == trust_contribution);
}

test "Withdraw Payroll Funds (ZPass & ANS Required)" {
    let worker = address("aleo1workerxyz456");
    let ans_name = "johndoe.pncw";
    let withdrawal_amount = 1000;

    // Ensure worker is ZPass verified
    assert!(pncw_payroll::worker_zpass_verified[worker] == true);

    // Assign ANS name to worker
    pncw_payroll::ans_registry[worker] = ans_name;
    pncw_payroll::ans_reverse_lookup[ans_name] = worker;

    // Withdraw payroll
    assert!(pncw_payroll::withdraw_payroll(worker, withdrawal_amount, false, false) == true);

    // Verify deduction
    assert!(pncw_payroll::payroll_records[worker] == 2000);
}

test "Withdraw PTO Balance (ZPass & ANS Required)" {
    let worker = address("aleo1workerxyz456");
    let ans_name = "johndoe.pncw";
    let withdrawal_amount = 4;

    // Ensure worker is ZPass verified
    assert!(pncw_payroll::worker_zpass_verified[worker] == true);

    // Assign ANS name to worker
    pncw_payroll::ans_registry[worker] = ans_name;
    pncw_payroll::ans_reverse_lookup[ans_name] = worker;

    // Withdraw PTO
    assert!(pncw_payroll::withdraw_payroll(worker, withdrawal_amount, true, false) == true);

    // Verify PTO deduction
    assert!(pncw_payroll::pto_balances[worker] < 4);
}

test "Withdraw Sick Leave Balance (ZPass & ANS Required)" {
    let worker = address("aleo1workerxyz456");
    let withdrawal_amount = 2;

    // Ensure worker is ZPass verified
    assert!(pncw_payroll::worker_zpass_verified[worker] == true);

    // Withdraw sick pay
    assert!(pncw_payroll::withdraw_payroll(worker, withdrawal_amount, false, true) == true);

    // Verify sick balance deduction
    assert!(pncw_payroll::sick_balances[worker] < 2);
}

test "Employer Funds Payroll Reserves (ZPass Required)" {
    let employer = address("aleo1employerabc123");
    let deposit_amount = 5000;

    // Ensure employer is ZPass verified
    assert!(pncw_payroll::employer_zpass_verified[employer] == true);

    // Deposit payroll reserves
    assert!(pncw_payroll::employer_deposit_usdc(employer, deposit_amount) == true);

    // Verify balance update
    assert!(pncw_payroll::get_usdc_balance(employer) == deposit_amount);
}

test "Ensure Employer Has Required Payroll Liquidity (ZPass Required)" {
    let employer = address("aleo1employerabc123");

    // Ensure employer is ZPass verified
    assert!(pncw_payroll::employer_zpass_verified[employer] == true);

    // Verify employer liquidity
    assert!(pncw_payroll::verify_usdc_pool(employer) == true);

    // Simulate underfunding
    pncw_payroll::set_usdc_balance(employer, 100);
    assert!(pncw_payroll::verify_usdc_pool(employer) == false);
}

test "Employer Penalized for Insufficient Payroll Liquidity (ZPass Required)" {
    let employer = address("aleo1employerabc123");

    // Simulate employer non-compliance
    pncw_payroll::set_usdc_balance(employer, 100);
    
    // Ensure employer is ZPass verified
    assert!(pncw_payroll::employer_zpass_verified[employer] == true);

    // Enforce penalty
    assert!(pncw_payroll::enforce_usdc_penalty(employer) == true);
}

test "Worker Invests PTO in Farm (ZPass & ANS Required)" {
    let worker = address("aleo1workerxyz456");
    let farm = address("aleo1farm789");
    let investment_amount = 10;
    let ans_name = "johndoe.pncw";

    // Ensure worker is ZPass verified
    assert!(pncw_payroll::worker_zpass_verified[worker] == true);

    // Assign ANS name to worker
    pncw_payroll::ans_registry[worker] = ans_name;
    pncw_payroll::ans_reverse_lookup[ans_name] = worker;

    // Worker invests PTO
    assert!(pncw_payroll::invest_pto_sick_pay(worker, investment_amount, "PTO") == true);

    // Verify PTO deduction
    assert!(pncw_payroll::pto_balances[worker] < 10);
    assert!(pncw_payroll::farm_investments[worker] == investment_amount);
}

test "Worker Invests Sick Pay in Farm (ZPass & ANS Required)" {
    let worker = address("aleo1workerxyz456");
    let farm = address("aleo1farm789");
    let investment_amount = 5;

    // Ensure worker is ZPass verified
    assert!(pncw_payroll::worker_zpass_verified[worker] == true);

    // Worker invests sick pay
    assert!(pncw_payroll::invest_pto_sick_pay(worker, investment_amount, "Sick") == true);

    // Verify Sick Pay deduction
    assert!(pncw_payroll::sick_balances[worker] < 5);
    assert!(pncw_payroll::farm_investments[worker] == 5);
}

test "SubDAO Reviews Employer Compliance (ZPass Required)" {
    let employer = address("aleo1employerabc123");

    // Ensure employer is ZPass verified
    assert!(pncw_payroll::employer_zpass_verified[employer] == true);

    // Enforce compliance check
    assert!(pncw_payroll::subdao_check_compliance(employer) == true);

    // Simulate employer non-compliance
    pncw_payroll::set_usdc_balance(employer, 50);
    assert!(pncw_payroll::subdao_check_compliance(employer) == false);
}
