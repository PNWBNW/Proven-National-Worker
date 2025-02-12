program mining_governance.leo;

import compliance_tracking.leo;
import pncw_payroll.leo;
import pniw_payroll.leo;
import subdao_treasury.leo;
import oversight_dao.leo;

// 🏷️ Mappings
mapping farm_mining_contributions: public hashmap<address, u64>;  // Tracks mining power per farm
mapping farm_mining_proofs: public hashmap<address, u64>;         // Stores verified mining proofs
mapping mining_rewards_pool: public u64;                          // Total mining rewards available
mapping farm_mining_alerts: public hashmap<address, bool>;        // Alerts farms if mining speed is too low

// 🔹 Reward Distribution Percentages
const FARM_OWNER_SHARE: u64 = 40;
const WORKER_SHARE: u64 = 30;
const SUBDAO_SHARE: u64 = 20;
const OVERSIGHT_DAO_SHARE: u64 = 10;

/// @dev Submits mining contribution data for a farm
function submit_mining_contribution(farm: address, mining_power: u64) -> bool {
    ensure!(mining_power > 0, "Mining power must be greater than zero.");
    
    farm_mining_contributions.insert(farm, mining_power);
    compliance_tracking.update_mining_proof(farm, mining_power);

    return true;
}

/// @dev Verifies mining proof before rewards are distributed
function verify_mining_proof(farm: address) -> bool {
    let proof_exists = compliance_tracking.check_mining_compliance(farm);
    ensure!(proof_exists, "Mining proof verification failed.");

    farm_mining_proofs.insert(farm, farm_mining_contributions.get(farm).unwrap_or(0));
    return true;
}

/// @dev Distributes mining rewards based on verified contributions
function distribute_mining_rewards() -> bool {
    let total_mining_rewards = mining_rewards_pool;
    ensure!(total_mining_rewards > 0, "No mining rewards available.");

    for (farm, mining_power) in farm_mining_proofs.iter() {
        let farm_reward = (total_mining_rewards * FARM_OWNER_SHARE) / 100;
        let worker_reward = (total_mining_rewards * WORKER_SHARE) / 100;
        let subdao_reward = (total_mining_rewards * SUBDAO_SHARE) / 100;
        let oversight_reward = (total_mining_rewards * OVERSIGHT_DAO_SHARE) / 100;

        // ✅ Transfer rewards to workers
        pncw_payroll.distribute_mining_rewards(worker_reward);
        pniw_payroll.distribute_mining_rewards(worker_reward);

        // ✅ Allocate to governance
        subdao_treasury.deposit(subdao_reward);
        oversight_dao.deposit(oversight_reward);

        // ✅ Send farm owner rewards
        let success = transfer_to_farm(farm, farm_reward);
        ensure!(success, "Failed to transfer mining rewards to farm.");
    }

    // ✅ Reset mining rewards pool after distribution
    mining_rewards_pool = 0;
    return true;
}

/// @dev Monitors mining speed and alerts farms if they fall below threshold
function monitor_mining_performance(farm: address, network_average_speed: u64, threshold: u64) -> bool {
    let farm_speed = farm_mining_contributions.get(farm).unwrap_or(0);
    ensure!(network_average_speed > 0, "Invalid network average speed.");

    let min_required_speed = (network_average_speed * threshold) / 100;
    if farm_speed < min_required_speed {
        farm_mining_alerts.insert(farm, true);
    } else {
        farm_mining_alerts.insert(farm, false);
    }

    return true;
}

/// @dev Checks if a farm has received a mining speed alert
function check_mining_alert(farm: address) -> bool {
    return farm_mining_alerts.get(farm).unwrap_or(false);
}

/// @dev Utility function to update the mining rewards pool
function update_mining_rewards(amount: u64) {
    mining_rewards_pool += amount;
}

/// @dev Transfers rewards to farm owners
function transfer_to_farm(farm: address, amount: u64) -> bool {
    ensure!(amount > 0, "Invalid reward amount.");
    // Implement direct transfer logic here (e.g., Aleo USDC transfer)
    return true;
}
