// pniw_farm_investment.leo

import 0x01::merkle_decision_maker;
import 0x01::payroll;
import 0x01::pniw_governance;

// Structure for tracking PNiW farm investments
struct PNiWFarmInvestment has store {
    investor_id: u64,
    amount: u64,
    investment_timestamp: u64,
    approved: bool,
}

// Mapping for storing PNiW farm investments
mapping pniw_farm_investments: u64 -> PNiWFarmInvestment;

// Function to add a new farm investment
public fun add_investment(investor_id: u64, amount: u64) -> bool {
    assert!(amount > 0, 0);

    let new_investment = PNiWFarmInvestment {
        investor_id: investor_id,
        amount: amount,
        investment_timestamp: timestamp(),
        approved: false,
    };

    pniw_farm_investments[investor_id] = new_investment;
    return true;
}

// Function to approve or reject a farm investment based on Merkle validation
public fun approve_investment(investor_id: u64) -> bool {
    let mut investment = pniw_farm_investments[investor_id];

    let valid = merkle_decision_maker::validate_investment(investor_id, investment.amount);
    if !valid {
        return false;
    }

    investment.approved = true;
    pniw_farm_investments[investor_id] = investment;
    return true;
}

// Function to process payouts for approved farm investments
public fun process_payout(investor_id: u64) -> bool {
    let investment = pniw_farm_investments[investor_id];
    assert!(investment.approved, 0); // Ensure investment is approved before payout

    let success = payroll::process_farm_payout(investor_id, investment.amount);
    return success;
}
