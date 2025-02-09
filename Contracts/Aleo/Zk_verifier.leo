program zk_verifier.leo;

mapping worker_merkle_root: mapping(address, u64); // Stores Merkle root for each verified worker
mapping employer_merkle_root: mapping(address, u64); // Stores Merkle root for each verified employer
mapping farm_merkle_root: mapping(address, u64); // Stores Merkle root for each farm
mapping farm_rewards: mapping(address, u64); // Tracks farm rewards for audit participation
mapping farm_availability: mapping(address, bool); // Tracks whether a farm's data stack is online

constant FARM_REWARD_PERCENTAGE: u64 = 25; // Farms receive 25% of network fees when used for an audit

// Struct for zero-knowledge verification records
struct ZKVerification {
    entity_address: address,
    merkle_root: u64,
    zk_proof: u64,
}

// Function to register a farm's Merkle root
function register_farm_merkle(farm: address, merkle_root: u64) {
    ensure!(farm_merkle_root[farm] == 0, "Farm Merkle root already exists");
    farm_merkle_root[farm] = merkle_root;
    farm_availability[farm] = true;
}

// Function to verify farm Merkle proof, using fallback logic
function verify_farm_merkle(farm: address, provided_merkle_root: u64) -> bool {
    if farm_availability[farm] == true {
        let stored_root = farm_merkle_root[farm];
        ensure!(stored_root == provided_merkle_root, "Farm Merkle proof does not match");
        distribute_farm_reward(farm);
        return true;
    } else {
        let fallback_farm = find_closest_available_farm(farm);
        ensure!(fallback_farm != address(0), "No available fallback farm found");

        let fallback_root = farm_merkle_root[fallback_farm];
        ensure!(fallback_root == provided_merkle_root, "Fallback farm Merkle proof does not match");

        distribute_farm_reward(fallback_farm);
        return true;
    }
}

// Function to find the next closest available farm when a primary farm is offline
function find_closest_available_farm(original_farm: address) -> address {
    for (farm in farm_merkle_root) {
        if farm_availability[farm] == true {
            return farm;
        }
    }
    return address(0); // No available fallback found
}

// Function to distribute audit rewards to the farm used in verification
function distribute_farm_reward(farm: address) {
    let reward = get_network_fee() * FARM_REWARD_PERCENTAGE / 100;
    farm_rewards[farm] += reward;
}

// Function to get the current network fee
function get_network_fee() -> u64 {
    return env::network_fee();
}

// Utility function to check if a farm is online
function is_farm_online(farm: address) -> bool {
    return farm_availability[farm];
}

// Function to manually update farm availability status (in case of downtime reports)
function update_farm_availability(farm: address, status: bool) {
    farm_availability[farm] = status;
}
