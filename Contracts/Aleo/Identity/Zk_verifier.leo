program zk_verifier.leo;

// 🏷️ Mappings
mapping worker_merkle_root: mapping(address, u64); // Stores Merkle root for each verified worker
mapping employer_merkle_root: mapping(address, u64); // Stores Merkle root for each verified employer
mapping farm_merkle_root: mapping(address, u64); // Stores Merkle root for each farm
mapping farm_rewards: mapping(address, u64); // Tracks farm rewards for audit participation
mapping farm_availability: mapping(address, bool); // Tracks whether a farm's data stack is online
mapping worker_zpass_verified: mapping(address, bool); // Worker ZPass verification status

// 🔹 New ANS Mappings
mapping ans_registry: mapping(address, string);  // Maps worker & farm addresses to ANS names
mapping ans_reverse_lookup: mapping(string, address);  // Maps ANS names to worker & farm addresses

constant FARM_REWARD_PERCENTAGE: u64 = 25; // Farms receive 25% of network fees when used for an audit

// 📦 Structs
struct ZKVerification {
    entity_address: address,
    merkle_root: u64,
    zk_proof: u64,
}

// ✅ Function: Register a farm's Merkle root
function register_farm_merkle(farm: address, merkle_root: u64) {
    ensure!(worker_zpass_verified.get_or_use(farm, false), "Farm operator must be ZPass verified for Merkle registration");
    ensure!(farm_merkle_root[farm] == 0, "Farm Merkle root already exists");

    farm_merkle_root[farm] = merkle_root;
    farm_availability[farm] = true;
}

// ✅ Function: Register a farm's Merkle root using ANS
function register_farm_merkle_by_ans(farm_ans: string, merkle_root: u64) {
    let farm = lookup_entity_by_ans(farm_ans);
    register_farm_merkle(farm, merkle_root);
}

// ✅ Function: Verify farm Merkle proof, using fallback logic
function verify_farm_merkle(farm: address, provided_merkle_root: u64) -> bool {
    ensure!(worker_zpass_verified.get_or_use(farm, false), "Farm operator must be ZPass verified for Merkle verification");

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

// ✅ Function: Verify farm Merkle proof using ANS
function verify_farm_merkle_by_ans(farm_ans: string, provided_merkle_root: u64) -> bool {
    let farm = lookup_entity_by_ans(farm_ans);
    return verify_farm_merkle(farm, provided_merkle_root);
}

// ✅ Function: Find the next closest available farm when a primary farm is offline
function find_closest_available_farm(original_farm: address) -> address {
    for (farm in farm_merkle_root) {
        if farm_availability[farm] == true {
            return farm;
        }
    }
    return address(0); // No available fallback found
}

// ✅ Function: Distribute audit rewards to the farm used in verification
function distribute_farm_reward(farm: address) {
    let reward = get_network_fee() * FARM_REWARD_PERCENTAGE / 100;
    farm_rewards[farm] += reward;
}

// ✅ Function: Get the current network fee
function get_network_fee() -> u64 {
    return env::network_fee();
}

// ✅ Utility Function: Check if a farm is online
function is_farm_online(farm: address) -> bool {
    return farm_availability[farm];
}

// ✅ Function: Manually update farm availability status (in case of downtime reports)
function update_farm_availability(farm: address, status: bool) {
    ensure!(worker_zpass_verified.get_or_use(farm, false), "Farm operator must be ZPass verified to update status");
    farm_availability[farm] = status;
}

// ✅ Function: Manually update farm availability status using ANS
function update_farm_availability_by_ans(farm_ans: string, status: bool) {
    let farm = lookup_entity_by_ans(farm_ans);
    update_farm_availability(farm, status);
}

// ✅ Utility Function: Lookup an entity's ANS name by address
public fun lookup_entity_by_address(entity: address) -> string {
    ensure!(ans_registry.contains(entity), "Entity does not have an ANS name");
    return ans_registry[entity];
}

// ✅ Utility Function: Lookup an entity's address by ANS name
public fun lookup_entity_by_ans(ans_name: string) -> address {
    ensure!(ans_reverse_lookup.contains(ans_name), "ANS name not found");
    return ans_reverse_lookup[ans_name];
}
