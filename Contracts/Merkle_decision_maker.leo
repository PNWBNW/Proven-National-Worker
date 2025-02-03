import MerkleHelper;

contract MerkleDecisionMaker {
    // Root hash of the Merkle tree (should be set securely)
    state merkle_root: field;

    // Function to determine which contract should process the payout
    public fun decidePayoutContract(proof: vector<field>, leaf: field) -> string {
        let contract_decision = MerkleHelper::verifyMerkleProof(self.merkle_root, leaf, proof);

        if (contract_decision == "farm_investment") {
            return "farm_investment";
        } else if (contract_decision == "worker_identity") {
            return "worker_identity";
        } else {
            return "undecided";
        }
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
