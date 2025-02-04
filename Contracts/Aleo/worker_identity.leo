// worker_identity.leo
import 0x01::Merkle;  // Import Merkle module for Merkle tree operations

// Worker structure to store key information
struct Worker {
    id: u64,                   // Unique worker ID
    name: string,              // Name of the worker
    nationality: string,       // Worker nationality (e.g., "US", "DE", "CA")
    status: string,            // Worker status (e.g., "Citizen", "Immigrant")
    nft_type: string,          // NFT type: "PNcW" for Citizen, "PNiW" for Immigrant
    verification_hash: vector<u8>, // Hash of verification data for Merkle tree integration
}

// Merkle Tree root for verifying worker data integrity
struct MerkleRoot {
    root_hash: vector<u8>,  // Merkle root hash to verify against
}

// Define the Worker Identity Contract
public fun register_worker(
    worker_id: u64,
    worker_name: string,
    nationality: string,
    status: string,
    merkle_root: vector<u8>,
): Worker {
    let worker_nft_type = if (status == "Citizen") { 
        format!("{}-PNcW", nationality) 
    } else { 
        format!("{}-PNiW", nationality) 
    };
    
    let verification_hash = Merkle::compute_merkle_hash(merkle_root);
    
    // Register the worker
    Worker {
        id: worker_id,
        name: worker_name,
        nationality: nationality,
        status: status,
        nft_type: worker_nft_type,
        verification_hash: verification_hash,
    }
}

// Function to verify worker's Merkle root
public fun verify_worker(
    worker_id: u64,
    worker_nft_type: string,
    provided_root: vector<u8>,
): bool {
    // Check if the worker's provided Merkle root matches the registered root
    let registered_worker = get_worker(worker_id);
    let is_verified = Merkle::verify_merkle_root(provided_root, registered_worker.verification_hash);

    // Ensure the worker’s NFT type corresponds to their verification status
    return is_verified && registered_worker.nft_type == worker_nft_type;
}

// Helper function to retrieve a worker based on ID (using a simulated storage mechanism)
public fun get_worker(worker_id: u64): Worker {
    // This would interact with a storage system, like a global mapping of workers
    // For now, it returns a dummy worker to simulate the functionality
    Worker {
        id: worker_id,
        name: "Alice Doe",
        nationality: "US",
        status: "Citizen",
        nft_type: "US-PNcW",
        verification_hash: vec![],  // Dummy hash for example
    }
}
