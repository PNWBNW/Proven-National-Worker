// SPDX-License-Identifier: proprietary
// Employer Agreement contract for PNW Smart Contracts (with SubDAO access to produce and animals management)

// Import relevant modules for SubDAO management and investment tracking
import 0x1::subdao_management;
import 0x1::worker_identity;
import 0x1::farm_investment;

// Enum for farm management preferences (farm or worker marketplace)
enum FarmManagementOption {
    FarmManaged,   // Farm manages the produce/animals and related processes
    WorkerManaged, // Workers manage the produce/animals and set up their own marketplace
}

// Struct to track employer agreement with farm management
struct EmployerAgreement {
    employer_address: address,
    subdao_address: address,
    produce_and_animals_management: FarmManagementOption, // Decision on who manages the produce and animals
    workers_investment: bool, // Whether the SubDAO has pooled investments into the farm
    workers_voting_rights: bool, // Whether the SubDAO can vote on the farm management decision
}

// State to store employer agreement data
state employer_agreements: map<address, EmployerAgreement>;

// Function to create a new employer agreement for farm management
public fun create_employer_agreement(employer_address: address, subdao_address: address, workers_investment: bool) {
    // Check if an agreement already exists for this employer
    if (employer_agreements.contains(employer_address)) {
        error("Employer agreement already exists.");
    }

    // Create the new employer agreement with default values
    let new_agreement = EmployerAgreement {
        employer_address: employer_address,
        subdao_address: subdao_address,
        produce_and_animals_management: FarmManagementOption::FarmManaged, // Default to farm-managed
        workers_investment: workers_investment,
        workers_voting_rights: workers_investment, // Workers have voting rights if they've pooled investments
    };

    // Store the new employer agreement in the state
    employer_agreements.insert(employer_address, new_agreement);
}

// Function to allow SubDAO to vote on whether the farm or the workers should manage produce and animals
public fun vote_on_management(employer_address: address, subdao_address: address, vote: FarmManagementOption) {
    let mut agreement = employer_agreements.get(employer_address).unwrap_or(error("Employer not found."));
    
    // Ensure only workers who have pooled investments are eligible to vote
    if (!agreement.workers_investment || agreement.subdao_address != subdao_address) {
        error("Only eligible workers (those who have invested) can vote.");
    }

    // Update the management decision based on the vote
    agreement.produce_and_animals_management = vote;

    // Update the agreement state
    employer_agreements.insert(employer_address, agreement);
}

// Function to get the current farm management option for an employer
public fun get_farm_management_option(employer_address: address) -> FarmManagementOption {
    let agreement = employer_agreements.get(employer_address).unwrap_or(error("Employer not found."));
    return agreement.produce_and_animals_management;
}

// Function to check if workers can vote on the management decision (based on investment)
public fun can_workers_vote_on_management(employer_address: address) -> bool {
    let agreement = employer_agreements.get(employer_address).unwrap_or(error("Employer not found."));
    return agreement.workers_voting_rights;
}

// Function to allow SubDAO to pool investment into the farm for produce and animals management
public fun invest_in_farm(employer_address: address, subdao_address: address) {
    let mut agreement = employer_agreements.get(employer_address).unwrap_or(error("Employer not found."));

    // Only allow SubDAO investment if it hasn't been made yet
    if (agreement.workers_investment) {
        error("SubDAO has already pooled investment into this farm.");
    }

    // Set the workers' investment flag to true
    agreement.workers_investment = true;
    agreement.workers_voting_rights = true; // Grant voting rights to the workers

    // Update the agreement state
    employer_agreements.insert(employer_address, agreement);
}

// Function to reset farm management option after workers vote to change it
public fun reset_farm_management(employer_address: address, subdao_address: address, new_option: FarmManagementOption) {
    let mut agreement = employer_agreements.get(employer_address).unwrap_or(error("Employer not found."));

    // Ensure only workers can reset the management option after voting
    if (agreement.subdao_address != subdao_address || !agreement.workers_voting_rights) {
        error("Only workers who have pooled investments can reset the management option.");
    }

    // Reset the farm management option
    agreement.produce_and_animals_management = new_option;

    // Update the agreement state
    employer_agreements.insert(employer_address, agreement);
}
