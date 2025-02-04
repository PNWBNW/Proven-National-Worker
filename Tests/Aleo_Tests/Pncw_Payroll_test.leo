program pncw_payroll_test.aleo;

import pncw_payroll.aleo;

function test_payroll_submission() -> bool {
    let employer_address = aleo1exampleemployer123;
    let worker_address = aleo1workerexample123;
    let payroll_amount = 120_000u64;

    let payroll_status = pncw_payroll::submit_payroll(employer_address, worker_address, payroll_amount);

    assert(payroll_status == true, "PNcW Payroll submission failed");
    return payroll_status;
}

function test_payroll_execution() -> bool {
    let worker_address = aleo1workerexample123;
    let execution_status = pncw_payroll::execute_payroll(worker_address);

    assert(execution_status == true, "PNcW Payroll execution failed");
    return execution_status;
}

function test_employer_compliance() -> bool {
    let employer_address = aleo1exampleemployer123;
    let compliance_status = pncw_payroll::check_employer_compliance(employer_address);

    assert(compliance_status == true, "Employer compliance check failed");
    return compliance_status;
}

function test_worker_payment_verification() -> bool {
    let worker_address = aleo1workerexample123;
    let payment_status = pncw_payroll::verify_worker_payment(worker_address);

    assert(payment_status == true, "Worker payment verification failed");
    return payment_status;
}

function test_unauthorized_payroll_prevention() -> bool {
    let unauthorized_worker = aleo1unauthorizedworker123;
    let execution_status = pncw_payroll::execute_payroll(unauthorized_worker);

    assert(execution_status == false, "Unauthorized payroll transaction should not be allowed");
    return !execution_status;
}
