program employer_agreement_test.aleo;

import employer_agreement.aleo;

function test_employer_registration() -> bool {
    let employer_address = aleo1exampleaddress123;
    let registration_status = employer_agreement::register_employer(employer_address);

    assert(registration_status == true, "Employer registration failed");
    return registration_status;
}

function test_employer_compliance() -> bool {
    let employer_address = aleo1exampleaddress123;
    let compliance_status = employer_agreement::check_compliance(employer_address);

    assert(compliance_status == true, "Employer is not compliant");
    return compliance_status;
}

function test_payroll_submission() -> bool {
    let employer_address = aleo1exampleaddress123;
    let worker_address = aleo1workerexample123;
    let payroll_amount = 100_000u64;

    let payroll_status = employer_agreement::submit_payroll(employer_address, worker_address, payroll_amount);

    assert(payroll_status == true, "Payroll submission failed");
    return payroll_status;
}

function test_tax_payment() -> bool {
    let employer_address = aleo1exampleaddress123;
    let tax_amount = 10_000u64;

    let tax_status = employer_agreement::pay_taxes(employer_address, tax_amount);

    assert(tax_status == true, "Tax payment failed");
    return tax_status;
}

function test_blacklist_check() -> bool {
    let employer_address = aleo1exampleaddress123;

    let blacklist_status = employer_agreement::is_blacklisted(employer_address);

    assert(blacklist_status == false, "Employer should not be blacklisted");
    return blacklist_status;
}
