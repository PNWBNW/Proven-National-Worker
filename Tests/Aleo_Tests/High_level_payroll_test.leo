// 📌 High-Level Payroll Test Suite
// ✅ Ensures PNcW & PNiW Payroll Systems Function Correctly in Parallel

import pncw_payroll.leo;
import pniw_payroll.leo;

test "PNcW & PNiW Payroll Processing (ZPass & ANS Required)" {
    let pncw_worker = address("aleo1pncwworker456");
    let pniw_worker = address("aleo1pniwworker789");
    let employer = address("aleo1employer123");
    let ans_pncw = "janedoe.pncw";
    let ans_pniw = "janedoe.pniw";
    let wage_pncw = 5000;
    let wage_pniw = 6000;
    let hours_worked = 40;
    let trust_contribution_pncw = 500;
    let trust_contribution_pniw = 600;

    // Ensure both workers are ZPass verified
    assert!(pncw_payroll::worker_zpass_verified[pncw_worker] == true);
    assert!(pniw_payroll::worker_zpass_verified[pniw_worker] == true);

    // Assign ANS names
    pncw_payroll::ans_registry[pncw_worker] = ans_pncw;
    pniw_payroll::ans_registry[pniw_worker] = ans_pniw;
    pncw_payroll::ans_reverse_lookup[ans_pncw] = pncw_worker;
    pniw_payroll::ans_reverse_lookup[ans_pniw] = pniw_worker;

    // Process payroll for both worker classes
    assert!(pncw_payroll::process_payroll(pncw_worker, employer, wage_pncw, hours_worked, trust_contribution_pncw) == true);
    assert!(pniw_payroll::process_pniw_payroll(pniw_worker, employer, wage_pniw, hours_worked, trust_contribution_pniw) == true);

    // Verify payroll records
    assert!(pncw_payroll::payroll_records[pncw_worker] == wage_pncw);
    assert!(pniw_payroll::payroll_records[pniw_worker] == wage_pniw);
}

test "PNcW & PNiW Workers Request Payroll Withdrawals" {
    let pncw_worker = address("aleo1pncwworker456");
    let pniw_worker = address("aleo1pniwworker789");
    let ans_pncw = "janedoe.pncw";
    let ans_pniw = "janedoe.pniw";
    let amount_pncw = 2000;
    let amount_pniw = 2500;

    // Ensure both workers are ZPass verified
    assert!(pncw_payroll::worker_zpass_verified[pncw_worker] == true);
    assert!(pniw_payroll::worker_zpass_verified[pniw_worker] == true);

    // Assign ANS names
    pncw_payroll::ans_registry[pncw_worker] = ans_pncw;
    pniw_payroll::ans_registry[pniw_worker] = ans_pniw;
    pncw_payroll::ans_reverse_lookup[ans_pncw] = pncw_worker;
    pniw_payroll::ans_reverse_lookup[ans_pniw] = pniw_worker;

    // Workers withdraw payroll
    assert!(pncw_payroll::withdraw_payroll(pncw_worker, amount_pncw, true, false) == true);
    assert!(pniw_payroll::withdraw_pniw_payroll(pniw_worker, amount_pniw, false, true) == true);
}

test "PNcW & PNiW Workers Receive Trust Fund Contributions" {
    let pncw_worker = address("aleo1pncwworker456");
    let pniw_worker = address("aleo1pniwworker789");
    let trust_contribution_pncw = 500;
    let trust_contribution_pniw = 600;

    // Ensure both workers are ZPass verified
    assert!(pncw_payroll::worker_zpass_verified[pncw_worker] == true);
    assert!(pniw_payroll::worker_zpass_verified[pniw_worker] == true);

    // Verify trust fund balances reflect contributions
    assert!(pncw_payroll::trust_funds[pncw_worker] == trust_contribution_pncw);
    assert!(pniw_payroll::trust_funds[pniw_worker] == trust_contribution_pniw);
}

test "Employer Fails to Maintain Payroll Liquidity (Triggers Compliance Check)" {
    let employer = address("aleo1employer123");

    // Ensure employer is underfunded
    assert!(pncw_payroll::verify_usdc_pool(employer) == false);
    assert!(pniw_payroll::verify_usdc_pool(employer) == false);

    // Trigger penalty enforcement
    assert!(pncw_payroll::enforce_usdc_penalty(employer) == true);
    assert!(pniw_payroll::enforce_usdc_penalty(employer) == true);
}

test "SubDAO Checks Employer Compliance Across Both Payroll Systems" {
    let employer = address("aleo1employer123");

    // Ensure employer is non-compliant
    assert!(pncw_payroll::subdao_check_compliance(employer) == false);
    assert!(pniw_payroll::subdao_check_compliance(employer) == false);

    // Employer deposits required liquidity
    assert!(pncw_payroll::employer_deposit_usdc(employer, 15000) == true);
    assert!(pniw_payroll::employer_deposit_usdc(employer, 15000) == true);

    // Recheck compliance
    assert!(pncw_payroll::subdao_check_compliance(employer) == true);
    assert!(pniw_payroll::subdao_check_compliance(employer) == true);
}
