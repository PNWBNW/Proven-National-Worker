// SPDX-License-Identifier: proprietary 
// Worker Identity contract for PNW Smart Contracts

// Enum for worker industry types
enum Industry {
    Agriculture,
    Technology,
    Manufacturing,
    Service,
    Other,
}

// Struct for storing worker details
struct Worker {
    worker_address: address,
    industry_type: Industry, // Worker industry type (Agriculture, Technology, etc.)
    is_agricultural_worker: bool, // Indicates whether the worker is eligible to invest in agriculture
    investment_balance: u64, // Worker balance of investments in the agriculture farm
}

// State to store workers' information (mapped by address)
state worker_identity: map<address, Worker>;

// Function to register a new worker with their industry and investment eligibility
public fun register_worker(worker: address, industry_type: Industry, is_agricultural_worker: bool) {
    // Check if the worker is already registered
    if (worker_identity.contains(worker)) {
        error("Worker already registered.");
    }

    // Create a new Worker struct with the provided details
    let new_worker = Worker {
        worker_address: worker,
        industry_type: industry_type,
        is_agricultural_worker: is_agricultural_worker,
        investment_balance: 0,  // Initial investment balance set to 0
    };

    // Register the new worker in the state
    worker_identity.insert(worker, new_worker);
}

// Function to update a worker's industry type
public fun update_worker_industry(worker: address, industry_type: Industry) {
    // Check if the worker is registered
    let current_worker = worker_identity.get(worker).unwrap_or(error("Worker not registered."));
    
    // Update the worker's industry type
    current_worker.industry_type = industry_type;
    
    // Update the worker record in state
    worker_identity.insert(worker, current_worker);
}

// Function to check if a worker is eligible to invest in agriculture (specifically for agricultural workers)
public fun is_agricultural_worker(worker: address) -> bool {
    let current_worker = worker_identity.get(worker).unwrap_or(error("Worker not registered."));
    return current_worker.is_agricultural_worker;
}

// Function to check if a worker belongs to a specific industry
public fun worker_industry(worker: address) -> Industry {
    let current_worker = worker_identity.get(worker).unwrap_or(error("Worker not registered."));
    return current_worker.industry_type;
}

// Function to add agricultural investment for a worker
public fun add_agricultural_investment(worker: address, amount: u64) {
    // Check if the worker is registered and is eligible to invest
    let mut current_worker = worker_identity.get(worker).unwrap_or(error("Worker not registered."));
    
    if !current_worker.is_agricultural_worker {
        error("Worker is not eligible to invest in agriculture.");
    }

    // Increase the worker's investment balance in agriculture
    current_worker.investment_balance = current_worker.investment_balance + amount;
    
    // Update the worker record in state
    worker_identity.insert(worker, current_worker);
}

// Function to remove agricultural investment for a worker
public fun remove_agricultural_investment(worker: address, amount: u64) {
    // Check if the worker is registered and has sufficient investment
    let mut current_worker = worker_identity.get(worker).unwrap_or(error("Worker not registered."));
    
    if !current_worker.is_agricultural_worker {
        error("Worker is not eligible to invest in agriculture.");
    }
    
    if current_worker.investment_balance < amount {
        error("Insufficient investment balance.");
    }

    // Decrease the worker's investment balance in agriculture
    current_worker.investment_balance = current_worker.investment_balance - amount;
    
    // Update the worker record in state
    worker_identity.insert(worker, current_worker);
}

// Function to check a worker's agricultural investment balance
public fun get_agricultural_investment_balance(worker: address) -> u64 {
    let current_worker = worker_identity.get(worker).unwrap_or(error("Worker not registered."));
    return current_worker.investment_balance;
}

// Function to get the total agricultural investment from all workers (for SubDAO or farm tracking purposes)
public fun get_total_agricultural_investment() -> u64 {
    let all_workers = worker_identity.values();
    let total_investment = all_workers.fold(0, |acc, worker| {
        if worker.is_agricultural_worker {
            acc + worker.investment_balance
        } else {
            acc
        }
    });
    return total_investment;
}

// Function to remove a worker from the system (in case of deactivation, etc.)
public fun remove_worker(worker: address) {
    worker_identity.remove(worker);
}
