// 📌 Government API Compliance Test Suite
// ✅ Ensures Employers Are Tax-Compliant Before Payroll Execution
// ✅ Requires ZPass & ANS Verification for Workers

import government_api.leo;
import process_tax_compliance.leo;
import worker_identity.leo;
import pncw_payroll.leo;
import pniw_payroll.leo;

test "Verify Government API Tax Compliance Before Payroll Execution" {
    let employer_id = 2001;

    // Employer initially non-compliant
    assert!(government_api::verify_tax_compliance(employer_id) == false);

    // Employer makes a tax payment
    process_tax_compliance::pay_taxes(employer_id, 8000);

    // Verify compliance after tax payment
    assert!(government_api::verify_tax_compliance(employer_id) == true);
}

test "Ensure Payroll Execution Fails if Employer is Non-Compliant" {
    let employer_id = 2002;
    let payroll_amount = 12000;

    // Employer has not paid taxes, should fail compliance check
    assert!(government_api::verify_tax_compliance(employer_id) == false);

    // Attempt to verify payroll, should be denied
    assert!(government_api::verify_payroll(employer_id, payroll_amount) == false);
}

test "Ensure PNcW Payroll Cannot Be Processed Without ZPass & ANS Verification" {
    let employer_id = 2003;
    let worker_id = address("aleo1pncwworker123");
    let ans_name = "johndoe.pncw";
    let wage = 6000;
    let hours_worked = 40;
    let trust_contribution = 300;

    // Ensure worker is not yet ZPass verified
    assert!(worker_identity::is_worker_zpass_verified(worker_id) == false);

    // Assign ANS name
    worker_identity::ans_registry[worker_id] = ans_name;
    worker_identity::ans_reverse_lookup[ans_name] = worker_id;

    // Attempt payroll execution (should fail)
    assert!(pncw_payroll::process_payroll(worker_id, employer_id, wage, hours_worked, trust_contribution) == false);

    // Now verify worker with ZPass
    worker_identity::verify_worker_zpass(worker_id);

    // Attempt payroll execution again (should still fail due to non-compliant employer)
    assert!(pncw_payroll::process_payroll(worker_id, employer_id, wage, hours_worked, trust_contribution) == false);
}

test "Ensure PNiW Payroll Cannot Be Processed Without ZPass & ANS Verification" {
    let employer_id = 2004;
    let worker_id = address("aleo1pniwworker456");
    let ans_name = "janedoe.pniw";
    let wage = 5000;
    let hours_worked = 38;
    let trust_contribution = 250;

    // Ensure worker is not yet ZPass verified
    assert!(worker_identity::is_worker_zpass_verified(worker_id) == false);

    // Assign ANS name
    worker_identity::ans_registry[worker_id] = ans_name;
    worker_identity::ans_reverse_lookup[ans_name] = worker_id;

    // Attempt payroll execution (should fail)
    assert!(pniw_payroll::process_pniw_payroll(worker_id, employer_id, wage, hours_worked, trust_contribution) == false);

    // Now verify worker with ZPass
    worker_identity::verify_worker_zpass(worker_id);

    // Attempt payroll execution again (should still fail due to non-compliant employer)
    assert!(pniw_payroll::process_pniw_payroll(worker_id, employer_id, wage, hours_worked, trust_contribution) == false);
}

test "Verify Payroll Execution Passes After Full Compliance" {
    let employer_id = 2005;
    let worker_id = address("aleo1pncwworker789");
    let ans_name = "michael.pncw";
    let payroll_amount = 14000;

    // Ensure worker is ZPass verified
    worker_identity::verify_worker_zpass(worker_id);
    assert!(worker_identity::is_worker_zpass_verified(worker_id) == true);

    // Assign ANS name
    worker_identity::ans_registry[worker_id] = ans_name;
    worker_identity::ans_reverse_lookup[ans_name] = worker_id;

    // Employer initially non-compliant
    assert!(government_api::verify_tax_compliance(employer_id) == false);

    // Employer pays taxes
    process_tax_compliance::pay_taxes(employer_id, 25000);

    // Ensure compliance
    assert!(government_api::verify_tax_compliance(employer_id) == true);

    // Verify payroll execution
    assert!(government_api::verify_payroll(employer_id, payroll_amount) == true);
}
