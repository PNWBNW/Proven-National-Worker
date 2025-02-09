program aleo_bridge.leo;

mapping employer_balances:
    key address as field;
    value u64 as field;

mapping employer_compliance:
    key address as field;
    value bool as field;

mapping worker_wallets:
    key address as field;
    value (address, u8) as record; // (Wallet Address, Network Type) → 1 = EVM, 2 = Stellar

function register_worker_wallet(public worker: address, public wallet: address, public network: u8) -> bool {
    ensure(network == 1u8 || network == 2u8, "Invalid network type (1 = EVM, 2 = Stellar)");
    worker_wallets.insert(worker, (wallet, network));
    return true;
}

function bridge_payroll(public employer: address, public worker: address, public amount: u64) -> bool {
    let compliance_status = employer_compliance.get_or_use(employer, false);
    ensure(compliance_status, "Employer is not compliant");

    let current_balance = employer_balances.get_or_use(employer, 0u64);
    ensure(current_balance >= amount, "Insufficient AleoUSDC balance");

    let (wallet, network) = worker_wallets.get_or_use(worker, (0address, 0u8));
    ensure(wallet != 0address, "Worker has not registered a wallet");

    employer_balances.insert(employer, current_balance - amount);

    if network == 1u8 {
        emit event("PayrollBridgedToEVM", employer, worker, wallet, amount);
    } else if network == 2u8 {
        emit event("PayrollBridgedToStellar", employer, worker, wallet, amount);
    }
    
    return true;
}

function set_employer_balance(public employer: address, public amount: u64) -> bool {
    let current_balance = employer_balances.get_or_use(employer, 0u64);
    employer_balances.insert(employer, current_balance + amount);
    return true;
}

function verify_employer_compliance(public employer: address, public status: bool) -> bool {
    employer_compliance.insert(employer, status);
    return true;
}

function get_worker_wallet(public worker: address) -> (address, u8) {
    return worker_wallets.get_or_use(worker, (0address, 0u8));
}

function get_employer_balance(public employer: address) -> u64 {
    return employer_balances.get_or_use(employer, 0u64);
}
