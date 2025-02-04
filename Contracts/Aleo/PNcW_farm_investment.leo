// pncw_farm_investment.leo

import 0x01::merkle_decision_maker;
import 0x01::payroll;
import 0x01::pncw_governance;

// Structure for tracking PNcW farm investments
struct FarmInvestment has store {
    investor_id: u64,
    amount: u64,
    investment_timestamp: u64,
    approved: bool,
}

// Mapping for storing PNcW farm investments
mapping pncw_farm_investments: u64 -> FarmInvestment;

// Function to add a new farm investment
public fun add_investment(investor_id: u64, amount: u64) -> bool {
    assert!(amount > 0, 0);

    let new_investment = FarmInvestment {
        investor_id: investor_id,
        amount: amount,
        investment_timestamp: timestamp(),
        approved: false,
    };

    pncw_farm_investments[investor_id] = new_investment;
    return true;
}

// Function to approve or reject a farm investment based on Merkle validation
public fun approve_investment(investor_id: u64) -> bool {
    let mut investment = pncw_farm_investments[investor_id];

    let valid = merkle_decision_maker::validate_investment(investor_id, investment.amount);
    if !valid {
        return false;
    }

    investment.approved = true;
    pncw_farm_investments[investor_id] = investment;
    return true;
}

// Function to process payouts for approved farm investments
public fun process_payout(investor_id: u64) -> bool {
    let investment = pncw_farm_investments[investor_id];
    assert!(investment.approved, 0); // Ensure investment is approved before payout

    let success = payroll::process_farm_payout(investor_id, investment.amount);
    return success;
}
