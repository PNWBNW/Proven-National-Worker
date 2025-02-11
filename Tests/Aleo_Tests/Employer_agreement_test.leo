// 📌 Employer Agreement Test Suite

import employer_agreement.leo;

test "Register Employer with Initial Deposit, Farm Types, and ZPass Verification" {
    let employer = address("aleo1employerabc123");
    let deposit = 10000;
    let farm_types = ["Organic", "Dairy"];

    // Ensure employer is ZPass verified before registration
    employer_agreement::employer_zpass_verified[employer] = true;

    // Register employer
    assert!(employer_agreement::register_employer(employer, deposit, farm_types) == true);

    // Verify employer registration
    assert!(employer_agreement::employer_balances[employer] == deposit);
    assert!(employer_agreement::employer_status[employer] == true);
    assert!(employer_agreement::employer_farm_types[employer] == farm_types);
}

test "Assign ZPass Verified Worker to Employer with Hourly Wage" {
    let worker = address("aleo1workerxyz456");
    let employer = address("aleo1employerabc123");
    let wage = 25;

    // Ensure worker is ZPass verified
    employer_agreement::worker_zpass_verified[worker] = true;

    // Assign worker
    assert!(employer_agreement::assign_worker(worker, employer, true, wage) == true);

    // Verify assignment
    assert!(employer_agreement::worker_assignments[worker] == employer);
    assert!(employer_agreement::worker_hourly_wages[worker] == wage);
}

test "Verify Hourly Payroll Funding Before Worker Clock-In (ZPass Required)" {
    let worker = address("aleo1workerxyz456");
    let employer = address("aleo1employerabc123");

    // Ensure employer is ZPass verified
    employer_agreement::employer_zpass_verified[employer] = true;

    // Set employer payroll balance
    employer_agreement::employer_balances[employer] = 5000;
    employer_agreement::employer_hourly_buffer[employer] = 24;

    // Ensure hourly funding is valid
    assert!(employer_agreement::enforce_hourly_funding(worker) == true);

    // Reduce employer balance (simulate underfunding)
    employer_agreement::employer_balances[employer] = 100;
    assert!(employer_agreement::enforce_hourly_funding(worker) == false);
}

test "Employer Agrees to Worker Farm Investment Negotiations (ZPass Required)" {
    let employer = address("aleo1employerabc123");

    // Ensure employer is ZPass verified
    employer_agreement::employer_zpass_verified[employer] = true;

    // Employer agrees
    assert!(employer_agreement::employer_agree_to_farm_investment(employer) == true);

    // Verify agreement
    assert!(employer_agreement::employer_farm_investment_agreement[employer] == true);
}

test "Register Farm Certification (ZPass & API Verified)" {
    let employer = address("aleo1employerabc123");
    let certification = "USDA Organic";

    // Ensure employer is ZPass verified
    employer_agreement::employer_zpass_verified[employer] = true;

    // Register certification
    assert!(employer_agreement::register_farm_certification(employer, certification) == true);

    // Verify certification stored
    assert!(employer_agreement::employer_certifications[employer].contains(certification));
}

test "Enforce Contract Worker Funding with 25% Buffer (ZPass Required)" {
    let worker = address("aleo1workerxyz456");
    let employer = address("aleo1employerabc123");
    let contract_amount = 4000;

    // Ensure employer is ZPass verified
    employer_agreement::employer_zpass_verified[employer] = true;

    // Set employer balance
    employer_agreement::employer_balances[employer] = 5500;

    // Ensure compliance
    assert!(employer_agreement::enforce_contract_funding(worker, employer, contract_amount) == true);

    // Reduce balance below buffer requirement (simulate underfunding)
    employer_agreement::employer_balances[employer] = 4000;
    assert!(employer_agreement::enforce_contract_funding(worker, employer, contract_amount) == false);
}

test "Employer Deposits Additional Payroll Funds (ZPass Required)" {
    let employer = address("aleo1employerabc123");

    // Ensure employer is ZPass verified
    employer_agreement::employer_zpass_verified[employer] = true;

    // Set initial balance
    employer_agreement::employer_balances[employer] = 8000;

    // Deposit additional funds
    assert!(employer_agreement::fund_employer(employer, 3000) == true);

    // Verify balance update
    assert!(employer_agreement::employer_balances[employer] == 11000);
}

test "Employer Penalty for Repeated Payroll Noncompliance (ZPass Required)" {
    let employer = address("aleo1employerabc123");

    // Simulate repeated noncompliance
    employer_agreement::employer_status[employer] = false;

    // Ensure employer is ZPass verified
    employer_agreement::employer_zpass_verified[employer] = true;

    // Enforce penalties
    assert!(employer_agreement::enforce_penalties(employer) == true);

    // Verify employer status updated
    assert!(employer_agreement::employer_status[employer] == true);
}

test "Employer Requests Contract Termination & Fund Withdrawal (ZPass Required)" {
    let employer = address("aleo1employerabc123");

    // Ensure employer is ZPass verified
    employer_agreement::employer_zpass_verified[employer] = true;

    // Set employer to inactive
    employer_agreement::employer_status[employer] = false;

    // Request fund withdrawal
    assert!(employer_agreement::request_employer_withdrawal(employer) == true);

    // Verify balance is reset
    assert!(employer_agreement::employer_balances[employer] == 0);
}

test "Employer Closes Agreement with PNW (ZPass Required)" {
    let employer = address("aleo1employerabc123");

    // Ensure employer is ZPass verified
    employer_agreement::employer_zpass_verified[employer] = true;

    // Close employer contract
    assert!(employer_agreement::close_employer_contract(employer) == true);

    // Verify closure
    assert!(employer_agreement::employer_status[employer] == false);
}

test "ANS & ZPass Integration: Employer & Worker Mapping" {
    let employer = address("aleo1employerabc123");
    let worker = address("aleo1workerxyz456");
    let employer_ans = "organicfarm.pnw";
    let worker_ans = "johndoe.pncw";

    // Ensure employer and worker are ZPass verified
    employer_agreement::employer_zpass_verified[employer] = true;
    employer_agreement::worker_zpass_verified[worker] = true;

    // Register ANS for employer and worker
    employer_agreement::ans_registry[employer] = employer_ans;
    employer_agreement::ans_registry[worker] = worker_ans;

    employer_agreement::ans_reverse_lookup[employer_ans] = employer;
    employer_agreement::ans_reverse_lookup[worker_ans] = worker;

    // Verify ANS mapping
    assert!(employer_agreement::lookup_employer_by_ans(employer_ans) == employer);
    assert!(employer_agreement::lookup_worker_by_ans(worker_ans) == worker);
}
