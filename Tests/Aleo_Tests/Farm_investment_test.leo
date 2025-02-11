// 📌 Farm Investment Test Suite

import farm_investment.leo;

test "Worker Invests in Farm (ZPass & ANS Required)" {
    let worker = address("aleo1workerxyz456");
    let farm = address("aleo1farm789");
    let investment_amount = 500;
    let ans_name = "johndoe.pncw";

    // Ensure worker is ZPass verified
    assert!(farm_investment::worker_zpass_verified[worker] == true);

    // Assign ANS name to worker
    farm_investment::ans_registry[worker] = ans_name;
    farm_investment::ans_reverse_lookup[ans_name] = worker;

    // Worker invests in farm
    assert!(farm_investment::invest_in_farm(worker, farm, investment_amount) == true);
    assert!(farm_investment::worker_farm_investment[worker] == investment_amount);
}

test "Worker Withdraws Farm Investment (ZPass & ANS Required)" {
    let worker = address("aleo1workerxyz456");
    let ans_name = "johndoe.pncw";
    let withdrawal_amount = 200;

    // Ensure worker is ZPass verified
    assert!(farm_investment::worker_zpass_verified[worker] == true);

    // Assign ANS name to worker
    farm_investment::ans_registry[worker] = ans_name;
    farm_investment::ans_reverse_lookup[ans_name] = worker;

    // Withdraw farm investment
    assert!(farm_investment::withdraw_farm_investment(worker, withdrawal_amount) == true);
}

test "Convert Investment to RWA NFT (ZPass & ANS Required)" {
    let worker = address("aleo1workerxyz456");
    let farm = address("aleo1farm789");
    let nft_id = 12345;
    let ans_name = "johndoe.pncw";

    // Ensure worker is ZPass verified
    assert!(farm_investment::worker_zpass_verified[worker] == true);

    // Assign ANS name to worker
    farm_investment::ans_registry[worker] = ans_name;
    farm_investment::ans_reverse_lookup[ans_name] = worker;

    // Convert farm investment to NFT
    assert!(farm_investment::convert_investment_to_nft(worker, farm, nft_id) == true);
    assert!(farm_investment::worker_nft_holdings[worker] == nft_id);
}

test "Verify Farm Merkle Proof" {
    let farm = address("aleo1farm789");
    let merkle_root = 987654321;

    // Register Merkle proof for farm
    assert!(farm_investment::register_farm_merkle(farm, merkle_root) == true);

    // Verify Merkle proof
    assert!(farm_investment::verify_farm_merkle(farm, merkle_root) == true);
}

test "Farm Certification Verification (API + ZPass Required)" {
    let farm = address("aleo1farm789");
    let certification = "USDA Organic";

    // Ensure farm certification is registered
    assert!(farm_investment::register_farm_certification(farm, certification) == true);

    // Verify farm certification
    assert!(farm_investment::get_farm_certification(farm) == certification);
}
