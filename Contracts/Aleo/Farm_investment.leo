program farm_investment.aleo;

mapping worker_farm_investment: mapping(address, u64);  // Tracks each worker's farm investment amount
mapping worker_category: mapping(address, string);  // Worker category classification (from worker_identity)
mapping worker_verified: mapping(address, bool);  // Worker verification status (from worker_identity)
mapping worker_zpass_verified: mapping(address, bool); // Worker ZPass verification status (from worker_identity)
mapping employer_farm_limits: mapping(address, u64);  // Tracks employer-set farm investment limits
mapping farm_certifications: mapping(address, string);  // Tracks farm certifications (e.g., USDA Organic)
mapping farm_merkle_proof: mapping(address, u64);  // Stores Merkle proof for farm investment compliance
mapping worker_withdrawable_funds: mapping(address, u64); // Tracks available worker investment withdrawals
mapping worker_nft_holdings: mapping(address, u64); // Tracks NFT-minted farm investments for workers

constant AGRICULTURE_CATEGORY: string = "Agricultural"; // Required category for farm investments

// Struct for tracking worker farm investments
struct WorkerFarmInvestment {
    worker_address: address,
    investment_amount: u64,
    farm: address,
    employer: address,
}

// Function to allow workers to invest in a farm (Agricultural workers only)
function invest_in_farm(worker: address, farm: address, amount: u64) {
    ensure!(worker_verified[worker] == true, "Worker must be verified");
    ensure!(worker_zpass_verified[worker] == true, "Worker must have ZPass verification");
    ensure!(worker_category[worker] == AGRICULTURE_CATEGORY, "Only Agricultural workers can invest in farms");
    ensure!(amount > 0, "Investment amount must be greater than zero");

    let employer = get_farm_employer(farm);
    let max_limit = employer_farm_limits[employer];

    ensure!(amount <= max_limit, "Investment exceeds employer-set limit");

    worker_farm_investment[worker] = amount;
}

// Function to allow workers to withdraw their farm investments (based on rules)
function withdraw_farm_investment(worker: address, amount: u64) {
    let balance = worker_farm_investment[worker];
    ensure!(balance >= amount, "Insufficient investment balance");

    worker_farm_investment[worker] -= amount;
    worker_withdrawable_funds[worker] += amount;
}

// Function to convert an investment into an RWA NFT instead of withdrawal
function convert_investment_to_nft(worker: address, farm: address, nft_id: u64) {
    let balance = worker_farm_investment[worker];
    ensure!(balance > 0, "No active investment to convert to NFT");

    worker_farm_investment[worker] = 0;
    worker_nft_holdings[worker] = nft_id;

    // Calls `rwa_nft.leo` to mint the NFT on behalf of the worker
    call rwa_nft.aleo.mint_rwa_nft(farm, worker, nft_id, "Farm Investment NFT");
}

// Function to register a farm certification (e.g., USDA Organic)
function register_farm_certification(farm: address, certification: string) {
    farm_certifications[farm] = certification;
}

// Function to verify farm investment compliance using Merkle proof
function verify_farm_merkle(farm: address, provided_merkle_root: u64) -> bool {
    let stored_root = farm_merkle_proof[farm];
    ensure!(stored_root == provided_merkle_root, "Farm Merkle proof does not match");
    return true;
}

// Function to get a worker's current farm investment
function get_worker_farm_investment(worker: address) -> u64 {
    return worker_farm_investment[worker];
}

// Function to get an employer's farm investment limit
function get_employer_farm_limit(employer: address) -> u64 {
    return employer_farm_limits[employer];
}

// Function to get a farm's certification
function get_farm_certification(farm: address) -> string {
    return farm_certifications[farm];
}

// Function to retrieve the employer managing a given farm
function get_farm_employer(farm: address) -> address {
    return env::get_associated_employer(farm);
}
