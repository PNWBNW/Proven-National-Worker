// 📌 RWA NFT Test Suite

import rwa_nft.leo;

test "PNcW Worker Mints RWA NFT (ZPass & ANS Required)" {
    let worker = address("aleo1pncwworker456");
    let farm = address("aleo1farm789");
    let ans_name = "janedoe.pncw";
    let nft_id = 5555;

    // Ensure worker is ZPass verified
    assert!(rwa_nft::worker_zpass_verified[worker] == true);

    // Assign ANS name
    rwa_nft::ans_registry[worker] = ans_name;
    rwa_nft::ans_reverse_lookup[ans_name] = worker;

    // Mint RWA NFT
    assert!(rwa_nft::mint_rwa_nft(farm, worker, nft_id, "Farm Investment NFT") == true);

    // Verify NFT ownership
    assert!(rwa_nft::worker_nft_holdings[worker] == nft_id);
}

test "PNiW Worker Mints RWA NFT (ZPass & ANS Required)" {
    let worker = address("aleo1pniwworker789");
    let farm = address("aleo1farm123");
    let ans_name = "janedoe.pniw";
    let nft_id = 7777;

    // Ensure worker is ZPass verified
    assert!(rwa_nft::worker_zpass_verified[worker] == true);

    // Assign ANS name
    rwa_nft::ans_registry[worker] = ans_name;
    rwa_nft::ans_reverse_lookup[ans_name] = worker;

    // Mint RWA NFT
    assert!(rwa_nft::mint_rwa_nft(farm, worker, nft_id, "Farm Investment NFT") == true);

    // Verify NFT ownership
    assert!(rwa_nft::worker_nft_holdings[worker] == nft_id);
}

test "Worker Transfers RWA NFT (ZPass & ANS Required)" {
    let sender = address("aleo1pncwworker456");
    let receiver = address("aleo1pncwworker789");
    let nft_id = 5555;
    let ans_sender = "janedoe.pncw";
    let ans_receiver = "johnsmith.pncw";

    // Ensure both sender and receiver are ZPass verified
    assert!(rwa_nft::worker_zpass_verified[sender] == true);
    assert!(rwa_nft::worker_zpass_verified[receiver] == true);

    // Assign ANS names
    rwa_nft::ans_registry[sender] = ans_sender;
    rwa_nft::ans_registry[receiver] = ans_receiver;
    rwa_nft::ans_reverse_lookup[ans_sender] = sender;
    rwa_nft::ans_reverse_lookup[ans_receiver] = receiver;

    // Transfer RWA NFT
    assert!(rwa_nft::transfer_rwa_nft(sender, receiver, nft_id) == true);

    // Verify new ownership
    assert!(rwa_nft::worker_nft_holdings[sender] == 0);
    assert!(rwa_nft::worker_nft_holdings[receiver] == nft_id);
}

test "Worker Redeems RWA NFT (ZPass & ANS Required)" {
    let worker = address("aleo1pncwworker456");
    let farm = address("aleo1farm789");
    let nft_id = 5555;
    let ans_name = "janedoe.pncw";

    // Ensure worker is ZPass verified
    assert!(rwa_nft::worker_zpass_verified[worker] == true);

    // Assign ANS name
    rwa_nft::ans_registry[worker] = ans_name;
    rwa_nft::ans_reverse_lookup[ans_name] = worker;

    // Mint NFT first
    assert!(rwa_nft::mint_rwa_nft(farm, worker, nft_id, "Farm Investment NFT") == true);

    // Redeem NFT
    assert!(rwa_nft::redeem_rwa_nft(worker, nft_id) == true);

    // Verify NFT is burned (ownership reset)
    assert!(rwa_nft::worker_nft_holdings[worker] == 0);
}

test "Worker Cannot Mint RWA NFT Without ZPass" {
    let worker = address("aleo1unverifiedworker999");
    let farm = address("aleo1farm789");
    let nft_id = 9999;

    // Ensure worker is NOT ZPass verified
    assert!(rwa_nft::worker_zpass_verified[worker] == false);

    // Attempt minting (should fail)
    assert!(rwa_nft::mint_rwa_nft(farm, worker, nft_id, "Farm Investment NFT") == false);
}

test "Bulk Buyer Cannot Resell RWA NFT (Resale Restricted)" {
    let buyer = address("aleo1bulkbuyer777");
    let nft_id = 6666;

    // Ensure farm resale policy is disabled
    assert!(rwa_nft::is_farm_resale_allowed(nft_id) == false);

    // Attempt resale (should fail)
    assert!(rwa_nft::transfer_rwa_nft(buyer, address("aleo1thirdparty999"), nft_id) == false);
}
