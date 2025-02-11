// 📌 Compliance Test Suite
// ✅ Ensures PNcW & PNiW Employers Meet Compliance Standards Before Payroll Execution
// ✅ Requires ZPass & ANS Verification for Workers

import process_tax_compliance.leo;
import government_api.leo;
import pncw_payroll.leo;
import pniw_payroll.leo;
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

test "Ensure Payroll Execution Fails if Employer is Non-Compliant" {
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
    let ans_name = "janedoe.pncw";
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

test "Ensure PNiW Payroll Cannot Be Processed for Non-Compliant Employers" {
    let employer_id = 1004;
    let worker_id = address("aleo1pniwworker789");
    let ans_name = "janedoe.pniw";
    let wage = 4500;
    let hours_worked = 38;
    let trust_contribution = 150;

    // Ensure worker is ZPass verified
    assert!(worker_identity::is_worker_zpass_verified(worker_id) == true);

    // Assign ANS name
    worker_identity::ans_registry[worker_id] = ans_name;
    worker_identity::ans_reverse_lookup[ans_name] = worker_id;

    // Employer is not compliant
    assert!(process_tax_compliance::check_compliance(employer_id) == false);

    // Payroll processing should fail
    assert!(pniw_payroll::process_pniw_payroll(worker_id, employer_id, wage, hours_worked, trust_contribution) == false);
}

test "Verify Payroll Compliance with Government API & ZPass/ANS" {
    let employer_id = 1005;
    let worker_id = address("aleo1pncwworker456");
    let ans_name = "janedoe.pncw";
    let payroll_amount = 15000;

    // Ensure worker is ZPass verified
    assert!(worker_identity::is_worker_zpass_verified(worker_id) == true);

    // Assign ANS name
    worker_identity::ans_registry[worker_id] = ans_name;
    worker_identity::ans_reverse_lookup[ans_name] = worker_id;

    // Employer initially non-compliant
    assert!(process_tax_compliance::check_compliance(employer_id) == false);

    // Employer pays taxes
    process_tax_compliance::pay_taxes(employer_id, 20000);

    // Ensure compliance
    assert!(process_tax_compliance::check_compliance(employer_id) == true);

    // Verify payroll execution
    assert!(government_api::verify_payroll(employer_id, payroll_amount) == true);
}
