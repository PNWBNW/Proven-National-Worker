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

function test_batch_payroll_processing() -> bool {
    let employer_address = aleo1exampleemployer123;
    let workers = [
        aleo1worker1example123,
        aleo1worker2example123,
        aleo1worker3example123
    ];
    let payroll_amount = 100_000u64;

    for worker in workers.iter() {
        let submission_status = pncw_payroll::submit_payroll(employer_address, worker, payroll_amount);
        assert(submission_status == true, "Batch payroll submission failed for worker");
    }

    for worker in workers.iter() {
        let execution_status = pncw_payroll::execute_payroll(worker);
        assert(execution_status == true, "Batch payroll execution failed for worker");
    }

    return true;
}

function test_rollup_batch_processing() -> bool {
    let employer_address = aleo1exampleemployer123;
    let batch_status = pncw_payroll::process_rollup_batch(employer_address);

    assert(batch_status == true, "Rollup batch processing failed");
    return batch_status;
}
