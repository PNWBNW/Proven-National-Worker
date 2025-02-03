// SubDAO Management Smart Contract

// Struct to define a SubDAO
struct SubDAO {
    address subdao_address;          // The address of the SubDAO
    vector<address> worker_addresses;  // List of worker addresses in the SubDAO
    u64 total_investment;            // Total investment in farms by workers
    bool manage_farm_produce;        // Whether the SubDAO will manage farm produce/animals
}

// Initialize a new SubDAO
public fun init_subdao(subdao_address: address, worker_addresses: vector<address>): SubDAO {
    assert(worker_addresses.len() <= 5000, 101, "SubDAO member limit exceeded.");

    return SubDAO {
        subdao_address,
        worker_addresses,
        total_investment = 0,
        manage_farm_produce = false, // Default to farm management not allowed
    };
}

// Add a worker to the SubDAO
public fun add_worker_to_subdao(subdao: &mut SubDAO, worker_address: address) {
    assert(subdao.worker_addresses.len() < 5000, 102, "Cannot add more than 5000 workers to SubDAO.");
    subdao.worker_addresses.push(worker_address);
}

// Update total investment in farms by the SubDAO's workers
public fun update_total_investment(subdao: &mut SubDAO, investment_amount: u64) {
    subdao.total_investment = subdao.total_investment + investment_amount;
}

// Vote on whether the SubDAO should manage farm produce and animals
public fun vote_on_farm_management(subdao: &mut SubDAO, vote: bool) {
    // Only workers who have invested in the farm can vote
    let eligible_voters = subdao.worker_addresses.filter(|worker| has_invested_in_farm(worker));
    
    assert(eligible_voters.len() > 0, 103, "No eligible voters for this decision.");

    let votes_for_management = eligible_voters.filter(|worker| worker_votes_for(worker, vote)).len();
    let votes_needed = eligible_voters.len() / 2; // Majority needed

    if votes_for_management > votes_needed {
        subdao.manage_farm_produce = true;
    } else {
        subdao.manage_farm_produce = false;
    }
}

// Function to check if a worker has invested in a farm
public fun has_invested_in_farm(worker: address): bool {
    // Retrieve the worker's payroll details from the appropriate data store
    let payroll = get_payroll_details(worker);  // Assuming this function is defined elsewhere
    return payroll.farm_investment > 0;
}

// Function for workers to vote on the proposal
public fun worker_votes_for(worker: address, vote: bool): bool {
    // Retrieve the worker's vote from the appropriate data store
    let worker_vote = get_worker_vote(worker);  // Assuming this function is defined elsewhere
    return worker_vote == vote;
}
