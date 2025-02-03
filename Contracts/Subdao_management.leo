// SPDX-License-Identifier: proprietary
// SubDAO Management contract for PNW Smart Contracts with Farm Investment and Voting Features

import 0x1::worker_identity; // Import worker_identity contract for managing worker roles

// Enum for farm management options
enum FarmManagement {
    ManagedByFarm,       // Farm manages the produce and marketplace
    ManagedByDAO,        // DAO manages produce and sets up marketplace
}

// Struct to represent a SubDAO
struct SubDAO {
    dao_address: address,
    worker_count: u64,
    agricultural_investment: u64,   // Total investment made by agricultural workers in the farm
    farm_management_option: FarmManagement, // Farm management decision by worker vote
    approved_farm_management: bool,  // Flag indicating if the farm management decision has been approved by vote
}

// State to store all SubDAOs by address
state subdaos: map<address, SubDAO>;

// State to store the voting power of each worker for a given SubDAO
state worker_votes: map<address, map<address, bool>>; // subdao_address -> worker_address -> vote

// Function to create a new SubDAO
public fun create_subdao(dao_address: address) {
    // Check if the SubDAO already exists
    if (subdaos.contains(dao_address)) {
        error("SubDAO already exists.");
    }

    // Initialize the new SubDAO with default values
    let new_subdao = SubDAO {
        dao_address: dao_address,
        worker_count: 0,
        agricultural_investment: 0,
        farm_management_option: FarmManagement::ManagedByFarm,
        approved_farm_management: false,
    };

    // Store the new SubDAO in state
    subdaos.insert(dao_address, new_subdao);
}

// Function to register a worker in a SubDAO
public fun register_worker_in_subdao(subdao_address: address, worker: address) {
    let mut subdao = subdaos.get(subdao_address).unwrap_or(error("SubDAO not found."));
    
    // Ensure worker is eligible to join the SubDAO (check if they are eligible for agriculture)
    if (!worker_identity.is_agricultural_worker(worker)) {
        error("Worker not eligible for agricultural investment.");
    }
    
    // Increment the worker count for the SubDAO
    subdao.worker_count = subdao.worker_count + 1;
    
    // Update the SubDAO record in state
    subdaos.insert(subdao_address, subdao);
}

// Function to allow agricultural workers to invest in the farm
public fun invest_in_farm(subdao_address: address, worker: address, amount: u64) {
    let mut subdao = subdaos.get(subdao_address).unwrap_or(error("SubDAO not found."));
    
    // Check if worker is registered in the SubDAO and eligible for investment
    if (!worker_identity.is_agricultural_worker(worker)) {
        error("Worker is not eligible for investment.");
    }

    // Add the investment to the SubDAO's total agricultural investment
    subdao.agricultural_investment = subdao.agricultural_investment + amount;
    
    // Update the SubDAO record in state
    subdaos.insert(subdao_address, subdao);

    // Update the worker's investment balance in the farm
    worker_identity.add_agricultural_investment(worker, amount);
}

// Function to remove agricultural investment from the farm
public fun withdraw_investment_from_farm(subdao_address: address, worker: address, amount: u64) {
    let mut subdao = subdaos.get(subdao_address).unwrap_or(error("SubDAO not found."));
    
    // Check if worker is registered in the SubDAO and eligible for investment
    if (!worker_identity.is_agricultural_worker(worker)) {
        error("Worker is not eligible for investment.");
    }
    
    // Check if the worker has sufficient funds
    if (worker_identity.get_agricultural_investment_balance(worker) < amount) {
        error("Insufficient investment balance.");
    }

    // Deduct the investment from the SubDAO's total agricultural investment
    subdao.agricultural_investment = subdao.agricultural_investment - amount;

    // Update the SubDAO record in state
    subdaos.insert(subdao_address, subdao);

    // Remove the investment from the worker’s balance
    worker_identity.remove_agricultural_investment(worker, amount);
}

// Function for workers to vote on farm management decision (ManagedByFarm or ManagedByDAO)
public fun vote_on_farm_management(subdao_address: address, worker: address, vote: bool) {
    let mut subdao = subdaos.get(subdao_address).unwrap_or(error("SubDAO not found."));
    
    // Ensure the worker is registered in the SubDAO and eligible to vote
    if (!worker_identity.is_agricultural_worker(worker)) {
        error("Worker is not eligible to vote.");
    }

    // Record the worker's vote for the farm management decision
    worker_votes.get_mut(subdao_address).unwrap_or_else(|_| error("Worker votes not found."))
        .insert(worker, vote);

    // Check if all workers have voted
    let all_workers_voted = subdao.worker_count == worker_votes.get(subdao_address).unwrap_or_default().len() as u64;
    if (all_workers_voted) {
        // Determine the result of the vote: majority rules
        let majority_vote = worker_votes.get(subdao_address)
            .unwrap_or(error("Worker votes not found."))
            .values()
            .fold(0, |acc, vote| if (vote) { acc + 1 } else { acc });
        
        // Update the farm management option based on the vote
        if (majority_vote * 2 > subdao.worker_count) {
            subdao.farm_management_option = FarmManagement::ManagedByDAO;
        }
        
        // Mark the vote as complete
        subdao.approved_farm_management = true;
        
        // Clear the votes for the next round
        worker_votes.remove(subdao_address);
        
        // Update the SubDAO record in state
        subdaos.insert(subdao_address, subdao);
    }
}

// Function to get the current farm management option for a SubDAO
public fun get_farm_management_option(subdao_address: address) -> FarmManagement {
    let subdao = subdaos.get(subdao_address).unwrap_or(error("SubDAO not found."));
    return subdao.farm_management_option;
}

// Function to get the total agricultural investment in a SubDAO
public fun get_agricultural_investment(subdao_address: address) -> u64 {
    let subdao = subdaos.get(subdao_address).unwrap_or(error("SubDAO not found."));
    return subdao.agricultural_investment;
}
