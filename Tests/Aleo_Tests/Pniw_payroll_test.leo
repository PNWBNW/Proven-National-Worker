// 📌 PNiW Payroll Test Suite

import pniw_payroll.leo;

test "Process Payroll for ZPass Verified Worker" {
    let worker = address("aleo1workerxyz456");
    let employer = address("aleo1employerabc123");
    let wage = 3500;
    let hours_worked = 40;
    let trust_contribution = 250;

    // Ensure worker is ZPass verified
    assert!(pniw_payroll::worker_zpass_verified[worker] == true);

    // Process payroll
    assert!(pniw_payroll::process_pniw_payroll(worker, employer, wage, hours_worked, trust_contribution) == true);

    // Verify payroll balances
    assert!(pniw_payroll::payroll_records[worker] == wage);
    assert!(pniw_payroll::pto_balances[worker] > 0);
    assert!(pniw_payroll::sick_balances[worker] > 0);
    assert!(pniw_payroll::trust_funds[worker] == trust_contribution);
}

test "Withdraw Payroll Funds (ZPass & ANS Required)" {
    let worker = address("aleo1workerxyz456");
    let ans_name = "janedoe.pniw";
    let withdrawal_amount = 1200;

    // Ensure worker is ZPass verified
    assert!(pniw_payroll::worker_zpass_verified[worker] == true);

    // Assign ANS name to worker
    pniw_payroll::ans_registry[worker] = ans_name;
    pniw_payroll::ans_reverse_lookup[ans_name] = worker;

    // Withdraw payroll
    assert!(pniw_payroll::withdraw_pniw_payroll(worker, withdrawal_amount, false, false) == true);

    // Verify deduction
    assert!(pniw_payroll::payroll_records[worker] == 2300);
}

test "Withdraw PTO Balance (ZPass & ANS Required)" {
    let worker = address("aleo1workerxyz456");
    let ans_name = "janedoe.pniw";
    let withdrawal_amount = 6;

    // Ensure worker is ZPass verified
    assert!(pniw_payroll::worker_zpass_verified[worker] == true);

    // Assign ANS name to worker
    pniw_payroll::ans_registry[worker] = ans_name;
    pniw_payroll::ans_reverse_lookup[ans_name] = worker;

    // Withdraw PTO
    assert!(pniw_payroll::withdraw_pniw_payroll(worker, withdrawal_amount, true, false) == true);

    // Verify PTO deduction
    assert!(pniw_payroll::pto_balances[worker] < 6);
}

test "Withdraw Sick Leave Balance (ZPass & ANS Required)" {
    let worker = address("aleo1workerxyz456");
    let withdrawal_amount = 3;

    // Ensure worker is ZPass verified
    assert!(pniw_payroll::worker_zpass_verified[worker] == true);

    // Withdraw sick pay
    assert!(pniw_payroll::withdraw_pniw_payroll(worker, withdrawal_amount, false, true) == true);

    // Verify sick balance deduction
    assert!(pniw_payroll::sick_balances[worker] < 3);
}

test "Employer Funds Payroll Reserves (ZPass Required)" {
    let employer = address("aleo1employerabc123");
    let deposit_amount = 6000;

    // Ensure employer is ZPass verified
    assert!(pniw_payroll::employer_zpass_verified[employer] == true);

    // Deposit payroll reserves
    assert!(pniw_payroll::employer_deposit_usdc(employer, deposit_amount) == true);

    // Verify balance update
    assert!(pniw_payroll::get_usdc_balance(employer) == deposit_amount);
}

test "Ensure Employer Has Required Payroll Liquidity (ZPass Required)" {
    let employer = address("aleo1employerabc123");

    // Ensure employer is ZPass verified
    assert!(pniw_payroll::employer_zpass_verified[employer] == true);

    // Verify employer liquidity
    assert!(pniw_payroll::verify_usdc_pool(employer) == true);

    // Simulate underfunding
    pniw_payroll::set_usdc_balance(employer, 100);
    assert!(pniw_payroll::verify_usdc_pool(employer) == false);
}

test "Employer Penalized for Insufficient Payroll Liquidity (ZPass Required)" {
    let employer = address("aleo1employerabc123");

    // Simulate employer non-compliance
    pniw_payroll::set_usdc_balance(employer, 100);
    
    // Ensure employer is ZPass verified
    assert!(pniw_payroll::employer_zpass_verified[employer] == true);

    // Enforce penalty
    assert!(pniw_payroll::enforce_usdc_penalty(employer) == true);
}

test "Worker Invests PTO in Farm (ZPass & ANS Required)" {
    let worker = address("aleo1workerxyz456");
    let farm = address("aleo1farm789");
    let investment_amount = 12;
    let ans_name = "janedoe.pniw";

    // Ensure worker is ZPass verified
    assert!(pniw_payroll::worker_zpass_verified[worker] == true);

    // Assign ANS name to worker
    pniw_payroll::ans_registry[worker] = ans_name;
    pniw_payroll::ans_reverse_lookup[ans_name] = worker;

    // Worker invests PTO
    assert!(pniw_payroll::invest_pniw_pto_sick_pay(worker, investment_amount, "PTO") == true);

    // Verify PTO deduction
    assert!(pniw_payroll::pto_balances[worker] < 12);
    assert!(pniw_payroll::farm_investments[worker] == investment_amount);
}

test "Worker Invests Sick Pay in Farm (ZPass & ANS Required)" {
    let worker = address("aleo1workerxyz456");
    let farm = address("aleo1farm789");
    let investment_amount = 7;

    // Ensure worker is ZPass verified
    assert!(pniw_payroll::worker_zpass_verified[worker] == true);

    // Worker invests sick pay
    assert!(pniw_payroll::invest_pniw_pto_sick_pay(worker, investment_amount, "Sick") == true);

    // Verify Sick Pay deduction
    assert!(pniw_payroll::sick_balances[worker] < 7);
    assert!(pniw_payroll::farm_investments[worker] == 7);
}

test "SubDAO Reviews Employer Compliance (ZPass Required)" {
    let employer = address("aleo1employerabc123");

    // Ensure employer is ZPass verified
    assert!(pniw_payroll::employer_zpass_verified[employer] == true);

    // Enforce compliance check
    assert!(pniw_payroll::subdao_check_compliance(employer) == true);

    // Simulate employer non-compliance
    pniw_payroll::set_usdc_balance(employer, 50);
    assert!(pniw_payroll::subdao_check_compliance(employer) == false);
}
