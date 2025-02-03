// farm_investment.leo
import 0x01 from "leo";

public struct FarmInvestment {
    // Worker ID
    worker_id: address,
    
    // Amount invested by the worker (in some unit)
    amount_invested: u64,

    // Whether the worker is voting to manage produce/animals or let the farm manage it
    vote_for_farm_management: bool,

    // The farm associated with this investment
    farm_id: address
}

// The Farm struct holds information about the farm and its workers.
public struct Farm {
    // Farm ID for identifying the farm
    farm_id: address,

    // The total funds pooled for the farm investment
    total_investment: u64,

    // The current status of farm management (e.g., "Farm managed", "Worker managed")
    farm_management_status: string,

    // List of workers investing in this farm
    workers_invested: vector<address>,

    // Total number of workers invested
    total_workers: u64
}

// Mapping for all workers and their farm investments
public var worker_investments: map<address, vector<FarmInvestment>>;

// Mapping for all farms
public var farms: map<address, Farm>;

// Function to allow workers to invest in a farm
public public fun invest_in_farm(worker: address, farm_id: address, amount: u64) {
    let farm = farms[farm_id];
    let investment = FarmInvestment {
        worker_id: worker,
        amount_invested: amount,
        vote_for_farm_management: false, // Default vote (can be updated by the worker later)
        farm_id: farm_id
    };

    // Add this investment to the worker's record
    worker_investments[worker] = worker_investments[worker] + [investment];

    // Update the farm's total investment
    farm.total_investment = farm.total_investment + amount;
    farm.workers_invested = farm.workers_invested + [worker];
    farm.total_workers = farm.total_workers + 1;
}

// Function for workers to vote on whether they want the farm to manage produce/animals
public public fun vote_on_farm_management(worker: address, farm_id: address, vote: bool) {
    let investments = worker_investments[worker];
    let investment = investments.filter(|i| i.farm_id == farm_id)[0];
    
    // Update the worker's vote for this specific farm
    investment.vote_for_farm_management = vote;

    // Update the worker's investments record
    worker_investments[worker] = investments;

    // Count the total votes for farm management (majority decision)
    let farm = farms[farm_id];
    let farm_management_votes = investments.filter(|i| i.farm_id == farm_id && i.vote_for_farm_management).length();
    let total_votes = farm.total_workers;

    // If majority of workers vote for farm management, update the status
    if farm_management_votes > total_votes / 2 {
        farm.farm_management_status = "Farm managed";
    } else {
        farm.farm_management_status = "Worker managed";
    }

    // Update the farm in the global map
    farms[farm_id] = farm;
}

// Function to check the investment status of a worker in a specific farm
public public fun get_investment_status(worker: address, farm_id: address): FarmInvestment {
    let investments = worker_investments[worker];
    investments.filter(|i| i.farm_id == farm_id)[0]
}
