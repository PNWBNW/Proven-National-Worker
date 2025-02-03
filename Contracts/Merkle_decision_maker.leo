// merkle_decision_maker.leo
contract MerkleDecisionMaker {
    // Store the Merkle root that will be verified
    state merkle_root: field;

    // Function to store the Merkle root
    public fun storeMerkleRoot(root: field) {
        self.merkle_root = root;
    }

    // Function to receive Merkle proof and decide payout contract
    public fun decidePayoutContract(proof: vector<field>) -> string {
        // Verify the Merkle proof
        let is_valid_proof = verifyMerkleProof(self.merkle_root, proof);
        
        if (is_valid_proof == false) {
            return "Invalid Merkle Proof"; // Return error if proof is invalid
        }

        // Retrieve farm's data from the Merkle proof (using the indexes)
        let gas_price = getDataFromMerkleProof(proof, 0);
        let block_time = getDataFromMerkleProof(proof, 1);
        let farm_investment_success_rate = getDataFromMerkleProof(proof, 2);
        let worker_identity_success_rate = getDataFromMerkleProof(proof, 3);

        // Define thresholds for decision-making
        let gas_threshold = 10;  // Gwei
        let block_time_threshold = 300;  // milliseconds
        let success_rate_threshold = 0.95;  // 95%

        // Decision-making logic based on conditions
        if (gas_price < gas_threshold && block_time < block_time_threshold && farm_investment_success_rate >= success_rate_threshold) {
            return "farm_investment";
        } else if (worker_identity_success_rate >= success_rate_threshold) {
            return "worker_identity";
        } else {
            return "farm_investment"; // Default to farm_investment
        }
    }

    // Helper function to verify Merkle proof (this will interact with the MerkleHelper contract)
    private fun verifyMerkleProof(merkle_root: field, proof: vector<field>) -> bool {
        // Merkle proof verification logic here (interaction with MerkleHelper)
        return MerkleHelper::verify(proof, merkle_root);
    }

    // Helper function to retrieve data from the Merkle proof based on index
    private fun getDataFromMerkleProof(proof: vector<field>, index: int) -> field {
        // Retrieve specific data (gas_price, block_time, success rates) based on the proof index
        return proof[index];
    }
}
