// 📌 PNcW Trust Fund Test Suite

import pncw_trust_pool.leo;

test "PNcW Worker Deposits into Trust Fund (ZPass Required)" {
    let worker = address("aleo1pncwworker456");
    let deposit_amount = 500;

    // Ensure worker is ZPass verified
    assert!(pncw_trust_pool::worker_zpass_verified[worker] == true);

    // Deposit funds
    assert!(pncw_trust_pool::deposit_trust_fund(worker, deposit_amount) == true);

    // Verify balance update
    assert!(pncw_trust_pool::get_worker_balance(worker) == deposit_amount);
}

test "PNcW Worker Withdraws Funds (ZPass & ANS Required, Monthly Limit Enforced)" {
    let worker = address("aleo1pncwworker456");
    let ans_name = "janedoe.pncw";
    let withdrawal_amount = 300;
    let current_time = 1700000000;

    // Ensure worker is ZPass verified
    assert!(pncw_trust_pool::worker_zpass_verified[worker] == true);

    // Assign ANS name to worker
    pncw_trust_pool::ans_registry[worker] = ans_name;
    pncw_trust_pool::ans_reverse_lookup[ans_name] = worker;

    // Withdraw funds
    assert!(pncw_trust_pool::withdraw_funds(worker, withdrawal_amount, current_time) == true);

    // Verify deduction
    assert!(pncw_trust_pool::get_worker_balance(worker) < 300);
}

test "PNcW Child Beneficiary Claims Funds (ZPass & ANS Required, Age 18+)" {
    let worker = address("aleo1pncwworker456");
    let child = address("aleo1pncwchild123");
    let ans_name = "childjanedoe.pncw";
    let age = 18;

    // Ensure worker and child are ZPass verified
    assert!(pncw_trust_pool::worker_zpass_verified[worker] == true);
    assert!(pncw_trust_pool::worker_zpass_verified[child] == true);

    // Assign ANS name to child
    pncw_trust_pool::ans_registry[child] = ans_name;
    pncw_trust_pool::ans_reverse_lookup[ans_name] = child;

    // Register child as beneficiary
    assert!(pncw_trust_pool::register_beneficiary(worker, child) == true);

    // Claim funds
    assert!(pncw_trust_pool::claim_funds_as_child(child, worker, age) == true);
}ribution_amount = 10_000u64;

    let contribution_status = pncw_trust_pool::contribute_to_trust_pool(worker_address, contribution_amount);

    assert(contribution_status == true, "Trust pool contribution failed");
    return contribution_status;
}

function test_trust_pool_balance() -> bool {
    let worker_address = aleo1workerexample123;
    let balance = pncw_trust_pool::get_trust_pool_balance(worker_address);

    assert(balance > 0, "Trust pool balance retrieval failed");
    return true;
}

function test_child_fund_redemption() -> bool {
    let worker_address = aleo1workerexample123;
    let child_address = aleo1childexample123;
    let withdrawal_amount = 5_000u64;
    let kyc_verified = true;

    let redemption_status = pncw_trust_pool::redeem_funds(worker_address, child_address, withdrawal_amount, kyc_verified);

    assert(redemption_status == true, "Child fund redemption failed");
    return redemption_status;
}

function test_partial_withdrawal_approval() -> bool {
    let worker_address = aleo1workerexample123;
    let withdrawal_amount = 2_000u64;
    let approver1 = aleo1approverexample1;
    let approver2 = aleo1approverexample2;
    let approver3 = aleo1approverexample3;

    let approval_status = pncw_trust_pool::request_partial_withdrawal(worker_address, withdrawal_amount, approver1, approver2, approver3);

    assert(approval_status == true, "Partial withdrawal approval failed");
    return approval_status;
}
