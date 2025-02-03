// subdao_management.leo
import 0x01 from "leo";

public struct SubDAO {
    // SubDAO ID to uniquely identify the subDAO
    subdao_id: address,
    
    // List of members in the SubDAO
    members: vector<address>,

    // Farm investments linked to the SubDAO
    farm_investments: vector<FarmInvestment>,

    // Voting threshold for farm management decisions
    management_vote_threshold: u64,

    // Vote results (0 - farm managed, 1 - worker managed)
    management_vote_result: u64
}

// Mapping for all SubDAOs
public var subdaos: map<address, SubDAO>;

// Function to create a SubDAO with the ability to invest in farms
public fund create_subdao(subdao_id: address, members: vector<address>, management_vote_threshold: u64) {
    let subdao = SubDAO {
        subdao_id: subdao_id,
        members: members,
        farm_investments: [],
        management_vote_threshold: management_vote_threshold,
        management_vote_result: 0, // Default value for no decision
    };
    
    // Store the SubDAO
    subdaos[subdao_id] = subdao;
}

// Function to allow a SubDAO to vote on farm management
public fund subdao_vote_on_farm_management(subdao_id: address, farm_id: address, vote: bool) {
    let subdao = subdaos[subdao_id];
    
    // Ensure the SubDAO has members and there are votes to count
    let total_members = subdao.members.length();
    if total_members == 0 {
        abort("SubDAO has no members");
    }

    // Count the total votes in favor of the farm management decision
    let mut total_votes = 0;

    // Loop through each member's investment to count votes
    for member in subdao.members {
        let investments = worker_investments[member];
        let investment = investments.filter(|i| i.farm_id == farm_id)[0];
        
        // Increment total votes if the worker has voted for farm management
        if investment.vote_for_farm_management {
            total_votes = total_votes + 1;
        }
    }

    // If the total votes exceed the management threshold, update the decision
    if total_votes > subdao.management_vote_threshold {
        // Farm will be managed by farm
        subdao.management_vote_result = 0;
    } else {
        // Worker managed
        subdao.management_vote_result = 1;
    }

    // Update the SubDAO record
    subdaos[subdao_id] = subdao;
}

// Function to check the current farm management vote result in a SubDAO
public public fun get_subdao_farm_management_result(subdao_id: address): u64 {
    let subdao = subdaos[subdao_id];
    subdao.management_vote_result
}
