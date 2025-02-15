program pniw_payroll.aleo;

import mining_investment.leo;
import aztec_bridge.noir; // New import for Aztec Payroll Bridge

// 🏷️ Mappings
mapping worker_category: public hashmap<address, string>;
mapping pto_balances: public hashmap<address, u64>;
mapping sick_balances: public hashmap<address, u64>;
mapping employer_pto_funds: public hashmap<address, u64>;
mapping employer_sick_funds: public hashmap<address, u64>;
mapping payroll_records: public hashmap<address, u64>;
mapping mining_rewards: public hashmap<address, u64>;
mapping trust_funds: public hashmap<address, u64>;
mapping farm_investments: public hashmap<address, u64>;
mapping minimum_usdc_pool: public hashmap<address, u64>;

// 🔹 ANS & Aztec Payroll Preferences
mapping ans_registry: public hashmap<address, string>;
mapping ans_reverse_lookup: public hashmap<string, address>;
mapping aztec_payroll_enabled: public hashmap<address, bool>;  // Tracks workers opting for Aztec Payroll

// 📦 Structs
struct WorkerPayroll {
    worker_address: address,
    employer: address,
    wage: u64,
    mining_income: u64,
    mining_to_trust: u64,
    accrued_pto: u64,
    accrued_sick: u64,
    trust_fund_balance: u64,
    last_payroll_time: u64,
    ans_name: string,
    using_aztec: bool,  // New field to indicate Aztec payroll
}

/// @dev Process payroll while ensuring Aleo deductions occur first
function process_payroll(worker: address, employer: address, wage: u64, hours_worked: u64, trust_contribution: u64, mining_to_trust: u64) {
    ensure!(verify_employer_funding(employer), "Employer has not funded PTO/Sick Pay reserves");
    ensure!(verify_usdc_pool(employer), "Employer USDC pool is below required minimum");

    let pto_rate = 1 / 20;
    let sick_rate = 1 / 40;
    let pto_accrued = hours_worked * pto_rate;
    let sick_accrued = hours_worked * sick_rate;

    let mining_income = mining_rewards.get(worker).unwrap_or(0);
    ensure!(mining_to_trust <= mining_income, "Cannot allocate more mining income than received.");

    mining_rewards[worker] -= mining_to_trust;
    trust_funds[worker] += mining_to_trust;

    payroll_records[worker] += wage;
    pto_balances[worker] += pto_accrued;
    sick_balances[worker] += sick_accrued;
    trust_funds[worker] += trust_contribution;

    employer_pto_funds[employer] -= pto_accrued;
    employer_sick_funds[employer] -= sick_accrued;

    let using_aztec = aztec_payroll_enabled.get(worker).unwrap_or(false);

    // Deduct trust, PTO, sick pay first (Only the remaining amount is sent to Aztec)
    let net_payroll = wage - trust_contribution - pto_accrued - sick_accrued;

    if using_aztec {
        ensure!(aleo_zpass::is_verified(worker), "Worker must be ZPass verified for Aztec Payroll");
        ensure!(aleo_ans::is_registered(ans_registry.get(worker).unwrap_or("")), "Worker must have an ANS registration for Aztec Payroll");

        // Route payroll through Aztec Bridge
        aztec_bridge::transfer_payroll({
            recipient: worker,
            amount: net_payroll,
            fee_option: true, // Default to direct transfer (worker can change this)
            ans_domain: ans_registry.get(worker).unwrap_or("")
        });
    }

    let payroll_entry = WorkerPayroll {
        worker_address: worker,
        employer: employer,
        wage: wage,
        mining_income: mining_income - mining_to_trust,
        mining_to_trust: mining_to_trust,
        accrued_pto: pto_accrued,
        accrued_sick: sick_accrued,
        trust_fund_balance: trust_contribution + mining_to_trust,
        last_payroll_time: env::block_time(),
        ans_name: ans_registry.get(worker).unwrap_or(""),
        using_aztec: using_aztec,
    };

    return true;
}

/// @dev Worker chooses Aztec payroll option
function set_aztec_payroll_preference(worker: address, enable: bool) -> bool {
    ensure!(aleo_zpass::is_verified(worker), "ZPass verification required");
    ensure!(ans_registry.contains(worker), "ANS registration required");

    aztec_payroll_enabled.insert(worker, enable);
    return true;
}

/// @dev Verifies that employer PTO & Sick Pay reserves are funded
function verify_employer_funding(employer: address) -> bool {
    return employer_pto_funds.get(employer).unwrap_or(0) > 0 && employer_sick_funds.get(employer).unwrap_or(0) > 0;
}

/// @dev Verifies that employer has sufficient USDC liquidity pool
function verify_usdc_pool(employer: address) -> bool {
    return minimum_usdc_pool.get(employer).unwrap_or(0) > 0;
}
