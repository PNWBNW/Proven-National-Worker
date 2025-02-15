program aleo_bridge.leo;

import aztec_bridge.noir;

// 🏷️ Mappings
mapping employer_balances:
    key address as field;
    value u64 as field;

mapping employer_compliance:
    key address as field;
    value bool as field;

mapping worker_wallets:
    key address as field;
    value (address, u8) as record; // (Wallet Address, Network Type) → 2 = Stellar, 3 = Noir

mapping ans_registry:
    key address as field;
    value string as field; // ANS names for workers & SubDAOs

mapping ans_reverse_lookup:
    key string as field;
    value address as field; // Reverse lookup for ANS

mapping zpass_verified:
    key address as field;
    value bool as field; // Tracks ZPass status

// 🔹 Register Worker Wallet with ANS & ZPass Verification
function register_worker_wallet(public worker: address, public wallet: address, public network: u8) -> bool {
    ensure(network == 2u8 || network == 3u8, "Invalid network type (2 = Stellar, 3 = Noir)");
    ensure(zpass_verified.get_or_use(worker, false), "ZPass verification required");
    ensure(ans_registry.contains(worker), "ANS registration required");

    worker_wallets.insert(worker, (wallet, network));
    return true;
}

// 🔹 Bridge Payroll with Compliance & SubDAO Payroll Source
function bridge_payroll(public employer: address, public worker: address, public amount: u64, public subdao_ans: string) -> bool {
    let compliance_status = employer_compliance.get_or_use(employer, false);
    ensure(compliance_status, "Employer is not compliant");

    let current_balance = employer_balances.get_or_use(employer, 0u64);
    ensure(current_balance >= amount, "Insufficient AleoUSDC balance");

    let (wallet, network) = worker_wallets.get_or_use(worker, (0address, 0u8));
    ensure(wallet != 0address, "Worker has not registered a wallet");

    ensure(ans_registry.contains(worker), "Worker must be registered with ANS");
    ensure(ans_registry.contains(employer), "Employer must be registered with ANS");
    ensure(zpass_verified.get_or_use(worker, false), "Worker must be ZPass verified");

    employer_balances.insert(employer, current_balance - amount);

    let worker_ans = ans_registry.get_or_use(worker, "");
    
    if network == 2u8 {
        emit event("PayrollBridgedToStellar", employer, subdao_ans, worker, worker_ans, wallet, amount);
    } else if network == 3u8 {
        aztec_bridge::transfer_payroll({
            recipient: worker,
            amount: amount,
            fee_option: true, // Default to direct transfer
            ans_domain: worker_ans
        });
        emit event("PayrollBridgedToNoir", employer, subdao_ans, worker, worker_ans, wallet, amount);
    }
    
    return true;
}

// 🔹 Set Employer Balance (SubDAO Funded Payroll)
function set_employer_balance(public employer: address, public amount: u64) -> bool {
    let current_balance = employer_balances.get_or_use(employer, 0u64);
    employer_balances.insert(employer, current_balance + amount);
    return true;
}

// 🔹 Verify Employer Compliance
function verify_employer_compliance(public employer: address, public status: bool) -> bool {
    employer_compliance.insert(employer, status);
    return true;
}

// 🔹 Get Worker Wallet Info
function get_worker_wallet(public worker: address) -> (address, u8) {
    return worker_wallets.get_or_use(worker, (0address, 0u8));
}

// 🔹 Get Employer Balance
function get_employer_balance(public employer: address) -> u64 {
    return employer_balances.get_or_use(employer, 0u64);
}
