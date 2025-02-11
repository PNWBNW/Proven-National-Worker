// 📌 PNiW Payroll Test Suite

import pniw_payroll.leo;

test "Process PNiW Payroll and Accrue PTO/Sick Pay" {
    let worker = address("aleo1workerimm123");
    let employer = address("aleo1employerxyz789");

    // Set initial balances
    pniw_payroll::payroll_records[worker] = 0;
    pniw_payroll::pto_balances[worker] = 0;
    pniw_payroll::sick_balances[worker] = 0;

    let wage = 1200;
    let hours_worked = 40;
    let trust_contribution = 60;

    // Process payroll
    assert!(pniw_payroll::process_pniw_payroll(worker, employer, wage, hours_worked, trust_contribution) == true);

    // Verify balances updated
    assert!(pniw_payroll::payroll_records[worker] == wage);
    assert!(pniw_payroll::pto_balances[worker] == 2); // 1 hour PTO per 20 hours worked
    assert!(pniw_payroll::sick_balances[worker] == 1); // 1 hour sick per 40 hours worked
    assert!(pniw_payroll::trust_funds[worker] == trust_contribution);
}

test "Verify Employer USDC Pool Compliance" {
    let employer = address("aleo1employerxyz789");

    // Set employer USDC balance
    pniw_payroll::minimum_usdc_pool[employer] = 5000;
    assert!(pniw_payroll::verify_usdc_pool(employer) == true);

    // Reduce employer balance (simulate underfunding)
    pniw_payroll::minimum_usdc_pool[employer] = 200;
    assert!(pniw_payroll::verify_usdc_pool(employer) == false);
}

test "Employer Deposits USDC into Payroll Pool" {
    let employer = address("aleo1employerxyz789");

    // Set employer balance
    pniw_payroll::minimum_usdc_pool[employer] = 2500;
    assert!(pniw_payroll::verify_usdc_pool(employer) == true);

    // Deposit additional USDC
    assert!(pniw_payroll::employer_deposit_usdc(employer, 3000) == true);

    // Verify updated balance
    assert!(pniw_payroll::minimum_usdc_pool[employer] == 5500);
}

test "Enforce USDC Penalty for Noncompliance" {
    let employer = address("aleo1employerxyz789");

    // Set employer balance below requirement
    pniw_payroll::minimum_usdc_pool[employer] = 100;

    // Enforce penalty (10% of missing balance)
    assert!(pniw_payroll::enforce_usdc_penalty(employer) == true);

    // Ensure penalty deducted
    assert!(pniw_payroll::minimum_usdc_pool[employer] < 100);
}

test "Worker Withdraws Payroll (With PTO & Sick Pay)" {
    let worker = address("aleo1workerimm123");

    // Set initial balances
    pniw_payroll::payroll_records[worker] = 1200;
    pniw_payroll::pto_balances[worker] = 45;
    pniw_payroll::sick_balances[worker] = 35;

    // Worker withdraws payroll including PTO & Sick Pay
    assert!(pniw_payroll::withdraw_pniw_payroll(worker, 1265, true, true) == true);

    // Verify balances deducted correctly
    assert!(pniw_payroll::payroll_records[worker] == 0);
    assert!(pniw_payroll::pto_balances[worker] == 10); // 45 - 35 used
    assert!(pniw_payroll::sick_balances[worker] == 0); // Fully used
}

test "Agricultural Worker Invests PTO/Sick Pay in Farm" {
    let worker = address("aleo1workerimm123");

    // Set worker category
    pniw_payroll::worker_category[worker] = "Agricultural";

    // Set PTO/Sick balances
    pniw_payroll::pto_balances[worker] = 50;
    pniw_payroll::sick_balances[worker] = 40;

    // Attempt farm investment using PTO
    assert!(pniw_payroll::invest_pniw_pto_sick_pay(worker, 30, "PTO") == true);
    assert!(pniw_payroll::pto_balances[worker] == 20); // Deducted

    // Attempt farm investment using Sick Pay
    assert!(pniw_payroll::invest_pniw_pto_sick_pay(worker, 15, "Sick") == true);
    assert!(pniw_payroll::sick_balances[worker] == 25); // Deducted
}

test "Employer Penalty for Payroll Noncompliance" {
    let employer = address("aleo1employerxyz789");

    // Set employer funds
    pniw_payroll::employer_pto_funds[employer] = 1100;
    pniw_payroll::employer_sick_funds[employer] = 1100;

    // Apply penalty
    assert!(pniw_payroll::employer_penalty(employer, 600) == true);

    // Verify funds reduced correctly
    assert!(pniw_payroll::employer_pto_funds[employer] == 800); // 50% penalty taken
    assert!(pniw_payroll::employer_sick_funds[employer] == 800);
}

test "SubDAO Compliance Check on Employer" {
    let employer = address("aleo1employerxyz789");

    // Employer is noncompliant
    pniw_payroll::employer_pto_funds[employer] = -200;
    pniw_payroll::employer_sick_funds[employer] = 600;

    // Check compliance (should fail)
    assert!(pniw_payroll::subdao_check_compliance(employer) == false);

    // Ensure penalty applied
    assert!(pniw_payroll::employer_pto_funds[employer] < 0);
}

test "ANS Integration: Worker Payroll Lookup" {
    let worker = address("aleo1workerimm123");
    let ans_name = "jane.doe.pniw";

    // Register worker ANS
    pniw_payroll::ans_registry[worker] = ans_name;
    pniw_payroll::ans_reverse_lookup[ans_name] = worker;

    // Verify ANS mapping works
    assert!(pniw_payroll::lookup_worker_by_ans(ans_name) == worker);
    assert!(pniw_payroll::lookup_worker_by_address(worker) == ans_name);
}
