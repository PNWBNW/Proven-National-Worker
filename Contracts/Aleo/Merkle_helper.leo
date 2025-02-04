contract MerkleHelper {
    // Function to verify a Merkle proof and return the determined payout contract
    public fun verifyMerkleProof(root: field, leaf: field, proof: vector<field>) -> string {
        if (self.validateMerkleProof(root, leaf, proof)) {
            // Determine payout contract based on Merkle leaf data
            if (leaf == 0) {
                return "farm_investment";
            } else if (leaf == 1) {
                return "worker_identity";
            } else {
                return "undecided";
            }
        }
        return "invalid_proof";
    }

    // Internal function to validate the Merkle proof
    private fun validateMerkleProof(root: field, leaf: field, proof: vector<field>) -> bool {
        let mut computed_hash = leaf;

        for p in proof {
            if (computed_hash < p) {
                computed_hash = hash(computed_hash, p);
            } else {
                computed_hash = hash(p, computed_hash);
            }
        }

        return computed_hash == root;
    }

    // Hash function (example using Poseidon)
    private fun hash(a: field, b: field) -> field {
        return poseidon_hash([a, b]);
    }
}
