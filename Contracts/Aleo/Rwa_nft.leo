program rwa_nft.leo;

mapping nft_ownership: mapping(u64, address);  // Tracks ownership of each RWA NFT
mapping nft_metadata: mapping(u64, string);  // Stores metadata for RWA NFTs (product details)
mapping farm_certification_status: mapping(address, bool); // Tracks whether a farm is certified for RWA issuance
mapping farm_nft_minting_rights: mapping(address, bool); // Tracks DAO-approved farms for NFT minting
mapping nft_redemption_status: mapping(u64, bool); // Tracks whether an NFT has been redeemed for physical delivery
mapping worker_verified: mapping(address, bool); // Ensures only validated workers can trade RWA NFTs
mapping nft_marketplace_requirement: mapping(u64, bool); // Ensures NFTs must be sold & redeemed via the marketplace

constant NFT_TYPE: string = "Farm Product RWA"; // Default classification for these NFTs

// Struct to track RWA NFT details
struct RWA_NFT {
    nft_id: u64,
    farm_address: address,
    owner: address,
    metadata: string,
    is_redeemed: bool,
}

// Function to mint an RWA NFT (Only DAO-approved farms can mint; NFTs go directly to worker’s wallet)
function mint_rwa_nft(farm: address, worker: address, nft_id: u64, metadata: string) {
    ensure!(farm_certification_status[farm] == true, "Farm must be certified to mint RWA NFTs");
    ensure!(farm_nft_minting_rights[farm] == true, "Farm must be DAO-approved to mint RWA NFTs");
    ensure!(nft_ownership[nft_id] == address(0), "NFT ID already exists");

    nft_ownership[nft_id] = worker;
    nft_metadata[nft_id] = metadata;
    nft_redemption_status[nft_id] = false;
    nft_marketplace_requirement[nft_id] = true; // Enforce marketplace sale & redemption
}

// Function to transfer an RWA NFT (Only validated workers can trade; must use marketplace)
function transfer_rwa_nft(nft_id: u64, new_owner: address) {
    let current_owner = nft_ownership[nft_id];
    ensure!(current_owner != address(0), "NFT does not exist");
    ensure!(worker_verified[current_owner] == true, "Only validated workers can trade RWA NFTs");
    ensure!(worker_verified[new_owner] == true, "Only validated workers can receive RWA NFTs");
    ensure!(nft_marketplace_requirement[nft_id] == true, "NFT must be sold through the marketplace");
    ensure!(nft_redemption_status[nft_id] == false, "NFT has already been redeemed and cannot be transferred");

    nft_ownership[nft_id] = new_owner;
}

// Function to redeem an RWA NFT (Must be processed through the marketplace)
function redeem_rwa_nft(nft_id: u64, farm: address) {
    ensure!(nft_ownership[nft_id] != address(0), "NFT does not exist");
    ensure!(nft_redemption_status[nft_id] == false, "NFT has already been redeemed");
    ensure!(nft_marketplace_requirement[nft_id] == true, "NFT must be redeemed through the marketplace");

    nft_redemption_status[nft_id] = true;
}

// Function to verify if an RWA NFT is valid and unredeemed
function is_rwa_nft_valid(nft_id: u64) -> bool {
    return nft_ownership[nft_id] != address(0) && nft_redemption_status[nft_id] == false;
}

// Function to check the owner of an RWA NFT
function get_nft_owner(nft_id: u64) -> address {
    return nft_ownership[nft_id];
}

// Function to retrieve the metadata of an RWA NFT
function get_nft_metadata(nft_id: u64) -> string {
    return nft_metadata[nft_id];
}
