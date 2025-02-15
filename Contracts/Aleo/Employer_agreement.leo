program employer_agreement.aleo;

import aleo_usdc_pool.leo;
import certification_verifier.leo;
import farm_investment.leo;
import compliance_tracking.leo;
import mining_investment.leo;
import aztec_payroll.noir;
import subdao_circle_usdc_reserve.noir;
import subdao_aleo_usdc_reserve.leo;
import oversightdao_combined_reserve.leo;

// 🏷️ Employer Payroll Fund Tracking
mapping employer_balances: public hashmap<address, u64>;  
mapping employer_aztec_balances: public hashmap<address, u64>;  
mapping employer_status: public hashmap<address, bool>;   
mapping worker_assignments: public hashmap<address, address>;  

// 🔹 Worker-Specific Payroll Preferences
mapping worker_hourly_wages: public hashmap<address, u64>;  
mapping employer_hourly_buffer: public hashmap<address, u64>;  
mapping worker_aztec_enabled: public hashmap<address, bool>;  

// 🔹 Employer Payroll Solvency Tracking
mapping employer_solvency_months: public hashmap<address, u64>;  

// 🔹 Farm & Investment Restrictions
mapping employer_farm_types: public hashmap<address, array<string>>;  
mapping employer_certifications: public hashmap<address, array<string>>;  
mapping employer_investment_limits: public hashmap<address, u64>;  
mapping employer_farm_investment_agreement: public hashmap<address, bool>;  

// 🔹 Employer Mining Contributions
mapping employer_mining_contribution: public hashmap<address, u64>;  
mapping grant_mining_rig_eligibility: public hashmap<address, bool>;  

// 🔹 Multi-Chain Payroll Compliance
mapping employer_subdao_fees: public hashmap<address, u64>;  

/// @dev Employers must register mining contributions for compliance
function verify_mining_contribution(employer: address, mining_power: u64) -> bool {
    ensure!(employer_status.get(employer).unwrap_or(false), "Employer is non-compliant.");
    ensure!(mining_power > 0, "Mining contribution must be greater than zero.");
    
    employer_mining_contribution.insert(employer, mining_power);
    compliance_tracking.update_mining_proof(employer, mining_power);
    mining_investment.track_mining_rewards(employer, mining_power);

    return true;
}

/// @dev Employers can apply for a grant-funded mining rig
function apply_for_grant_mining_rig(employer: address) -> bool {
    ensure!(employer_status.get(employer).unwrap_or(false), "Employer is non-compliant.");
    ensure!(!grant_mining_rig_eligibility.contains(employer), "Employer has already received a grant-funded rig.");
    
    grant_mining_rig_eligibility.insert(employer, true);
    return true;
}

/// @dev Ensures worker investments follow employer-defined farm restrictions
function enforce_farm_investment_restrictions(worker: address, employer: address, farm_type: string, investment_amount: u64) -> bool {
    ensure!(employer_status.get(employer).unwrap_or(false), "Employer is non-compliant.");
    
    let allowed_farms = employer_farm_types.get(employer).unwrap_or(vec![]);
    ensure!(allowed_farms.contains(farm_type), "Worker cannot invest in this farm type.");

    let certs_required = employer_certifications.get(employer).unwrap_or(vec![]);
    if !certs_required.is_empty() {
        let valid_certification = certification_verifier.verify_certification(employer, farm_type);
        ensure!(valid_certification, "Farm does not meet certification requirements.");
    }

    let max_investment = employer_investment_limits.get(employer).unwrap_or(0);
    ensure!(investment_amount <= max_investment, "Investment exceeds employer-defined limit.");

    let compliant = compliance_tracking.check_employer_compliance(employer);
    ensure!(compliant, "Investment blocked due to unpaid employer payroll.");

    return true;
}

/// @dev Employers must approve farm investment agreements before workers can invest
function approve_farm_investment_agreement(employer: address) -> bool {
    ensure!(employer_status.get(employer).unwrap_or(false), "Employer is non-compliant.");
    employer_farm_investment_agreement.insert(employer, true);
    return true;
}

/// @dev Employers must deposit payroll into the assigned SubDAO before paying workers
function deposit_payroll_to_subdao(employer: address, subdao_id: Field, amount: u64, use_aztec: bool) -> bool {
    ensure!(employer_status.get(employer).unwrap_or(false), "Employer is not registered.");
    
    if use_aztec {
        let success = subdao_circle_usdc_reserve.deposit_circle_usdc(subdao_id, employer, amount);
        ensure!(success, "Failed to deposit CircleUSDC into SubDAO.");
        employer_aztec_balances.insert(employer, employer_aztec_balances.get(employer).unwrap_or(0) + amount);
    } else {
        let success = subdao_aleo_usdc_reserve.deposit_aleo_usdc(subdao_id, employer, amount);
        ensure!(success, "Failed to deposit AleoUSDC into SubDAO.");
        employer_balances.insert(employer, employer_balances.get(employer).unwrap_or(0) + amount);
    }

    enforce_employer_topup(employer);
    return true;
}

/// @dev Employers must contribute a percentage of payroll to SubDAO reserves
function contribute_to_subdao_reserve(employer: address, subdao_id: Field, payroll_amount: u64) -> bool {
    let contribution_rate = employer_subdao_fees.get(employer).unwrap_or(1);
    let contribution_amount = payroll_amount * contribution_rate / 100;

    let success = subdao_aleo_usdc_reserve.deposit_aleo_usdc(subdao_id, employer, contribution_amount);
    ensure!(success, "Failed to contribute to SubDAO reserve.");

    return true;
}

/// @dev Employers must automatically top-up payroll if funds drop below 50%
function enforce_employer_topup(employer: address) -> bool {
    let employer_balance = employer_balances.get(employer).unwrap_or(0);
    let employer_aztec_balance = employer_aztec_balances.get(employer).unwrap_or(0);
    let total_balance = employer_balance + employer_aztec_balance;
    
    let required_balance = employer_hourly_buffer.get(employer).unwrap_or(24) * 50;
    
    if total_balance < required_balance {
        oversightdao_combined_reserve.request_employer_topup(employer, total_balance);
    }

    return true;
}

/// @dev Reduces employer overhead by 1% per month if solvent
function update_employer_overhead(employer: address) -> bool {
    let months_solved = employer_solvency_months.get(employer).unwrap_or(0);
    
    if months_solved >= 1 {
        let reduction = months_solved.min(25);
        oversightdao_combined_reserve.update_employer_overhead(employer, reduction);
    }

    return true;
}
