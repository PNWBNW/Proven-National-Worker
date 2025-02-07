program farm_investment_governance.aleo;

/// **Mappings**
mapping dao_investment_votes: u8 => u64;  // Tracks total votes per investment option
mapping worker_vote_records: address => (u8, u64);  // Stores worker votes and investment amounts
mapping total_voted_investments: u8 => u64;  // Tracks total investments per option
mapping employer_unpaid_payroll: address => u64;  // Tracks unpaid payroll for employers

/// **Function: vote_investment_outcome**
/// - Workers vote on how their investments should be handled.
/// - Uses roll-up voting for efficiency.
/// - If employer has unpaid payroll, workers can claim product rights instead.
function vote_investment_outcome(employer: address, selected_option: u8, investment_amount: u64) -> bool {
    let worker: address = caller();

    // **Step 1: Validate Inputs**
    assert!(selected_option >= 1 && selected_option <= 4, "Invalid voting option.");

    // **Step 2: Check Employer Payroll Compliance**
    let unpaid_payroll = compliance_tracking::get_unpaid_payroll(employer);
    if unpaid_payroll > 0 {
        return claim_product_rights(worker, employer, unpaid_payroll);
    }

    // **Step 3: Enforce Compliance Before Voting**
    assert!(compliance_tracking::check_worker_investment_cap(employer, investment_amount), "Investment limit exceeded.");
    assert!(compliance_tracking::check_payroll_compliance(employer), "Employer has unpaid payroll obligations.");

    // **Step 4: Record Vote**
    worker_vote_records[worker] = (selected_option, investment_amount);
    dao_investment_votes[selected_option] += 1;
    total_voted_investments[selected_option] += investment_amount;

    return true;
}

/// **Function: claim_product_rights**
/// - Allows workers to claim products equal to unpaid payroll.
function claim_product_rights(worker: address, employer: address, unpaid_amount: u64) -> bool {
    let available_products: u64 = get_farm_product_value(employer);
    assert!(available_products >= unpaid_amount, "Insufficient product value to cover payroll debt.");

    allocate_product_rights(worker, employer, unpaid_amount);
    return true;
}

/// **Function: finalize_voting**
/// - Processes roll-up voting at the end of an investment cycle.
/// - Distributes investment returns proportionally based on votes.
function finalize_voting() -> bool {
    let total_votes: u64 = dao_investment_votes[1] + dao_investment_votes[2] + dao_investment_votes[3] + dao_investment_votes[4];
    assert!(total_votes > 0, "No votes to finalize.");

    for option_id in [1, 2, 3, 4] {
        let total_amount = total_voted_investments[option_id];
        
        if total_amount > 0 {
            distribute_voted_payouts(option_id, total_amount);
        }
    }

    reset_voting_data();
    
    return true;
}

/// **Helper Function: distribute_voted_payouts**
/// - Allocates investment returns based on worker votes.
/// - Ensures workers receive their proportional share.
function distribute_voted_payouts(option_id: u8, total_amount: u64) -> bool {
    for (worker, (voted_option, amount)) in worker_vote_records {
        if voted_option == option_id {
            let proportional_share: u64 = (amount * total_amount) / total_voted_investments[option_id];
            process_voting_payout(worker, option_id, proportional_share);
        }
    }
    return true;
}

/// **Helper Function: process_voting_payout**
/// - Handles actual payout based on worker votes.
function process_voting_payout(worker: address, option_id: u8, amount: u64) -> bool {
    match option_id {
        1 => payout_usdc(worker, amount),  // Sell for USDC
        2 => reinvest(worker, amount),     // Reinvest
        3 => donate(worker, amount),       // Donate to community reserves
        4 => trade(worker, amount),        // Trade for other farm products
        _ => assert!(false, "Invalid payout option.")
    }

    return true;
}

/// **Helper Function: reset_voting_data**
/// - Clears voting records after an investment cycle.
function reset_voting_data() -> bool {
    for (worker, _) in worker_vote_records {
        delete worker_vote_records[worker];
    }

    for option_id in [1, 2, 3, 4] {
        dao_investment_votes[option_id] = 0;
        total_voted_investments[option_id] = 0;
    }

    return true;
}
