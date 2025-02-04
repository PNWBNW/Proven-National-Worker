
program pniw_payroll_test.aleo;

import pniw_payroll.aleo;

function test_payroll_submission() -> bool {
    let employer_address = aleo1exampleemployer123;
    let worker_address = aleo1workerexample123;
    let payroll_amount = 110_000u64;

    let payroll_status = pniw_payroll::submit_payroll(employer_address, worker_address, payroll_amount);

    assert(payroll_status == true, "PNiW Payroll submission failed");
    return payroll_status;
}

function test_payroll_execution() -> bool {
    let worker_address = aleo1workerexample123;
    let execution_status = pniw_payroll::execute_payroll(worker_address);

    assert(execution_status == true, "PNiW Payroll execution failed");
    return execution_status;
}

function test_employer_compliance() -> bool {
    let employer_address = aleo1exampleemployer123;
    let compliance_status = pniw_payroll::check_employer_compliance(employer_address);

    assert(compliance_status == true, "Employer compliance check failed");
    return compliance_status;
}

function test_worker_payment_verification() -> bool {
    let worker_address = aleo1workerexample123;
    let payment_status = pniw_payroll::verify_worker_payment(worker_address);

    assert(payment_status == true, "Worker payment verification failed");
    return payment_status;
}

function test_unauthorized_payroll_prevention() -> bool {
    let unauthorized_worker = aleo1unauthorizedworker123;
    let execution_status = pniw_payroll::execute_payroll(unauthorized_worker);

    assert(execution_status == false, "Unauthorized payroll transaction should not be allowed");
    return !execution_status;
}

function test_batch_payroll_processing() -> bool {
    let employer_address = aleo1exampleemployer123;
    let workers = [
        aleo1worker1example123,
        aleo1worker2example123,
        aleo1worker3example123
    ];
    let payroll_amount = 90_000u64;

    for worker in workers.iter() {
        let submission_status = pniw_payroll::submit_payroll(employer_address, worker, payroll_amount);
        assert(submission_status == true, "Batch payroll submission failed for worker");
    }

    for worker in workers.iter() {
        let execution_status = pniw_payroll::execute_payroll(worker);
        assert(execution_status == true, "Batch payroll execution failed for worker");
    }

    return true;
}

function test_rollup_batch_processing() -> bool {
    let employer_address = aleo1exampleemployer123;
    let batch_status = pniw_payroll::process_rollup_batch(employer_address);

    assert(batch_status == true, "Rollup batch processing failed");
    return batch_status;
}
