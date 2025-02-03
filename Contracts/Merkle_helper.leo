// merkle_helper.leo
contract MerkleHelper {
    // Function to verify a Merkle proof
    public fun verify(proof: vector<field>, root: field) -> bool {
        // Start with the first leaf in the proof
        let mut computed_hash = proof[0];

        // Iterate through proof elements, hashing each level
        for i in 1..proof.len() {
            let sibling = proof[i];

            if (computed_hash < sibling) {
                computed_hash = hash(computed_hash, sibling);
            } else {
                computed_hash = hash(sibling, computed_hash);
            }
        }

        // Compare computed hash with stored root
        return computed_hash == root;
    }

    // Function to hash two fields together (Merkle hash function)
    private fun hash(left: field, right: field) -> field {
        return poseidon_hash([left, right]); // Using Poseidon hash function
    }

    // Function to compute a Merkle root from a set of data
    public fun computeMerkleRoot(leaves: vector<field>) -> field {
        let mut nodes = leaves;

        // Build the Merkle tree layer by layer
        while nodes.len() > 1 {
            let mut next_layer: vector<field> = [];

            for i in (0..nodes.len()).step_by(2) {
                if (i + 1 < nodes.len()) {
                    next_layer.push(hash(nodes[i], nodes[i + 1]));
                } else {
                    next_layer.push(nodes[i]); // Carry over the last node if odd number
                }
            }
            nodes = next_layer;
        }

        return nodes[0]; // Root of the Merkle tree
    }
}
