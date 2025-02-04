program main_test.aleo;

import main.aleo;

function test_worker_registration() -> bool {
    let worker_address = aleo1workerexample123;
    let registration_status = main::register_worker(worker_address);

    assert(registration_status == true, "Worker registration failed");
    return registration_status;
}

function test_worker_verification() -> bool {
    let worker_address = aleo1workerexample123;
    let verification_status = main::verify_worker(worker_address);

    assert(verification_status == true, "Worker verification failed");
    return verification_status;
}

function test_employer_compliance() -> bool {
    let employer_address = aleo1exampleemployer123;
    let compliance_status = main::check_employer_compliance(employer_address);

    assert(compliance_status == true, "Employer compliance check failed");
    return compliance_status;
}

function test_payroll_submission() -> bool {
    let employer_address = aleo1exampleemployer123;
    let worker_address = aleo1workerexample123;
    let payroll_amount = 150_000u64;

    let payroll_status = main::submit_payroll(employer_address, worker_address, payroll_amount);

    assert(payroll_status == true, "Payroll submission failed");
    return payroll_status;
}

function test_trust_pool_contribution() -> bool {
    let worker_address = aleo1workerexample123;
    let contribution_amount = 10_000u64;

    let contribution_status = main::contribute_to_trust_pool(worker_address, contribution_amount);

    assert(contribution_status == true, "Trust pool contribution failed");
    return contribution_status;
}

function test_trust_pool_withdrawal() -> bool {
    let worker_address = aleo1workerexample123;
    let withdrawal_amount = 5_000u64;

    let withdrawal_status = main::withdraw_from_trust_pool(worker_address, withdrawal_amount);

    assert(withdrawal_status == true, "Trust pool withdrawal failed");
    return withdrawal_status;
}
