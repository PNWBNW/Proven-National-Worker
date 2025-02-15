// 📌 PNcW Payroll Test Suite (Full: Aleo & Aztec Payroll)

import pncw_payroll.leo;
import aztec_bridge.noir;

// -------------------------------------------
// ✅ Standard Aleo Payroll Tests
// -------------------------------------------

test "Process Payroll for Aleo Worker (Standard Payroll)" {
    let worker = address("aleo1workerxyz456");
    let employer = address("aleo1employerabc123");
    let wage = 3000;
    let hours_worked = 40;
    let trust_contribution = 200;

    // Ensure employer funding is valid
    assert!(pncw_payroll::verify_employer_funding(employer) == true);

    // Process payroll (Aleo-based)
    assert!(pncw_payroll::process_payroll(worker, employer, wage, hours_worked, trust_contribution, 0) == true);

    // Verify balances
    assert!(pncw_payroll::payroll_records[worker] == wage);
    assert!(pncw_payroll::pto_balances[worker] > 0);
    assert!(pncw_payroll::sick_balances[worker] > 0);
    assert!(pncw_payroll::trust_funds[worker] == trust_contribution);
}

test "Withdraw Payroll Funds (Standard Aleo Payroll)" {
    let worker = address("aleo1workerxyz456");
    let withdrawal_amount = 1000;

    // Ensure worker has enough balance
    assert!(pncw_payroll::payroll_records[worker] >= withdrawal_amount);

    // Withdraw payroll
    assert!(pncw_payroll::withdraw_payroll(worker, withdrawal_amount, false, false, false) == true);

    // Verify deduction
    assert!(pncw_payroll::payroll_records[worker] == 2000);
}

test "Employer Funds Payroll Reserves (Standard Aleo Payroll)" {
    let employer = address("aleo1employerabc123");
    let deposit_amount = 5000;

    // Deposit payroll reserves
    assert!(pncw_payroll::employer_deposit_usdc(employer, deposit_amount) == true);

    // Verify balance update
    assert!(pncw_payroll::get_usdc_balance(employer) == deposit_amount);
}

// -------------------------------------------
// ✅ Aztec Payroll Tests (New Additions)
// -------------------------------------------

test "Worker Enables Aztec Payroll (ZPass & ANS Required)" {
    let worker = address("aleo1workerxyz456");
    let ans_name = "johndoe.pncw";

    // Ensure worker has ZPass verification
    assert!(aleo_zpass::is_verified(worker) == true);

    // Assign ANS name to worker
    pncw_payroll::ans_registry[worker] = ans_name;
    pncw_payroll::ans_reverse_lookup[ans_name] = worker;

    // Enable Aztec payroll
    assert!(pncw_payroll::set_aztec_payroll_preference(worker, true) == true);

    // Verify preference update
    assert!(pncw_payroll::aztec_payroll_enabled[worker] == true);
}

test "Process Payroll for Worker Using Aztec (ZPass & ANS Required)" {
    let worker = address("aleo1workerxyz456");
    let employer = address("aleo1employerabc123");
    let wage = 3000;
    let hours_worked = 40;
    let trust_contribution = 200;
    
    // Ensure employer funding is valid
    assert!(pncw_payroll::verify_employer_funding(employer) == true);
    
    // Enable Aztec Payroll
    assert!(pncw_payroll::set_aztec_payroll_preference(worker, true) == true);

    // Process payroll
    assert!(pncw_payroll::process_payroll(worker, employer, wage, hours_worked, trust_contribution, 0) == true);

    // Verify deductions before sending to Aztec
    assert!(pncw_payroll::payroll_records[worker] == wage - trust_contribution);
    assert!(pncw_payroll::trust_funds[worker] == trust_contribution);

    // Verify net payroll is routed through Aztec
    let net_payroll = wage - trust_contribution;
    assert!(aztec_bridge::transfer_payroll({
        recipient: worker,
        amount: net_payroll,
        fee_option: true,
        ans_domain: pncw_payroll::ans_registry[worker]
    }) == true);
}

test "Prevent Aztec Payroll Without ZPass & ANS" {
    let worker = address("aleo1workerxyz456");

    // Ensure worker is NOT ZPass verified
    assert!(aleo_zpass::is_verified(worker) == false);

    // Attempt to enable Aztec payroll (should fail)
    assert!(pncw_payroll::set_aztec_payroll_preference(worker, true) == false);
}

test "Verify Payroll Deduction Before Aztec Transfer" {
    let worker = address("aleo1workerxyz456");
    let employer = address("aleo1employerabc123");
    let wage = 5000;
    let trust_contribution = 500;

    // Enable Aztec Payroll
    assert!(pncw_payroll::set_aztec_payroll_preference(worker, true) == true);

    // Process payroll
    assert!(pncw_payroll::process_payroll(worker, employer, wage, 40, trust_contribution, 0) == true);

    // Ensure deductions occurred before sending to Aztec
    let net_wage = wage - trust_contribution;
    assert!(pncw_payroll::payroll_records[worker] == net_wage);
    assert!(pncw_payroll::trust_funds[worker] == trust_contribution);

    // Confirm net amount was transferred
    assert!(aztec_bridge::transfer_payroll({
        recipient: worker,
        amount: net_wage,
        fee_option: true,
        ans_domain: pncw_payroll::ans_registry[worker]
    }) == true);
}
