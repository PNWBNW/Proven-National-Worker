// SPDX-License-Identifier: proprietary 
// Main contract for PNW SubDAOs with Farm Investment logic

// Include required imports
import 0xPNW::worker_identity;
import 0xPNW::farm_investment;

// SubDAO structure to hold basic information about each SubDAO
struct SubDAO {
    id: u32,                  // Unique ID for the SubDAO
    name: string,             // Name of the SubDAO
    total_investment: u64,    // Total investment in the farm by workers of this SubDAO
    farm_control: bool,       // Whether the SubDAO manages its own produce and marketplace
    investment_pool: set<address>,  // Set of workers who have invested in the farm
}

// State to track SubDAOs
state subdaos: map<u32, SubDAO>;  // Map of SubDAO ID to SubDAO details
state next_subdao_id: u32 = 1;    // Automatically incrementing ID for new SubDAOs

// Function to create a new SubDAO
public function create_subdao(name: string) -> u32 {
    let id = next_subdao_id;
    next_subdao_id += 1;

    let new_subdao = SubDAO {
        id: id,
        name: name,
        total_investment: 0,
        farm_control: true,  // Default farm control to the SubDAO (initially)
        investment_pool: set<address>::new(),
    };

    subdaos.insert(id, new_subdao);
    return id;
}

// Function for workers to invest in a farm within a SubDAO
public function invest_in_farm(subdao_id: u32, amount: u64) {
    let worker = msg.sender;  // Get the worker's address from the transaction sender
    
    // Ensure that the worker is eligible for agricultural investment
    if !worker_identity.is_agricultural_worker(worker) {
        error("Worker is not eligible to invest in farm.");
    }

    // Add investment to the farm pool for the given SubDAO
    farm_investment.add_investment_to_farm(subdao_id, worker, amount);

    // Update the total investment for the SubDAO
    let subdao = subdaos.get(subdao_id).unwrap();
    let updated_subdao = SubDAO {
        id: subdao.id,
        name: subdao.name,
        total_investment: subdao.total_investment + amount,
        farm_control: subdao.farm_control,
        investment_pool: subdao.investment_pool.add(worker),
    };

    subdaos.insert(subdao_id, updated_subdao);
}

// Function to remove investment from farm pool
public function withdraw_investment_from_farm(subdao_id: u32, amount: u64) {
    let worker = msg.sender;  // Get the worker's address

    // Ensure that the worker has made an investment
    if !farm_investment.has_investment_in_farm(subdao_id, worker) {
        error("Worker has no investment to withdraw.");
    }

    // Remove the investment from the farm pool
    farm_investment.remove_investment_from_farm(subdao_id, worker, amount);

    // Update the total investment for the SubDAO
    let subdao = subdaos.get(subdao_id).unwrap();
    let updated_subdao = SubDAO {
        id: subdao.id,
        name: subdao.name,
        total_investment: subdao.total_investment - amount,
        farm_control: subdao.farm_control,
        investment_pool: subdao.investment_pool.remove(worker),
    };

    subdaos.insert(subdao_id, updated_subdao);
}

// Function for workers to vote on the farm control option (SubDAO or external farm management)
public function vote_on_farm_control(subdao_id: u32, control_choice: bool) {
    let worker = msg.sender;  // Get the worker's address

    // Ensure the worker has invested in the farm before voting
    if !farm_investment.has_investment_in_farm(subdao_id, worker) {
        error("Worker must have invested in the farm to vote.");
    }

    // Update the SubDAO's control choice (either manage internally or let farm manage)
    let subdao = subdaos.get(subdao_id).unwrap();
    let updated_subdao = SubDAO {
        id: subdao.id,
        name: subdao.name,
        total_investment: subdao.total_investment,
        farm_control: control_choice,
        investment_pool: subdao.investment_pool,
    };

    subdaos.insert(subdao_id, updated_subdao);
}

// Function to view the total investment in a SubDAO's farm
public function get_total_investment(subdao_id: u32) -> u64 {
    let subdao = subdaos.get(subdao_id).unwrap();
    return subdao.total_investment;
}

// Function to check if a worker has voted on the farm control
public function has_voted_for_farm_control(subdao_id: u32, worker: address) -> bool {
    // We assume each worker votes once, and the vote is recorded with the SubDAO's farm control setting
    let subdao = subdaos.get(subdao_id).unwrap();
    return subdao.investment_pool.contains(worker);
}
