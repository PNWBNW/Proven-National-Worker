// SPDX-License-Identifier: proprietary 
// Farm Investment contract for PNW Smart Contracts

// Import necessary dependencies
import 0xPNW::worker_identity;

// Struct for handling the investments in the farm by each worker
struct Investment {
    worker: address,   // Address of the worker who invested
    amount: u64,       // Amount the worker invested
}

// State to track investments in a particular farm (per SubDAO)
state farm_investments: map<u32, vector<Investment>>;  // Map of SubDAO ID to list of investments
state worker_investment: map<(u32, address), u64>;      // Map of SubDAO ID and worker address to amount invested

// Function to add investment to a farm for a specific SubDAO
public fun add_investment_to_farm(subdao_id: u32, worker: address, amount: u64) {
    // Check if the worker is an eligible agricultural worker
    if !worker_identity.is_agricultural_worker(worker) {
        error("Worker is not eligible to invest in the farm.");
    }

    // Track the investment for the worker in the SubDAO
    let current_investment = worker_investment.get((subdao_id, worker)).unwrap_or(0);
    let new_investment = current_investment + amount;
    worker_investment.insert((subdao_id, worker), new_investment);

    // Add the investment to the farm pool for the SubDAO
    let investment = Investment {
        worker: worker,
        amount: amount,
    };

    // Insert the investment into the farm investments state
    let mut investments = farm_investments.get(subdao_id).unwrap_or(vector<Investment>::empty());
    investments.push(investment);
    farm_investments.insert(subdao_id, investments);
}

// Function to remove investment from a farm for a specific SubDAO
public fun remove_investment_from_farm(subdao_id: u32, worker: address, amount: u64) {
    // Ensure the worker has made an investment
    let current_investment = worker_investment.get((subdao_id, worker)).unwrap_or(0);
    if current_investment < amount {
        error("Worker has insufficient investment to withdraw.");
    }

    // Update the worker's investment
    let new_investment = current_investment - amount;
    worker_investment.insert((subdao_id, worker), new_investment);

    // Remove the investment from the farm pool
    let mut investments = farm_investments.get(subdao_id).unwrap_or(vector<Investment>::empty());
    investments = investments.filter(|inv| inv.worker != worker || inv.amount != amount);  // Remove the specific investment

    farm_investments.insert(subdao_id, investments);
}

// Function to check if a worker has invested in a specific farm (SubDAO)
public fun has_investment_in_farm(subdao_id: u32, worker: address) -> bool {
    let current_investment = worker_investment.get((subdao_id, worker)).unwrap_or(0);
    return current_investment > 0;
}

// Function to get the total investment in a farm for a given SubDAO
public fun get_total_investment(subdao_id: u32) -> u64 {
    let investments = farm_investments.get(subdao_id).unwrap_or(vector<Investment>::empty());
    let total_investment = investments.fold(0, |acc, inv| acc + inv.amount);
    return total_investment;
}

// Function to get the investment history for a worker in a specific SubDAO
public fun get_investment_history(subdao_id: u32, worker: address) -> u64 {
    return worker_investment.get((subdao_id, worker)).unwrap_or(0);
}

// Function to get all investments in a specific farm (SubDAO)
public fun get_all_investments(subdao_id: u32) -> vector<Investment> {
    return farm_investments.get(subdao_id).unwrap_or(vector<Investment>::empty());
}

// Function to remove all investments for a specific SubDAO (in case of farm liquidation or other reasons)
public fun remove_all_investments(subdao_id: u32) {
    farm_investments.remove(subdao_id);
}

// Utility function to get all workers who have invested in a specific farm
public fun get_investors(subdao_id: u32) -> vector<address> {
    let investments = farm_investments.get(subdao_id).unwrap_or(vector<Investment>::empty());
    let investors = investments.fold(vector<address>::empty(), |acc, inv| acc.push(inv.worker));
    return investors;
}
