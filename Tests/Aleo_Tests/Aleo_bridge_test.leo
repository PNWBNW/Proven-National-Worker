// 📌 Aleo Bridge Test Suite (Payroll Bridging with ANS & ZPass)

import aleo_bridge.leo;

test "Register Worker Wallet (ZPass & ANS Required)" {
    let worker = address("aleo1workerxyz456");
    let wallet = address("aztec1walletxyz789");
    let network = 3u8; // 3 = Noir (Aztec)

    // Ensure worker is ZPass verified
    assert!(aleo_bridge::zpass_verified.get_or_use(worker, false) == true);

    // Assign ANS name to worker
    let worker_ans = "john_doe.pncw.ans";
    aleo_bridge::ans_registry.insert(worker, worker_ans);
    aleo_bridge::ans_reverse_lookup.insert(worker_ans, worker);

    // Register worker wallet
    assert!(aleo_bridge::register_worker_wallet(worker, wallet, network) == true);

    // Verify wallet assignment
    let (saved_wallet, saved_network) = aleo_bridge::get_worker_wallet(worker);
    assert!(saved_wallet == wallet);
    assert!(saved_network == network);
}

test "Bridge Payroll from SubDAO to Worker (ZPass, ANS, Compliance Required)" {
    let employer = address("aleo1employerabc123");
    let worker = address("aleo1workerxyz456");
    let subdao_ans = "wa001_payroll.pnw.ans";
    let amount = 3000u64;

    // Ensure employer is compliant
    aleo_bridge::verify_employer_compliance(employer, true);
    assert!(aleo_bridge::employer_compliance.get_or_use(employer, false) == true);

    // Ensure worker is ZPass verified & ANS registered
    assert!(aleo_bridge::zpass_verified.get_or_use(worker, false) == true);
    let worker_ans = "john_doe.pncw.ans";
    aleo_bridge::ans_registry.insert(worker, worker_ans);

    // Set employer balance
    aleo_bridge::set_employer_balance(employer, 5000u64);
    assert!(aleo_bridge::get_employer_balance(employer) == 5000u64);

    // Bridge payroll
    assert!(aleo_bridge::bridge_payroll(employer, worker, amount, subdao_ans) == true);

    // Verify updated employer balance
    assert!(aleo_bridge::get_employer_balance(employer) == 2000u64);
}

test "Prevent Payroll Bridge if Employer is Non-Compliant" {
    let employer = address("aleo1employerabc123");
    let worker = address("aleo1workerxyz456");
    let subdao_ans = "wa001_payroll.pnw.ans";
    let amount = 3000u64;

    // Ensure employer is NOT compliant
    aleo_bridge::verify_employer_compliance(employer, false);
    assert!(aleo_bridge::employer_compliance.get_or_use(employer, true) == false);

    // Attempt to bridge payroll (should fail)
    assert!(aleo_bridge::bridge_payroll(employer, worker, amount, subdao_ans) == false);
}

test "Prevent Payroll Bridge if Worker is Not ZPass Verified" {
    let employer = address("aleo1employerabc123");
    let worker = address("aleo1workerxyz456");
    let subdao_ans = "wa001_payroll.pnw.ans";
    let amount = 3000u64;

    // Ensure employer is compliant
    aleo_bridge::verify_employer_compliance(employer, true);

    // Ensure worker is NOT ZPass verified
    aleo_bridge::zpass_verified.insert(worker, false);
    assert!(aleo_bridge::zpass_verified.get_or_use(worker, true) == false);

    // Attempt to bridge payroll (should fail)
    assert!(aleo_bridge::bridge_payroll(employer, worker, amount, subdao_ans) == false);
}

test "Bridge Payroll to Stellar Wallet (ANS & ZPass Required)" {
    let employer = address("aleo1employerabc123");
    let worker = address("aleo1workerxyz456");
    let subdao_ans = "wa001_payroll.pnw.ans";
    let amount = 2500u64;
    let worker_wallet = address("stellar1walletabc789");

    // Ensure employer compliance
    aleo_bridge::verify_employer_compliance(employer, true);

    // Ensure worker is ZPass verified & ANS registered
    assert!(aleo_bridge::zpass_verified.get_or_use(worker, false) == true);
    let worker_ans = "jane_doe.pncw.ans";
    aleo_bridge::ans_registry.insert(worker, worker_ans);

    // Register Stellar wallet
    aleo_bridge::register_worker_wallet(worker, worker_wallet, 2u8);
    let (saved_wallet, saved_network) = aleo_bridge::get_worker_wallet(worker);
    assert!(saved_wallet == worker_wallet);
    assert!(saved_network == 2u8);

    // Bridge payroll to Stellar
    assert!(aleo_bridge::bridge_payroll(employer, worker, amount, subdao_ans) == true);
}

test "Bridge Payroll to Aztec Wallet (ANS & ZPass Required)" {
    let employer = address("aleo1employerabc123");
    let worker = address("aleo1workerxyz456");
    let subdao_ans = "wa001_payroll.pnw.ans";
    let amount = 2000u64;
    let worker_wallet = address("aztec1walletxyz789");

    // Ensure employer compliance
    aleo_bridge::verify_employer_compliance(employer, true);

    // Ensure worker is ZPass verified & ANS registered
    assert!(aleo_bridge::zpass_verified.get_or_use(worker, false) == true);
    let worker_ans = "john_doe.pncw.ans";
    aleo_bridge::ans_registry.insert(worker, worker_ans);

    // Register Aztec wallet
    aleo_bridge::register_worker_wallet(worker, worker_wallet, 3u8);
    let (saved_wallet, saved_network) = aleo_bridge::get_worker_wallet(worker);
    assert!(saved_wallet == worker_wallet);
    assert!(saved_network == 3u8);

    // Bridge payroll to Aztec
    assert!(aleo_bridge::bridge_payroll(employer, worker, amount, subdao_ans) == true);
}
