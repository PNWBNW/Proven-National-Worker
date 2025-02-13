import MerkleHelper;
import NetworkStatus;
import DateTime;

// 🏷️ Mappings
mapping ans_registry: mapping(address, string);  // Maps worker & employer addresses to ANS names
mapping ans_reverse_lookup: mapping(string, address);  // Maps ANS names to worker & employer addresses
mapping entity_zpass_verified: mapping(address, bool); // Entity ZPass verification status

contract MerkleDecisionMaker {
    // Root hash of the Merkle tree
    state merkle_root: field;
    state last_gas_fee: u64;
    state last_network_latency: u64;

    // ✅ Function: Determine which contract should process the payout
    public fun decidePayoutContract(proof: vector<field>, leaf: field) -> string {
        ensure!(self.isPayoutDay(), "Payouts are only allowed on the 1st of each month");

        // Step 1: Check Network Health
        if (!self.isNetworkHealthy()) {
            return "Network congestion detected: SubDAO vote required";
        }

        let contract_decision = MerkleHelper::verifyMerkleProof(self.merkle_root, leaf, proof);

        match contract_decision {
            "farm_investment" => return "farm_investment",
            "worker_identity" => return "worker_identity",
            _ => return "undecided",
        };
    }

    // ✅ Function: Determine payout contract using ANS
    public fun decidePayoutContractByAns(entity_ans: string, proof: vector<field>, leaf: field) -> string {
        let entity = lookup_entity_by_ans(entity_ans);
        return self.decidePayoutContract(proof, leaf);
    }

    // ✅ Function: Test network health before executing payouts
    private fun isNetworkHealthy() -> bool {
        let gas_fee = NetworkStatus::getGasFee();
        let latency = NetworkStatus::getLatency();

        self.last_gas_fee = gas_fee;
        self.last_network_latency = latency;

        // If gas fees exceed 2x the 30-day average or latency is high, trigger SubDAO vote
        return !(gas_fee > 2 * NetworkStatus::get30DayAvgGasFee() || latency > NetworkStatus::getHighLatencyThreshold());
    }

    // ✅ Function: Check if today is the 1st of the month
    private fun isPayoutDay() -> bool {
        let today = DateTime::getCurrentDate();
        return today.day == 1;
    }

    // ✅ Function: Update the Merkle root (only callable by authorized ZPass-verified entities)
    public fun updateMerkleRoot(new_root: field, entity: address) -> string {
        ensure!(entity_zpass_verified.get_or_use(entity, false), "Entity must be ZPass verified to update Merkle root");

        self.merkle_root = new_root;
        return "Merkle root updated successfully";
    }

    // ✅ Function: Update the Merkle root using ANS
    public fun updateMerkleRootByAns(new_root: field, entity_ans: string) -> string {
        let entity = lookup_entity_by_ans(entity_ans);
        return self.updateMerkleRoot(new_root, entity);
    }

    // ✅ Function: Retrieve the current Merkle root
    public fun getMerkleRoot() -> field {
        return self.merkle_root;
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
}
