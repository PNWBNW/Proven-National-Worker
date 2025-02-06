program pniw_trust_pool_test.aleo;

import pniw_trust_pool.aleo;

function test_trust_pool_contribution() -> bool {
    let worker_address = aleo1workerexample456;
    let contribution_amount = 10_000u64;

    let contribution_status = pniw_trust_pool::contribute_to_trust_pool(worker_address, contribution_amount);

    assert(contribution_status == true, "Trust pool contribution failed");
    return contribution_status;
}

function test_trust_pool_balance() -> bool {
    let worker_address = aleo1workerexample456;
    let balance = pniw_trust_pool::get_trust_pool_balance(worker_address);

    assert(balance > 0, "Trust pool balance retrieval failed");
    return true;
}

function test_child_fund_redemption() -> bool {
    let worker_address = aleo1workerexample456;
    let child_address = aleo1childexample456;
    let withdrawal_amount = 5_000u64;
    let kyc_verified = true;

    let redemption_status = pniw_trust_pool::redeem_funds(worker_address, child_address, withdrawal_amount, kyc_verified);

    assert(redemption_status == true, "Child fund redemption failed");
    return redemption_status;
}

function test_partial_withdrawal_approval() -> bool {
    let worker_address = aleo1workerexample456;
    let withdrawal_amount = 2_000u64;
    let approver1 = aleo1approverexample4;
    let approver2 = aleo1approverexample5;
    let approver3 = aleo1approverexample6;

    let approval_status = pniw_trust_pool::request_partial_withdrawal(worker_address, withdrawal_amount, approver1, approver2, approver3);

    assert(approval_status == true, "Partial withdrawal approval failed");
    return approval_status;
}
