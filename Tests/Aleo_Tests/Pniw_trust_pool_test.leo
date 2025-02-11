// 📌 PNiW Trust Fund Test Suite

import pniw_trust_pool.leo;

test "PNiW Worker Deposits into Trust Fund (ZPass Required)" {
    let worker = address("aleo1pniwworker789");
    let deposit_amount = 750;

    // Ensure worker is ZPass verified
    assert!(pniw_trust_pool::worker_zpass_verified[worker] == true);

    // Deposit funds
    assert!(pniw_trust_pool::deposit_trust_fund(worker, deposit_amount) == true);

    // Verify balance update
    assert!(pniw_trust_pool::get_worker_balance(worker) == deposit_amount);
}

test "PNiW Worker Withdraws Funds (ZPass & ANS Required, Monthly Limit Enforced)" {
    let worker = address("aleo1pniwworker789");
    let ans_name = "janedoe.pniw";
    let withdrawal_amount = 450;
    let current_time = 1700005000;

    // Ensure worker is ZPass verified
    assert!(pniw_trust_pool::worker_zpass_verified[worker] == true);

    // Assign ANS name to worker
    pniw_trust_pool::ans_registry[worker] = ans_name;
    pniw_trust_pool::ans_reverse_lookup[ans_name] = worker;

    // Withdraw funds
    assert!(pniw_trust_pool::withdraw_funds(worker, withdrawal_amount, current_time) == true);

    // Verify deduction
    assert!(pniw_trust_pool::get_worker_balance(worker) < 450);
}

test "PNiW Child Beneficiary Claims Funds (ZPass & ANS Required, Age 18+)" {
    let worker = address("aleo1pniwworker789");
    let child = address("aleo1pniwchild456");
    let ans_name = "childjanedoe.pniw";
    let age = 18;

    // Ensure worker and child are ZPass verified
    assert!(pniw_trust_pool::worker_zpass_verified[worker] == true);
    assert!(pniw_trust_pool::worker_zpass_verified[child] == true);

    // Assign ANS name to child
    pniw_trust_pool::ans_registry[child] = ans_name;
    pniw_trust_pool::ans_reverse_lookup[ans_name] = child;

    // Register child as beneficiary
    assert!(pniw_trust_pool::register_beneficiary(worker, child) == true);

    // Claim funds
    assert!(pniw_trust_pool::claim_funds_as_child(child, worker, age) == true);
}
