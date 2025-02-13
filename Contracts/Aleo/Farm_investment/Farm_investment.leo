program farm_investment.leo;

// 🏷️ Mappings
mapping worker_farm_investment: mapping(address, u64);  // Tracks each worker's farm investment amount
mapping worker_category: mapping(address, string);  // Worker category classification (from worker_identity)
mapping worker_verified: mapping(address, bool);  // Worker verification status (from worker_identity)
mapping worker_zpass_verified: mapping(address, bool); // Worker ZPass verification status (from worker_identity)
mapping employer_farm_limits: mapping(address, u64);  // Tracks employer-set farm investment limits
mapping farm_certifications: mapping(address, string);  // Tracks farm certifications (e.g., USDA Organic)
mapping farm_merkle_proof: mapping(address, u64);  // Stores Merkle proof for farm investment compliance
mapping worker_withdrawable_funds: mapping(address, u64); // Tracks available worker investment withdrawals
mapping worker_nft_holdings: mapping(address, u64); // Tracks NFT-minted farm investments for workers

// 🔹 New Fractional NFT Mappings
mapping worker_fractional_shares: mapping(address, u64);  // Tracks F-NFT shares per worker
mapping farm_total_shares: mapping(address, u64);  // Total available F-NFT shares per farm

// 🔹 New ANS Mappings
mapping ans_registry: mapping(address, string);  // Maps worker addresses to ANS names
mapping ans_reverse_lookup: mapping(string, address);  // Maps ANS names to worker addresses

constant AGRICULTURE_CATEGORY: string = "Agricultural"; // Required category for farm investments

// 📦 Structs
struct WorkerFarmInvestment {
    worker_address: address,
    investment_amount: u64,
    farm: address,
    employer: address,
    ans_name: string,  // New field for ANS
    fractional_shares: u64, // New field for fractional ownership
}

// ✅ Function: Allow workers to invest in a farm (Agricultural workers only)
function invest_in_farm(worker: address, farm: address, amount: u64) {
    ensure!(worker_verified[worker] == true, "Worker must be verified");
    ensure!(worker_zpass_verified[worker] == true, "Worker must have ZPass verification");
    ensure!(worker_category[worker] == AGRICULTURE_CATEGORY, "Only Agricultural workers can invest in farms");
    ensure!(amount > 0, "Investment amount must be greater than zero");

    let employer = get_farm_employer(farm);
    let max_limit = employer_farm_limits[employer];

    ensure!(amount <= max_limit, "Investment exceeds employer-set limit");

    // Assign Fractional NFT shares (1 share per 1 unit of investment)
    worker_farm_investment[worker] += amount;
    worker_fractional_shares[worker] += amount;
    farm_total_shares[farm] += amount;
}

// ✅ Function: Allow workers to invest in a farm using ANS
function invest_in_farm_by_ans(worker_ans: string, farm: address, amount: u64) {
    let worker = lookup_worker_by_ans(worker_ans);
    invest_in_farm(worker, farm, amount);
}

// ✅ Function: Allow workers to withdraw their farm investments (fractional ownership applied)
function withdraw_farm_investment(worker: address, amount: u64) {
    let balance = worker_farm_investment[worker];
    ensure!(balance >= amount, "Insufficient investment balance");

    // Deduct Fractional NFT shares proportionally
    worker_farm_investment[worker] -= amount;
    worker_fractional_shares[worker] -= amount;
    farm_total_shares[get_farm_employer(worker)] -= amount;
    worker_withdrawable_funds[worker] += amount;
}

// ✅ Function: Allow workers to withdraw farm investments using ANS
function withdraw_farm_investment_by_ans(worker_ans: string, amount: u64) {
    let worker = lookup_worker_by_ans(worker_ans);
    withdraw_farm_investment(worker, amount);
}

// ✅ Function: Convert an investment into an RWA Fractional NFT (instead of withdrawal)
function convert_investment_to_fractional_nft(worker: address, farm: address, nft_id: u64, fraction: u64) {
    let balance = worker_farm_investment[worker];
    ensure!(balance >= fraction, "Insufficient investment balance to mint fractional NFT");

    worker_farm_investment[worker] -= fraction;
    worker_nft_holdings[worker] = nft_id;
    worker_fractional_shares[worker] -= fraction;

    // Calls `rwa_nft.aleo` to mint the fractional NFT
    call rwa_nft.aleo.mint_fractional_nft(farm, worker, nft_id, fraction);
}

// ✅ Function: Convert an investment into an RWA Fractional NFT using ANS
function convert_investment_to_fractional_nft_by_ans(worker_ans: string, farm: address, nft_id: u64, fraction: u64) {
    let worker = lookup_worker_by_ans(worker_ans);
    convert_investment_to_fractional_nft(worker, farm, nft_id, fraction);
}

// ✅ Function: Register a farm certification (e.g., USDA Organic)
function register_farm_certification(farm: address, certification: string) {
    farm_certifications[farm] = certification;
}

// ✅ Function: Verify farm investment compliance using Merkle proof
function verify_farm_merkle(farm: address, provided_merkle_root: u64) -> bool {
    let stored_root = farm_merkle_proof[farm];
    ensure!(stored_root == provided_merkle_root, "Farm Merkle proof does not match");
    return true;
}

// ✅ Function: Get a worker's current farm investment
function get_worker_farm_investment(worker: address) -> u64 {
    return worker_farm_investment[worker];
}

// ✅ Function: Get a worker's current farm investment using ANS
function get_worker_farm_investment_by_ans(worker_ans: string) -> u64 {
    let worker = lookup_worker_by_ans(worker_ans);
    return get_worker_farm_investment(worker);
}

// ✅ Function: Get an employer's farm investment limit
function get_employer_farm_limit(employer: address) -> u64 {
    return employer_farm_limits[employer];
}

// ✅ Function: Get a farm's certification
function get_farm_certification(farm: address) -> string {
    return farm_certifications[farm];
}

// ✅ Function: Retrieve the employer managing a given farm
function get_farm_employer(farm: address) -> address {
    return env::get_associated_employer(farm);
}

// ✅ Utility function: Lookup a worker's ANS name by address
function lookup_worker_by_address(worker: address) -> string {
    ensure!(ans_registry.contains(worker), "Worker does not have an ANS name");
    return ans_registry[worker];
}

// ✅ Utility function: Lookup a worker's address by ANS name
function lookup_worker_by_ans(ans_name: string) -> address {
    ensure!(ans_reverse_lookup.contains(ans_name), "ANS name not found");
    return ans_reverse_lookup[ans_name];
}
