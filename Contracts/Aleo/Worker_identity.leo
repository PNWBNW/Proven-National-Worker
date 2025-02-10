program worker_identity.leo;

// 🏷️ Mappings
mapping worker_category: mapping(address, string);  // Worker category classification
mapping worker_verified: mapping(address, bool);   // Worker identity verification status
mapping worker_kyc_timestamp: mapping(address, u64); // Optional KYC timestamp tracking
mapping worker_zpass_verified: mapping(address, bool); // ZPass verification status (permanent)
mapping trust_fund_eligibility: mapping(address, bool); // Worker trust fund eligibility
mapping worker_descendants: mapping(address, address); // Mapping of worker to child (descendant)
mapping descendant_verified: mapping(address, bool); // Verification of child’s KYC status

// 🔹 New ANS-Related Mappings
mapping ans_registry: mapping(address, string);  // Maps worker addresses to ANS names
mapping ans_reverse_lookup: mapping(string, address);  // Maps ANS names to worker addresses
mapping worker_kyc_verified: mapping(address, bool); // Tracks if KYC is verified for ANS

// 📦 Structs
struct WorkerIdentity {
    worker_address: address,
    category: string,
    verified: bool,
    zpass_verified: bool,
    kyc_timestamp: u64,
    ans_name: string,  // New field for ANS
}

// Struct for tracking descendant trust fund access
struct DescendantAccess {
    descendant_address: address,
    parent_worker: address,
    verified: bool,
}

// ✅ Function: Verify a worker’s identity
function verify_worker(worker: address) -> bool {
    ensure!(worker_verified[worker] == false, "Worker is already verified");
    worker_verified[worker] = true;
    worker_kyc_timestamp[worker] = get_current_time();
    return true;
}

// ✅ Function: Verify worker’s ZPass identity (permanent)
function verify_worker_zpass(worker: address) -> bool {
    ensure!(worker_verified[worker] == true, "Worker must be identity-verified before enabling ZPass");
    ensure!(worker_zpass_verified[worker] == false, "Worker is already ZPass verified");
    worker_zpass_verified[worker] = true;
    return true;
}

// ✅ Function: Register a worker’s ANS name (Requires ZPass Verification)
function register_worker_ans(worker: address, ans_name: string) -> bool {
    ensure!(worker_verified[worker] == true, "Worker must be verified before registering an ANS name");
    ensure!(worker_zpass_verified[worker] == true, "Worker must be ZPass verified for ANS registration");
    ensure!(!ans_reverse_lookup.contains(ans_name), "ANS name is already in use");

    ans_registry[worker] = ans_name;
    ans_reverse_lookup[ans_name] = worker;

    return true;
}

// ✅ Function: Update a worker’s ANS name (Requires Active ZPass Verification)
function update_worker_ans(worker: address, new_ans_name: string) -> bool {
    ensure!(worker_verified[worker] == true, "Worker must be verified before updating an ANS name");
    ensure!(worker_zpass_verified[worker] == true, "Worker must be ZPass verified for ANS updates");
    ensure!(!ans_reverse_lookup.contains(new_ans_name), "ANS name is already in use");

    let old_ans = ans_registry[worker];
    delete ans_reverse_lookup[old_ans]; // Remove old ANS reference

    ans_registry[worker] = new_ans_name;
    ans_reverse_lookup[new_ans_name] = worker;

    return true;
}

// ✅ Function: Lookup a worker’s ANS name by address
function lookup_worker_by_address(worker: address) -> string {
    ensure!(ans_registry.contains(worker), "Worker does not have an ANS name");
    return ans_registry[worker];
}

// ✅ Function: Lookup a worker’s address by ANS name
function lookup_worker_by_ans(ans_name: string) -> address {
    ensure!(ans_reverse_lookup.contains(ans_name), "ANS name not found");
    return ans_reverse_lookup[ans_name];
}

// ✅ Function: Prevent workers from revoking ZPass (unless DAOs override)
function prevent_zpass_revoke(worker: address) {
    ensure!(worker_zpass_verified[worker] == true, "Worker must have ZPass verification");
    env::emit("ZPass verification is permanent and cannot be revoked unless DAOs vote otherwise.");
}

// ✅ Function: Classify a worker into an industry category
function set_worker_category(worker: address, category: string) {
    ensure!(category == "General" || category == "Skilled" || category == "Agricultural" || category == "Healthcare",
            "Invalid category");

    worker_category[worker] = category;
}

// ✅ Function: Check if a worker is eligible for trust fund contributions
function check_trust_fund_eligibility(worker: address) -> bool {
    ensure!(worker_verified[worker] == true, "Worker must be verified for trust fund eligibility");
    ensure!(worker_zpass_verified[worker] == true, "Worker must have permanent ZPass verification for trust fund eligibility");
    return trust_fund_eligibility[worker];
}

// ✅ Function: Enable trust fund eligibility for verified ZPass workers
function enable_trust_fund(worker: address) {
    ensure!(worker_verified[worker] == true, "Worker must be verified for trust fund access");
    ensure!(worker_zpass_verified[worker] == true, "Worker must have permanent ZPass verification for trust fund access");
    trust_fund_eligibility[worker] = true;
}

// ✅ Function: Disable trust fund eligibility (for compliance violations)
function disable_trust_fund(worker: address) {
    trust_fund_eligibility[worker] = false;
}

// ✅ Function: Register a worker’s child (descendant)
function register_descendant(worker: address, child: address) {
    ensure!(worker_verified[worker] == true, "Parent worker must be verified");
    worker_descendants[child] = worker;
}

// ✅ Function: Verify a descendant’s identity (KYC proof)
function verify_descendant(child: address) -> bool {
    ensure!(worker_descendants[child] != address(0), "Child must be registered as a descendant of a worker");
    descendant_verified[child] = true;
    return true;
}

// ✅ Function: Check if a descendant is eligible to withdraw trust funds
function check_descendant_trust_access(child: address) -> bool {
    let parent_worker = worker_descendants[child];
    ensure!(descendant_verified[child] == true, "Descendant must have KYC verification");
    ensure!(parent_worker != address(0), "No registered parent worker found");
    ensure!(worker_zpass_verified[parent_worker] == true, "Parent worker must be ZPass verified for descendant trust access");
    return trust_fund_eligibility[parent_worker];
}

// ✅ Utility function: Check worker verification status
function is_worker_verified(worker: address) -> bool {
    return worker_verified[worker];
}

// ✅ Utility function: Check ZPass verification status (permanent)
function is_worker_zpass_verified(worker: address) -> bool {
    return worker_zpass_verified[worker];
}

// ✅ Utility function: Get the worker’s KYC timestamp
function get_worker_kyc_timestamp(worker: address) -> u64 {
    return worker_kyc_timestamp[worker];
}

// ✅ Utility function: Get the current timestamp
function get_current_time() -> u64 {
    return env::block_timestamp();
}
