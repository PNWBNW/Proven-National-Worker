program farm_investment.aleo;

/// **Struct: InvestmentRecord**
/// - Stores individual worker investment details.
struct InvestmentRecord {
    owner: address,
    amount: u64,
    selected_option: u8,  // 1 = Sell, 2 = Reinvest, 3 = Donate, 4 = Trade
    farm_type: u8         // Categorizes the investment
}

/// **Mappings**
mapping investment_ledger: address => InvestmentRecord;  // Tracks investments per worker
mapping total_option_votes: u8 => u64;  // Tracks votes per investment option
mapping total_investments: u8 => u64;  // Tracks total investment per option
mapping farm_type_totals: u8 => u64;  // Tracks total investment per farm type

/// **Function: register_investment**
/// - Allows a worker to register an investment.
/// - Enforces farm type, certification, and payroll compliance.
function register_investment(employer: address, amount: u64, selected_option: u8, farm_type: u8) -> bool {
    let worker: address = caller();

    // **Step 1: Validate Inputs**
    assert!(selected_option >= 1 && selected_option <= 4, "Invalid investment option.");
    assert!(farm_type >= 1 && farm_type <= 12, "Invalid farm type.");

    // **Step 2: Enforce Compliance Rules**
    assert!(compliance_tracking::verify_farm_type(employer, farm_type), "Farm type not allowed.");
    assert!(compliance_tracking::check_worker_investment_cap(employer, amount), "Investment limit exceeded.");
    assert!(compliance_tracking::check_payroll_compliance(employer), "Employer has unpaid payroll obligations.");

    // **Step 3: Log Investment**
    let record = InvestmentRecord { owner: worker, amount, selected_option, farm_type };
    investment_ledger[worker] = record;

    total_option_votes[selected_option] += 1;
    total_investments[selected_option] += amount;
    farm_type_totals[farm_type] += amount;

    // **Step 4: Record Worker Investment**
    assert!(compliance_tracking::record_worker_investment(employer, amount), "Investment tracking failed.");

    return true;
}

/// **Function: finalize_investments**
/// - Processes roll-up voting and distributes investments at harvest/work cycle completion.
function finalize_investments() -> bool {
    let total_votes: u64 = total_option_votes[1] + total_option_votes[2] + total_option_votes[3] + total_option_votes[4];
    assert!(total_votes > 0, "No investments to finalize.");

    for option_id in [1, 2, 3, 4] {
        let total_amount = total_investments[option_id];
        
        if total_amount > 0 {
            distribute_payouts(option_id, total_amount);
        }
    }

    reset_investments();
    
    return true;
}

/// **Helper Function: distribute_payouts**
/// - Distributes investment returns based on selected options and farm type.
function distribute_payouts(option_id: u8, total_amount: u64) -> bool {
    for (worker, record) in investment_ledger {
        if record.selected_option == option_id {
            let proportional_share: u64 = (record.amount * total_amount) / total_investments[option_id];
            process_payout(worker, option_id, record.farm_type, proportional_share);
        }
    }
    return true;
}

/// **Helper Function: process_payout**
/// - Handles the actual payout (sell, reinvest, donate, trade).
/// - Associates payouts with farm type for tracking.
function process_payout(worker: address, option_id: u8, farm_type: u8, amount: u64) -> bool {
    match option_id {
        1 => payout_usdc(worker, amount, farm_type),  // Sell for USDC
        2 => reinvest(worker, amount, farm_type),     // Reinvest
        3 => donate(worker, amount, farm_type),       // Donate to community reserves
        4 => trade(worker, amount, farm_type),        // Trade for other farm products
        _ => assert!(false, "Invalid payout option.")
    }

    return true;
}

/// **Helper Function: reset_investments**
/// - Clears investment records after a harvest cycle.
function reset_investments() -> bool {
    for (worker, _) in investment_ledger {
        delete investment_ledger[worker];
    }

    for option_id in [1, 2, 3, 4] {
        total_option_votes[option_id] = 0;
        total_investments[option_id] = 0;
    }

    for farm_type in [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12] {
        farm_type_totals[farm_type] = 0;
    }

    return true;
}
