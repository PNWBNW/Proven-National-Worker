program worker_identity.leo;

mapping worker_category: mapping(address, string);  // Worker category classification
mapping worker_verified: mapping(address, bool);   // Worker identity verification status
mapping worker_kyc_timestamp: mapping(address, u64); // Optional KYC timestamp tracking
mapping worker_zpass_verified: mapping(address, bool); // ZPass verification status (permanent)
mapping trust_fund_eligibility: mapping(address, bool); // Worker trust fund eligibility
mapping worker_descendants: mapping(address, address); // Mapping of worker to child (descendant)
mapping descendant_verified: mapping(address, bool); // Verification of child’s KYC status

// Struct for tracking worker identity details
struct WorkerIdentity {
    worker_address: address,
    category: string,
    verified: bool,
    zpass_verified: bool,
    kyc_timestamp: u64,
}

// Struct for tracking descendant trust fund access
struct DescendantAccess {
    descendant_address: address,
    parent_worker: address,
    verified: bool,
}

// Function to verify a worker's identity
function verify_worker(worker: address) -> bool {
    ensure!(worker_verified[worker] == false, "Worker is already verified");
    worker_verified[worker] = true;
    worker_kyc_timestamp[worker] = get_current_time();
    return true;
}

// Function to verify worker's ZPass identity (permanent)
function verify_worker_zpass(worker: address) -> bool {
    ensure!(worker_verified[worker] == true, "Worker must be identity-verified before enabling ZPass");
    ensure!(worker_zpass_verified[worker] == false, "Worker is already ZPass verified");
    worker_zpass_verified[worker] = true;
    return true;
}

// Function to classify a worker into an industry category
function set_worker_category(worker: address, category: string) {
    ensure!(category == "General" || category == "Skilled" || category == "Agricultural" || category == "Healthcare",
            "Invalid category");

    worker_category[worker] = category;
}

// Function to check if a worker is eligible for trust fund contributions
function check_trust_fund_eligibility(worker: address) -> bool {
    ensure!(worker_verified[worker] == true, "Worker must be verified for trust fund eligibility");
    ensure!(worker_zpass_verified[worker] == true, "Worker must have permanent ZPass verification for trust fund eligibility");
    return trust_fund_eligibility[worker];
}

// Function to enable trust fund eligibility for verified ZPass workers
function enable_trust_fund(worker: address) {
    ensure!(worker_verified[worker] == true, "Worker must be verified for trust fund access");
    ensure!(worker_zpass_verified[worker] == true, "Worker must have permanent ZPass verification for trust fund access");
    trust_fund_eligibility[worker] = true;
}

// Function to disable trust fund eligibility (for compliance violations)
function disable_trust_fund(worker: address) {
    trust_fund_eligibility[worker] = false;
}

// Function to register a worker's child (descendant)
function register_descendant(worker: address, child: address) {
    ensure!(worker_verified[worker] == true, "Parent worker must be verified");
    worker_descendants[child] = worker;
}

// Function to verify a descendant’s identity (KYC proof)
function verify_descendant(child: address) -> bool {
    ensure!(worker_descendants[child] != address(0), "Child must be registered as a descendant of a worker");
    descendant_verified[child] = true;
    return true;
}

// Function to check if a descendant is eligible to withdraw trust funds
function check_descendant_trust_access(child: address) -> bool {
    let parent_worker = worker_descendants[child];
    ensure!(descendant_verified[child] == true, "Descendant must have KYC verification");
    ensure!(parent_worker != address(0), "No registered parent worker found");
    ensure!(worker_zpass_verified[parent_worker] == true, "Parent worker must be ZPass verified for descendant trust access");
    return trust_fund_eligibility[parent_worker];
}

// Utility function to check worker verification status
function is_worker_verified(worker: address) -> bool {
    return worker_verified[worker];
}

// Utility function to check ZPass verification status (permanent)
function is_worker_zpass_verified(worker: address) -> bool {
    return worker_zpass_verified[worker];
}

// Function to prevent workers from revoking ZPass (unless DAOs override)
function prevent_zpass_revoke(worker: address) {
    ensure!(worker_zpass_verified[worker] == true, "Worker must have ZPass verification");
    env::emit("ZPass verification is permanent and cannot be revoked unless DAOs vote otherwise.");
}

// Utility function to get the worker's KYC timestamp
function get_worker_kyc_timestamp(worker: address) -> u64 {
    return worker_kyc_timestamp[worker];
}

// Utility function to get the current timestamp
function get_current_time() -> u64 {
    return env::block_timestamp();
}
