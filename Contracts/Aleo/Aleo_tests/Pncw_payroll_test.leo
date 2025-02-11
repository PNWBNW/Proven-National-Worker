// 📌 PNcW Payroll Test Suite

import pncw_payroll.leo;

test "Process Payroll and Accrue PTO/Sick Pay" {
    let worker = address("aleo1workerxyz123");
    let employer = address("aleo1employerabc456");

    // Set initial balances
    pncw_payroll::payroll_records[worker] = 0;
    pncw_payroll::pto_balances[worker] = 0;
    pncw_payroll::sick_balances[worker] = 0;

    let wage = 1000;
    let hours_worked = 40;
    let trust_contribution = 50;

    // Process payroll
    assert!(pncw_payroll::process_payroll(worker, employer, wage, hours_worked, trust_contribution) == true);

    // Verify balances updated
    assert!(pncw_payroll::payroll_records[worker] == wage);
    assert!(pncw_payroll::pto_balances[worker] == 2); // 1 hour PTO per 20 hours worked
    assert!(pncw_payroll::sick_balances[worker] == 1); // 1 hour sick per 40 hours worked
    assert!(pncw_payroll::trust_funds[worker] == trust_contribution);
}

test "Verify Employer USDC Pool Compliance" {
    let employer = address("aleo1employerabc456");

    // Set employer USDC balance
    pncw_payroll::minimum_usdc_pool[employer] = 5000;
    assert!(pncw_payroll::verify_usdc_pool(employer) == true);

    // Reduce employer balance (simulate underfunding)
    pncw_payroll::minimum_usdc_pool[employer] = 100;
    assert!(pncw_payroll::verify_usdc_pool(employer) == false);
}

test "Employer Deposit USDC into Payroll Pool" {
    let employer = address("aleo1employerabc456");

    // Set employer balance
    pncw_payroll::minimum_usdc_pool[employer] = 2000;
    assert!(pncw_payroll::verify_usdc_pool(employer) == true);

    // Deposit additional USDC
    assert!(pncw_payroll::employer_deposit_usdc(employer, 3000) == true);

    // Verify updated balance
    assert!(pncw_payroll::minimum_usdc_pool[employer] == 5000);
}

test "Enforce USDC Penalty for Noncompliance" {
    let employer = address("aleo1employerabc456");

    // Set employer balance below requirement
    pncw_payroll::minimum_usdc_pool[employer] = 200;

    // Enforce penalty (10% of missing balance)
    assert!(pncw_payroll::enforce_usdc_penalty(employer) == true);

    // Ensure penalty deducted
    assert!(pncw_payroll::minimum_usdc_pool[employer] < 200);
}

test "Worker Withdraws Payroll (With PTO & Sick Pay)" {
    let worker = address("aleo1workerxyz123");

    // Set initial balances
    pncw_payroll::payroll_records[worker] = 1000;
    pncw_payroll::pto_balances[worker] = 50;
    pncw_payroll::sick_balances[worker] = 40;

    // Worker withdraws payroll including PTO & Sick Pay
    assert!(pncw_payroll::withdraw_payroll(worker, 1090, true, true) == true);

    // Verify balances deducted correctly
    assert!(pncw_payroll::payroll_records[worker] == 0);
    assert!(pncw_payroll::pto_balances[worker] == 10); // 50 - 40 used
    assert!(pncw_payroll::sick_balances[worker] == 0); // Fully used
}

test "Agricultural Worker Invests PTO/Sick Pay in Farm" {
    let worker = address("aleo1workerxyz123");

    // Set worker category
    pncw_payroll::worker_category[worker] = "Agricultural";

    // Set PTO/Sick balances
    pncw_payroll::pto_balances[worker] = 40;
    pncw_payroll::sick_balances[worker] = 30;

    // Attempt farm investment using PTO
    assert!(pncw_payroll::invest_pto_sick_pay(worker, 20, "PTO") == true);
    assert!(pncw_payroll::pto_balances[worker] == 20); // Deducted

    // Attempt farm investment using Sick Pay
    assert!(pncw_payroll::invest_pto_sick_pay(worker, 10, "Sick") == true);
    assert!(pncw_payroll::sick_balances[worker] == 20); // Deducted
}

test "Employer Penalty for Payroll Noncompliance" {
    let employer = address("aleo1employerabc456");

    // Set employer funds
    pncw_payroll::employer_pto_funds[employer] = 1000;
    pncw_payroll::employer_sick_funds[employer] = 1000;

    // Apply penalty
    assert!(pncw_payroll::employer_penalty(employer, 500) == true);

    // Verify funds reduced correctly
    assert!(pncw_payroll::employer_pto_funds[employer] == 750); // 50% penalty taken
    assert!(pncw_payroll::employer_sick_funds[employer] == 750);
}

test "SubDAO Compliance Check on Employer" {
    let employer = address("aleo1employerabc456");

    // Employer is noncompliant
    pncw_payroll::employer_pto_funds[employer] = -100;
    pncw_payroll::employer_sick_funds[employer] = 500;

    // Check compliance (should fail)
    assert!(pncw_payroll::subdao_check_compliance(employer) == false);

    // Ensure penalty applied
    assert!(pncw_payroll::employer_pto_funds[employer] < 0);
}

test "ANS Integration: Worker Payroll Lookup" {
    let worker = address("aleo1workerxyz123");
    let ans_name = "john.doe.pncw";

    // Register worker ANS
    pncw_payroll::ans_registry[worker] = ans_name;
    pncw_payroll::ans_reverse_lookup[ans_name] = worker;

    // Verify ANS mapping works
    assert!(pncw_payroll::lookup_worker_by_ans(ans_name) == worker);
    assert!(pncw_payroll::lookup_worker_by_address(worker) == ans_name);
}
