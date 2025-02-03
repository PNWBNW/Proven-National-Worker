// SPDX-License-Identifier: custom
// Farm Investment - farm_investment.leo

// Structure representing an individual investment in a farm
struct FarmInvestment {
    worker: address,          // Address of the worker who made the investment
    investment_amount: u64,   // Amount invested by the worker
}

// Mapping to track investments for each SubDAO
state farm_investments: map<u32, set<FarmInvestment>>;  // Mapping of SubDAO ID to set of investments

// Function to add a worker's investment to the farm pool for a given SubDAO
function add_investment_to_farm(subdao_id: u32, worker: address, amount: u64) {
    // Ensure worker is eligible for agricultural investment
    if !worker_identity.is_agricultural_worker(worker) {
        error("Worker is not eligible to invest in farm.");
    }

    // Retrieve current investments for this SubDAO
    let investments = farm_investments.get(subdao_id).unwrap_or_else(|| set<FarmInvestment>::new());

    // Create a new investment record
    let new_investment = FarmInvestment {
        worker: worker,
        investment_amount: amount,
    };

    // Add new investment to the set
    investments.add(new_investment);

    // Update the farm investments mapping
    farm_investments.insert(subdao_id, investments);

    // Mark the worker as having made an investment
    worker_identity.mark_investment(worker);
}

// Function to remove a worker's investment from the farm pool for a given SubDAO
function remove_investment_from_farm(subdao_id: u32, worker: address, amount: u64) {
    // Retrieve current investments for this SubDAO
    let investments = farm_investments.get(subdao_id).unwrap_or_else(|| set<FarmInvestment>::new());

    // Find the investment for this worker
    let investment = investments.iter().find(|&inv| inv.worker == worker);

    match investment {
        Some(inv) => {
            // Ensure the amount to be removed is valid
            if inv.investment_amount < amount {
                error("Amount to remove exceeds investment.");
            }

            // Update the investment amount for this worker
            let updated_investment = FarmInvestment {
                worker: inv.worker,
                investment_amount: inv.investment_amount - amount,
            };

            // Remove the old investment and add the updated one
            investments.remove(inv);
            investments.add(updated_investment);

            // Update the mapping with the new set of investments
            farm_investments.insert(subdao_id, investments);

            // If the investment amount becomes zero, remove the investment entirely
            if updated_investment.investment_amount == 0 {
                worker_identity.remove_investment(worker);
            }
        },
        None => error("No investment found for this worker."),
    }
}

// Function to get the total investment from all workers in a given SubDAO
function get_total_investment(subdao_id: u32) -> u64 {
    // Retrieve the investments for the SubDAO
    let investments = farm_investments.get(subdao_id).unwrap_or_else(|| set<FarmInvestment>::new());

    // Calculate the total investment by summing all investment amounts
    let total_investment = investments.fold(0, |accum, investment| accum + investment.investment_amount);

    return total_investment;
}

// Function to check if a worker has an active farm investment
function has_investment_in_farm(subdao_id: u32, worker: address) -> bool {
    // Retrieve the investments for the SubDAO
    let investments = farm_investments.get(subdao_id).unwrap_or_else(|| set<FarmInvestment>::new());

    // Check if the worker has any investment in the farm pool
    return investments.iter().any(|investment| investment.worker == worker);
}

// Function to get the list of workers who have invested in a particular SubDAO
function get_investment_list(subdao_id: u32) -> set<address> {
    // Retrieve the investments for the SubDAO
    let investments = farm_investments.get(subdao_id).unwrap_or_else(|| set<FarmInvestment>::new());

    // Return the list of worker addresses who have made investments
    return investments.iter().map(|investment| investment.worker).collect();
}
