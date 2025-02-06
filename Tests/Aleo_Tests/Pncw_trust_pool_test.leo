program pncw_trust_pool_test.aleo;

import pncw_trust_pool.aleo;

function test_trust_pool_contribution() -> bool {
    let worker_address = aleo1workerexample123;
    let contribution_amount = 10_000u64;

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
