// 📌 PNiW Payroll Test Suite (Full: Aleo & Aztec Payroll)

import pniw_payroll.leo;
import aztec_bridge.noir;

// -------------------------------------------
// ✅ Standard Aleo Payroll Tests
// -------------------------------------------

test "Process Payroll for Aleo Worker (Standard Payroll)" {
    let worker = address("aleo1workerxyz456");
    let employer = address("aleo1employerabc123");
    let wage = 3500;
    let hours_worked = 40;
    let trust_contribution = 250;

    // Ensure employer funding is valid
    assert!(pniw_payroll::verify_employer_funding(employer) == true);

    // Process payroll (Aleo-based)
    assert!(pniw_payroll::process_payroll(worker, employer, wage, hours_worked, trust_contribution, 0) == true);

    // Verify balances
    assert!(pniw_payroll::payroll_records[worker] == wage);
    assert!(pniw_payroll::pto_balances[worker] > 0);
    assert!(pniw_payroll::sick_balances[worker] > 0);
    assert!(pniw_payroll::trust_funds[worker] == trust_contribution);
}

test "Withdraw Payroll Funds (Standard Aleo Payroll)" {
    let worker = address("aleo1workerxyz456");
    let withdrawal_amount = 1200;

    // Ensure worker has enough balance
    assert!(pniw_payroll::payroll_records[worker] >= withdrawal_amount);

    // Withdraw payroll
    assert!(pniw_payroll::withdraw_payroll(worker, withdrawal_amount, false, false, false) == true);

    // Verify deduction
    assert!(pniw_payroll::payroll_records[worker] == 2300);
}

test "Employer Funds Payroll Reserves (Standard Aleo Payroll)" {
    let employer = address("aleo1employerabc123");
    let deposit_amount = 6000;

    // Deposit payroll reserves
    assert!(pniw_payroll::employer_deposit_usdc(employer, deposit_amount) == true);

    // Verify balance update
    assert!(pniw_payroll::get_usdc_balance(employer) == deposit_amount);
}

// -------------------------------------------
// ✅ Aztec Payroll Tests (New Additions)
// -------------------------------------------

test "Worker Enables Aztec Payroll (ZPass & ANS Required)" {
    let worker = address("aleo1workerxyz456");
    let ans_name = "janedoe.pniw";

    // Ensure worker has ZPass verification
    assert!(aleo_zpass::is_verified(worker) == true);

    // Assign ANS name to worker
    pniw_payroll::ans_registry[worker] = ans_name;
    pniw_payroll::ans_reverse_lookup[ans_name] = worker;

    // Enable Aztec payroll
    assert!(pniw_payroll::set_aztec_payroll_preference(worker, true) == true);

    // Verify preference update
    assert!(pniw_payroll::aztec_payroll_enabled[worker] == true);
}

test "Process Payroll for Worker Using Aztec (ZPass & ANS Required)" {
    let worker = address("aleo1workerxyz456");
    let employer = address("aleo1employerabc123");
    let wage = 3500;
    let hours_worked = 40;
    let trust_contribution = 250;
    
    // Ensure employer funding is valid
    assert!(pniw_payroll::verify_employer_funding(employer) == true);
    
    // Enable Aztec Payroll
    assert!(pniw_payroll::set_aztec_payroll_preference(worker, true) == true);

    // Process payroll
    assert!(pniw_payroll::process_payroll(worker, employer, wage, hours_worked, trust_contribution, 0) == true);

    // Verify deductions before sending to Aztec
    assert!(pniw_payroll::payroll_records[worker] == wage - trust_contribution);
    assert!(pniw_payroll::trust_funds[worker] == trust_contribution);

    // Verify net payroll is routed through Aztec
    let net_payroll = wage - trust_contribution;
    assert!(aztec_bridge::transfer_payroll({
        recipient: worker,
        amount: net_payroll,
        fee_option: true,
        ans_domain: pniw_payroll::ans_registry[worker]
    }) == true);
}

test "Prevent Aztec Payroll Without ZPass & ANS" {
    let worker = address("aleo1workerxyz456");

    // Ensure worker is NOT ZPass verified
    assert!(aleo_zpass::is_verified(worker) == false);

    // Attempt to enable Aztec payroll (should fail)
    assert!(pniw_payroll::set_aztec_payroll_preference(worker, true) == false);
}

test "Verify Payroll Deduction Before Aztec Transfer" {
    let worker = address("aleo1workerxyz456");
    let employer = address("aleo1employerabc123");
    let wage = 5000;
    let trust_contribution = 500;

    // Enable Aztec Payroll
    assert!(pniw_payroll::set_aztec_payroll_preference(worker, true) == true);

    // Process payroll
    assert!(pniw_payroll::process_payroll(worker, employer, wage, 40, trust_contribution, 0) == true);

    // Ensure deductions occurred before sending to Aztec
    let net_wage = wage - trust_contribution;
    assert!(pniw_payroll::payroll_records[worker] == net_wage);
    assert!(pniw_payroll::trust_funds[worker] == trust_contribution);

    // Confirm net amount was transferred
    assert!(aztec_bridge::transfer_payroll({
        recipient: worker,
        amount: net_wage,
        fee_option: true,
        ans_domain: pniw_payroll::ans_registry[worker]
    }) == true);
}
