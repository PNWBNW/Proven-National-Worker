// 📌 Worker Identity Test Suite

import worker_identity.leo;

test "Verify Worker Registration" {
    let worker = address("aleo1workerxyz123");

    // Ensure worker starts as unverified
    assert!(worker_identity::is_worker_verified(worker) == false);

    // Verify worker identity
    assert!(worker_identity::verify_worker(worker) == true);

    // Ensure worker is now verified
    assert!(worker_identity::is_worker_verified(worker) == true);
}

test "ZPass Verification Should be Permanent" {
    let worker = address("aleo1workerxyz123");

    // Ensure ZPass is not initially verified
    assert!(worker_identity::is_worker_zpass_verified(worker) == false);

    // Attempt to verify ZPass
    assert!(worker_identity::verify_worker_zpass(worker) == true);

    // Ensure ZPass verification is now true
    assert!(worker_identity::is_worker_zpass_verified(worker) == true);

    // Attempt to revoke ZPass (should fail)
    assert!(worker_identity::prevent_zpass_revoke(worker) == true);
}

test "Set and Retrieve Worker Category" {
    let worker = address("aleo1workerxyz123");

    // Assign worker category
    assert!(worker_identity::set_worker_category(worker, "Agricultural") == true);

    // Ensure category is stored correctly
    assert!(worker_identity::worker_category[worker] == "Agricultural");
}

test "Trust Fund Eligibility" {
    let worker = address("aleo1workerxyz123");

    // Worker must be verified and have ZPass to be eligible
    assert!(worker_identity::check_trust_fund_eligibility(worker) == false);

    // Enable trust fund eligibility
    assert!(worker_identity::enable_trust_fund(worker) == true);

    // Ensure worker is now eligible
    assert!(worker_identity::check_trust_fund_eligibility(worker) == true);

    // Disable trust fund eligibility (for compliance violations)
    assert!(worker_identity::disable_trust_fund(worker) == true);

    // Ensure worker is no longer eligible
    assert!(worker_identity::check_trust_fund_eligibility(worker) == false);
}

test "Register and Verify a Descendant" {
    let worker = address("aleo1workerxyz123");
    let child = address("aleo1childxyz456");

    // Register child as a descendant
    assert!(worker_identity::register_descendant(worker, child) == true);

    // Ensure child is mapped to the worker
    assert!(worker_identity::worker_descendants[child] == worker);

    // Ensure descendant is unverified initially
    assert!(worker_identity::descendant_verified[child] == false);

    // Verify descendant identity
    assert!(worker_identity::verify_descendant(child) == true);

    // Ensure descendant is now verified
    assert!(worker_identity::descendant_verified[child] == true);
}

test "Descendant Trust Fund Withdrawal Verification" {
    let worker = address("aleo1workerxyz123");
    let child = address("aleo1childxyz456");

    // Ensure unverified child cannot access funds
    assert!(worker_identity::check_descendant_trust_access(child) == false);

    // Verify child identity
    assert!(worker_identity::verify_descendant(child) == true);

    // Ensure verified descendant can access funds if parent is also verified
    assert!(worker_identity::check_descendant_trust_access(child) == true);
}

test "ANS Integration: Worker Registration and Lookup" {
    let worker = address("aleo1workerxyz123");
    let ans_name = "farmer.john";

    // Ensure worker has no ANS name initially
    assert!(worker_identity::lookup_worker_by_address(worker) == "");

    // Register worker with ANS name
    assert!(worker_identity::ans_registry[worker] = ans_name);
    assert!(worker_identity::ans_reverse_lookup[ans_name] = worker);

    // Verify ANS lookup works correctly
    assert!(worker_identity::lookup_worker_by_address(worker) == ans_name);
    assert!(worker_identity::lookup_worker_by_ans(ans_name) == worker);
}
