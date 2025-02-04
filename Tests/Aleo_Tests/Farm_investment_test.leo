program farm_investment_test.aleo;

import farm_investment.aleo;

function test_farm_investment_submission() -> bool {
    let investor_address = aleo1investorexample123;
    let investment_amount = 50_000u64;

    let submission_status = farm_investment::submit_investment(investor_address, investment_amount);

    assert(submission_status == true, "Farm investment submission failed");
    return submission_status;
}

function test_farm_investment_approval() -> bool {
    let investor_address = aleo1investorexample123;
    let approval_status = farm_investment::approve_investment(investor_address);

    assert(approval_status == true, "Farm investment approval failed");
    return approval_status;
}

function test_farm_investment_payout() -> bool {
    let investor_address = aleo1investorexample123;
    let payout_status = farm_investment::process_payout(investor_address);

    assert(payout_status == true, "Farm investment payout failed");
    return payout_status;
}

function test_farm_investment_blacklist() -> bool {
    let investor_address = aleo1investorexample123;
    let blacklist_status = farm_investment::is_blacklisted(investor_address);

    assert(blacklist_status == false, "Investor should not be blacklisted");
    return blacklist_status;
}
