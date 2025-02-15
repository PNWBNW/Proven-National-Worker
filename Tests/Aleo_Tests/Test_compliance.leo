// 📌 Compliance Test Suite
// ✅ Ensures PNcW & PNiW Employers Meet Compliance Standards Before Payroll Execution
// ✅ Requires ZPass & ANS Verification for Workers
// ✅ Includes SubDAO Fee Verification for Aztec Payroll
// ✅ Ensures Payroll Routing Meets Regulatory Requirements

import process_tax_compliance.leo;
import government_api.leo;
import pncw_payroll.leo;
import pniw_payroll.leo;
import aztec_payroll.noir;
import worker_identity.leo;

test "Verify Employer Tax Compliance Before Payroll Execution" {
    let employer_id = 1001;

    // Employer initially non-compliant
    assert!(process_tax_compliance::check_compliance(employer_id) == false);

    // Employer makes a tax payment
    process_tax_compliance::pay_taxes(employer_id, 5000);

    // Verify compliance after tax payment
    assert!(process_tax_compliance::check_compliance(employer_id) == true);
}

test "Ensure Aleo Payroll Execution Fails if Employer is Non-Compliant" {
    let employer_id = 1002;
    let payroll_amount = 10000;

    // Employer has not paid taxes, should fail compliance check
    assert!(process_tax_compliance::check_compliance(employer_id) == false);

    // Attempt to verify payroll, should be denied
    assert!(government_api::verify_payroll(employer_id, payroll_amount) == false);
}

test "Ensure PNcW Payroll Cannot Be Processed for Non-Compliant Employers" {
    let employer_id = 1003;
    let worker_id = address("aleo1pncwworker456");
    let ans_name = "john_doe.pncw.ans";
    let wage = 5000;
    let hours_worked = 40;
    let trust_contribution = 200;

    // Ensure worker is ZPass verified
    assert!(worker_identity::is_worker_zpass_verified(worker_id) == true);

    // Assign ANS name
    worker_identity::ans_registry[worker_id] = ans_name;
    worker_identity::ans_reverse_lookup[ans_name] = worker_id;

    // Employer is not compliant
    assert!(process_tax_compliance::check_compliance(employer_id) == false);

    // Payroll processing should fail
    assert!(pncw_payroll::process_payroll(worker_id, employer_id, wage, hours_worked, trust_contribution) == false);
}

test "Ensure Aztec Payroll Processing Fails if SubDAO Fee is Missing" {
    let employer_id = field(1006);
    let worker_id = field(2001);
    let subdao_id = field(3001);
    let payroll_amount = 12000u64;
    let trust_contribution = 500u64;

    // Ensure worker & employer are ZPass verified
    assert!(aleo_zpass::is_verified(worker_id) == true);
    assert!(aleo_zpass::is_verified(employer_id) == true);

    // Ensure worker & SubDAO have ANS
    let worker_ans = "jane_doe.pncw.ans";
    let subdao_ans = "wa002_payroll.pnw.ans";
    worker_identity::ans_registry[worker_id] = worker_ans;
    worker_identity::ans_reverse_lookup[worker_ans] = worker_id;
    worker_identity::ans_registry[subdao_id] = subdao_ans;
    worker_identity::ans_reverse_lookup[subdao_ans] = subdao_id;

    // Employer is compliant but does not fund SubDAO fee
    assert!(process_tax_compliance::check_compliance(employer_id) == true);

    // Attempt Aztec payroll processing (should fail due to missing SubDAO fee)
    assert!(aztec_payroll::process_payroll(worker_id, employer_id, subdao_id, payroll_amount, trust_contribution) == false);
}

test "Verify Aleo & Aztec Payroll Execution with Full Compliance" {
    let employer_id = field(1007);
    let worker_id = field(2002);
    let subdao_id = field(3002);
    let payroll_amount = 9000u64;
    let trust_contribution = 400u64;

    // Ensure worker & employer are ZPass verified
    assert!(aleo_zpass::is_verified(worker_id) == true);
    assert!(aleo_zpass::is_verified(employer_id) == true);

    // Ensure worker & SubDAO have ANS
    let worker_ans = "bob_smith.pniw.ans";
    let subdao_ans = "tx003_payroll.pnw.ans";
    worker_identity::ans_registry[worker_id] = worker_ans;
    worker_identity::ans_reverse_lookup[worker_ans] = worker_id;
    worker_identity::ans_registry[subdao_id] = subdao_ans;
    worker_identity::ans_reverse_lookup[subdao_ans] = subdao_id;

    // Employer funds SubDAO fee & pays taxes
    process_tax_compliance::pay_taxes(employer_id, 25000);

    // Ensure compliance before payroll execution
    assert!(process_tax_compliance::check_compliance(employer_id) == true);

    // Execute Aztec payroll (should pass)
    let aztec_payroll_record = aztec_payroll::process_payroll(worker_id, employer_id, subdao_id, payroll_amount, trust_contribution);
    
    // Execute Aleo payroll (should pass)
    let aleo_payroll_success = pncw_payroll::process_payroll(worker_id, employer_id, payroll_amount, 40, trust_contribution);
    
    // Verify both payroll executions succeeded
    assert!(aleo_payroll_success == true);
    assert!(aztec_payroll_record.net_payout > 0);

    // Verify 0.1% SubDAO fee deduction
    let expected_subdao_fee = (payroll_amount * 1) / 1000;
    assert!(aztec_payroll_record.subdao_expense_fee == expected_subdao_fee);
}
