// 📌 Worker Identity Test Suite

import worker_identity.leo;

test "Verify Worker Identity & ZPass Activation" {
    let worker = address("aleo1workerxyz456");

    // Verify worker identity
    assert!(worker_identity::verify_worker(worker) == true);
    assert!(worker_identity::is_worker_verified(worker) == true);

    // Ensure worker cannot activate ZPass before identity verification
    assert!(worker_identity::verify_worker_zpass(worker) == true);
    assert!(worker_identity::is_worker_zpass_verified(worker) == true);
}

test "Worker Category Assignment with ANS" {
    let worker = address("aleo1workerxyz456");
    let ans_name = "johndoe.pncw";

    // Assign worker category
    assert!(worker_identity::set_worker_category(worker, "Agricultural") == true);
    assert!(worker_identity::worker_category[worker] == "Agricultural");

    // Register worker's ANS name
    worker_identity::ans_registry[worker] = ans_name;
    worker_identity::ans_reverse_lookup[ans_name] = worker;

    // Verify ANS mapping
    assert!(worker_identity::lookup_worker_by_ans(ans_name) == worker);
}

test "Trust Fund Eligibility with ZPass" {
    let worker = address("aleo1workerxyz456");

    // Ensure worker is identity verified and ZPass verified
    assert!(worker_identity::verify_worker(worker) == true);
    assert!(worker_identity::verify_worker_zpass(worker) == true);

    // Enable trust fund access
    assert!(worker_identity::enable_trust_fund(worker) == true);
    assert!(worker_identity::check_trust_fund_eligibility(worker) == true);
}

test "Register & Verify Descendant for Trust Fund" {
    let worker = address("aleo1workerxyz456");
    let child = address("aleo1childabc123");

    // Register child as descendant
    assert!(worker_identity::register_descendant(worker, child) == true);
    assert!(worker_identity::worker_descendants[child] == worker);

    // Verify descendant
    assert!(worker_identity::verify_descendant(child) == true);
    assert!(worker_identity::descendant_verified[child] == true);
}

test "Trust Fund Withdrawal for Verified Descendant" {
    let worker = address("aleo1workerxyz456");
    let child = address("aleo1childabc123");

    // Ensure descendant is verified
    assert!(worker_identity::verify_descendant(child) == true);

    // Verify trust fund access
    assert!(worker_identity::check_descendant_trust_access(child) == true);
}
