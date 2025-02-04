program worker_identity_test.aleo;

import worker_identity.aleo;

function test_worker_registration() -> bool {
    let worker_address = aleo1workerexample123;
    let worker_type = 0u8;  // 0 = PNcW, 1 = PNiW
    let industry_type = 101u64;
    let zk_proof = "zk_placeholder_proof";
    let merkle_kyc = "merkle_placeholder_proof";

    let registration_status = worker_identity::register_worker(worker_address, worker_type, industry_type, zk_proof, merkle_kyc);

    assert(registration_status == true, "Worker registration failed");
    return registration_status;
}

function test_worker_verification() -> bool {
    let worker_address = aleo1workerexample123;
    let verification_status = worker_identity::is_verified_worker(worker_address);

    assert(verification_status == true, "Worker verification failed");
    return verification_status;
}

function test_kyc_verification() -> bool {
    let worker_address = aleo1workerexample123;
    let merkle_kyc = "merkle_placeholder_proof";

    let kyc_status = worker_identity::verify_kyc_fallback(worker_address, merkle_kyc);

    assert(kyc_status == true, "Worker KYC verification failed");
    return kyc_status;
}

function test_worker_industry_update() -> bool {
    let worker_address = aleo1workerexample123;
    let new_industry = 202u64;

    let update_status = worker_identity::update_industry(worker_address, new_industry);

    assert(update_status == true, "Industry update failed");
    return update_status;
}

function test_worker_type_retrieval() -> bool {
    let worker_address = aleo1workerexample123;
    let worker_type = worker_identity::get_worker_type(worker_address);

    assert(worker_type == 0u8 || worker_type == 1u8, "Invalid worker type retrieval");
    return true;
}
