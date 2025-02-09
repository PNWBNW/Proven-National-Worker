program farm_investment_governance.leo;

mapping worker_investment_choices: mapping(address, string);  // Tracks each worker's investment decision
mapping farm_voting_power: mapping(address, u64);  // Tracks voting power for each farm
mapping farm_governance_policies: mapping(address, string);  // Stores governance rules for each farm
mapping worker_investment_rights: mapping(address, bool);  // Determines if workers can control their investments
mapping farm_nft_minting_rights: mapping(address, bool);  // Determines if a farm can mint RWA NFTs
mapping farm_resale_policies: mapping(address, bool);  // Determines if RWA NFTs can be resold by bulk buyers

constant DEFAULT_GOVERNANCE_POLICY: string = "Direct Farm-to-Table"; // Default governance policy

// Fixed options for worker investment management
constant OPTION_SELL: string = "Sell for USDC";
constant OPTION_REINVEST: string = "Reinvest in next harvest";
constant OPTION_DONATE: string = "Donate to community reserves";
constant OPTION_TRADE: string = "Trade for other farm products";

// Struct to track farm governance details
struct FarmGovernance {
    farm_address: address,
    voting_power: u64,
    governance_policy: string,
}

// Function to assign governance policies to farms
function set_farm_governance_policy(farm: address, policy: string) {
    farm_governance_policies[farm] = policy;
}

// Function to enable worker investment control for a farm
function enable_worker_investment_control(farm: address) {
    worker_investment_rights[farm] = true;
}

// Function to disable worker investment control for a farm
function disable_worker_investment_control(farm: address) {
    worker_investment_rights[farm] = false;
}

// Function to allow a farm to mint RWA NFTs
function allow_farm_nft_minting(farm: address) {
    farm_nft_minting_rights[farm] = true;
}

// Function to prevent a farm from minting RWA NFTs
function revoke_farm_nft_minting(farm: address) {
    farm_nft_minting_rights[farm] = false;
}

// Function to enable or disable bulk buyer resale rights (default: disabled)
function set_farm_resale_policy(farm: address, allow_resale: bool) {
    farm_resale_policies[farm] = allow_resale;
}

// Function for each worker to select their own investment choice
function select_investment_choice(worker: address, farm: address, choice: string) {
    ensure!(worker_investment_rights[farm] == true, "Worker investment control is not enabled for this farm");
    ensure!(
        choice == OPTION_SELL || choice == OPTION_REINVEST || choice == OPTION_DONATE || choice == OPTION_TRADE,
        "Invalid investment choice"
    );

    worker_investment_choices[worker] = choice;
}

// Function to process a worker's individual investment decision
function process_worker_investment(worker: address, farm: address) -> string {
    let choice = worker_investment_choices[worker];
    ensure!(choice != "", "No investment choice has been made");

    return choice;
}

// Function to check if a farm has worker investment control enabled
function is_worker_investment_control_enabled(farm: address) -> bool {
    return worker_investment_rights[farm];
}

// Function to check if a farm is authorized to mint RWA NFTs
function is_farm_nft_minting_allowed(farm: address) -> bool {
    return farm_nft_minting_rights[farm];
}

// Function to check if a farm allows resale by bulk buyers
function is_farm_resale_allowed(farm: address) -> bool {
    return farm_resale_policies[farm];
}

// Function to get a farm’s governance policy
function get_farm_governance_policy(farm: address) -> string {
    return farm_governance_policies[farm];
}
