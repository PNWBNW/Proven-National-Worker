import MerkleHelper;
import NetworkStatus;
import DateTime;

contract MerkleDecisionMaker {
    // Root hash of the Merkle tree
    state merkle_root: field;
    state last_gas_fee: u64;
    state last_network_latency: u64;

    // Function to determine which contract should process the payout
    public fun decidePayoutContract(proof: vector<field>, leaf: field) -> string {
        if (!self.isPayoutDay()) {
            return "Payouts are only allowed on the 1st of each month";
        }

        // Step 1: Check Network Health
        if (!self.isNetworkHealthy()) {
            return "Network congestion detected: SubDAO vote required";
        }

        let contract_decision = MerkleHelper::verifyMerkleProof(self.merkle_root, leaf, proof);

        if (contract_decision == "farm_investment") {
            return "farm_investment";
        } else if (contract_decision == "worker_identity") {
            return "worker_identity";
        } else {
            return "undecided";
        }
    }

    // Function to test network health before executing payouts
    private fun isNetworkHealthy() -> bool {
        let gas_fee = NetworkStatus::getGasFee();
        let latency = NetworkStatus::getLatency();

        self.last_gas_fee = gas_fee;
        self.last_network_latency = latency;

        // If gas fees exceed 2x the 30-day average or latency is high, trigger SubDAO vote
        return !(gas_fee > 2 * NetworkStatus::get30DayAvgGasFee() || latency > NetworkStatus::getHighLatencyThreshold());
    }

    // Function to check if today is the 1st of the month
    private fun isPayoutDay() -> bool {
        let today = DateTime::getCurrentDate();
        return today.day == 1;
    }

    // Function to update the Merkle root (only callable by authorized entities)
    public fun updateMerkleRoot(new_root: field) -> string {
        self.merkle_root = new_root;
        return "Merkle root updated successfully";
    }

    // Function to retrieve the current Merkle root
    public fun getMerkleRoot() -> field {
        return self.merkle_root;
    }
}
