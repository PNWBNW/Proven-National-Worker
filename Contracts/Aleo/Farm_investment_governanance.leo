program farm_investment_governance.aleo;

// 🏷️ Mappings
mapping worker_investment_choices: mapping(address, string);  // Tracks each worker's investment decision
mapping farm_voting_power: mapping(address, u64);  // Tracks voting power for each farm
mapping farm_governance_policies: mapping(address, string);  // Stores governance rules for each farm
mapping worker_investment_rights: mapping(address, bool);  // Determines if workers can control their investments
mapping farm_nft_minting_rights: mapping(address, bool);  // Determines if a farm can mint RWA NFTs
mapping farm_resale_policies: mapping(address, bool);  // Determines if RWA NFTs can be resold by bulk buyers
mapping worker_fractional_shares: mapping(address, u64);  // Tracks F-NFT shares per worker
mapping farm_total_shares: mapping(address, u64);  // Tracks total F-NFT shares per farm

// 🔹 New ANS Mappings
mapping ans_registry: mapping(address, string);  // Maps worker addresses to ANS names
mapping ans_reverse_lookup: mapping(string, address);  // Maps ANS names to worker addresses

constant DEFAULT_GOVERNANCE_POLICY: string = "Direct Farm-to-Table"; // Default governance policy

// Fixed options for worker investment management
constant OPTION_SELL: string = "Sell for USDC";
constant OPTION_REINVEST: string = "Reinvest in next harvest";
constant OPTION_DONATE: string = "Donate to community reserves";
constant OPTION_TRADE: string = "Trade for other farm products";

// 📦 Structs
struct FarmGovernance {
    farm_address: address,
    voting_power: u64,
    governance_policy: string,
}

// ✅ Function: Assign governance policies to farms
function set_farm_governance_policy(farm: address, policy: string) {
    farm_governance_policies[farm] = policy;
}

// ✅ Function: Enable worker investment control for a farm
function enable_worker_investment_control(farm: address) {
    worker_investment_rights[farm] = true;
}

// ✅ Function: Disable worker investment control for a farm
function disable_worker_investment_control(farm: address) {
    worker_investment_rights[farm] = false;
}

// ✅ Function: Allow a farm to mint RWA NFTs
function allow_farm_nft_minting(farm: address) {
    farm_nft_minting_rights[farm] = true;
}

// ✅ Function: Prevent a farm from minting RWA NFTs
function revoke_farm_nft_minting(farm: address) {
    farm_nft_minting_rights[farm] = false;
}

// ✅ Function: Enable or disable bulk buyer resale rights (default: disabled)
function set_farm_resale_policy(farm: address, allow_resale: bool) {
    farm_resale_policies[farm] = allow_resale;
}

// ✅ Function: Worker selects their own investment choice (Supports ANS)
function select_investment_choice(worker: address, farm: address, choice: string) {
    ensure!(worker_investment_rights[farm] == true, "Worker investment control is not enabled for this farm");
    ensure!(
        choice == OPTION_SELL || choice == OPTION_REINVEST || choice == OPTION_DONATE || choice == OPTION_TRADE,
        "Invalid investment choice"
    );

    worker_investment_choices[worker] = choice;
}

// ✅ Function: Worker selects their investment choice using ANS
function select_investment_choice_by_ans(worker_ans: string, farm: address, choice: string) {
    let worker = lookup_worker_by_ans(worker_ans);
    select_investment_choice(worker, farm, choice);
}

// ✅ Function: Process a worker's individual investment decision
function process_worker_investment(worker: address, farm: address) -> string {
    let choice = worker_investment_choices[worker];
    ensure!(choice != "", "No investment choice has been made");

    return choice;
}

// ✅ Function: Process a worker's investment decision using ANS
function process_worker_investment_by_ans(worker_ans: string, farm: address) -> string {
    let worker = lookup_worker_by_ans(worker_ans);
    return process_worker_investment(worker, farm);
}

// ✅ Function: Calculate a worker's voting power based on fractional NFT shares
function calculate_voting_power(worker: address, farm: address) -> u64 {
    let total_shares = farm_total_shares[farm];
    let worker_shares = worker_fractional_shares[worker];

    if total_shares == 0 {
        return 0; // Avoid division by zero
    }

    return (worker_shares * 100) / total_shares; // Voting power is proportional to fractional shares
}

// ✅ Function: Calculate a worker's voting power using ANS
function calculate_voting_power_by_ans(worker_ans: string, farm: address) -> u64 {
    let worker = lookup_worker_by_ans(worker_ans);
    return calculate_voting_power(worker, farm);
}

// ✅ Function: Check if a farm has worker investment control enabled
function is_worker_investment_control_enabled(farm: address) -> bool {
    return worker_investment_rights[farm];
}

// ✅ Function: Check if a farm is authorized to mint RWA NFTs
function is_farm_nft_minting_allowed(farm: address) -> bool {
    return farm_nft_minting_rights[farm];
}

// ✅ Function: Check if a farm allows resale by bulk buyers
function is_farm_resale_allowed(farm: address) -> bool {
    return farm_resale_policies[farm];
}

// ✅ Function: Get a farm’s governance policy
function get_farm_governance_policy(farm: address) -> string {
    return farm_governance_policies[farm];
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
