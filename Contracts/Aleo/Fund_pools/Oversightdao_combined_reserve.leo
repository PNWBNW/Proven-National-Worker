// 🔹 OversightDAO Combined Reserve Contract 🔹
// Manages extra 25% liquidity (50% CircleUSDC / 50% AleoUSDC).
// Supports SubDAOs by assisting payroll solvency & enabling swaps.

import aleo_std::*;
import subdao_circle_usdc_reserve::*;
import subdao_aleo_usdc_reserve::*;
import aleo_ans::*;

struct LiquidityRequest {
    subdao_id: Field,
    requested_token: String,
    requested_amount: u64,
    timestamp: u64,
}

// 🔹 OversightDAO Liquidity Pool Management
struct LiquidityPool {
    circle_usdc_balance: u64,
    aleo_usdc_balance: u64,
}

// 🔹 Initialize Liquidity Pool
let liquidity_pool = LiquidityPool {
    circle_usdc_balance: 0,
    aleo_usdc_balance: 0,
};

// 🔹 Function: Deposit Extra Employer Contributions (50/50 Split)
fn deposit_extra_contribution(employer_id: Field, amount: u64) {
    let half = amount / 2;
    liquidity_pool.circle_usdc_balance += half;
    liquidity_pool.aleo_usdc_balance += half;
}

// 🔹 Function: Request Emergency Liquidity (Enforces Limits)
fn request_liquidity(subdao_id: Field, requested_token: String, requested_amount: u64) -> bool {
    assert!(requested_token == "CircleUSDC" || requested_token == "AleoUSDC", "Invalid token request");

    // Max withdrawal limit: 75% of the available liquidity
    let max_withdrawable = if requested_token == "CircleUSDC" {
        liquidity_pool.circle_usdc_balance * 75 / 100
    } else {
        liquidity_pool.aleo_usdc_balance * 75 / 100
    };

    assert!(requested_amount <= max_withdrawable, "Cannot withdraw more than 75% of liquidity reserves");

    // Process liquidity request
    if requested_token == "CircleUSDC" {
        liquidity_pool.circle_usdc_balance -= requested_amount;
        subdao_circle_usdc_reserve::receive_liquidity(subdao_id, requested_amount);
    } else {
        liquidity_pool.aleo_usdc_balance -= requested_amount;
        subdao_aleo_usdc_reserve::receive_liquidity(subdao_id, requested_amount);
    }

    emit liquidity_assistance_event(subdao_id, requested_token, requested_amount);
    return true;
}

// 🔹 Function: Swap Between CircleUSDC & AleoUSDC (If Liquidity Allows)
fn swap_liquidity(requester_id: Field, from_token: String, to_token: String, amount: u64) -> bool {
    assert!(from_token != to_token, "Invalid swap: Tokens must be different");

    if from_token == "CircleUSDC" && liquidity_pool.aleo_usdc_balance >= amount {
        liquidity_pool.circle_usdc_balance += amount;
        liquidity_pool.aleo_usdc_balance -= amount;
    } else if from_token == "AleoUSDC" && liquidity_pool.circle_usdc_balance >= amount {
        liquidity_pool.aleo_usdc_balance += amount;
        liquidity_pool.circle_usdc_balance -= amount;
    } else {
        return false; // Swap fails if insufficient liquidity
    }

    emit swap_event(requester_id, from_token, to_token, amount);
    return true;
}

// 🔹 Function: Employer Auto-Top-Up Enforcement
fn enforce_employer_topup(employer_id: Field, subdao_id: Field) -> bool {
    let subdao_balance = subdao_circle_usdc_reserve::get_subdao_balance(subdao_id);
    let min_required = subdao_balance * 50 / 100;

    assert!(subdao_balance < min_required, "SubDAO has sufficient funds");

    emit topup_request_event(employer_id, subdao_id, min_required);
    return true;
}

// 🔹 Function: Employer Overhead Reduction for Maintaining Solvency
fn update_employer_overhead(employer_id: Field, months_solved: u64) {
    if months_solved >= 1 {
        let reduction = months_solved.min(25); // Max reduction limit is 25%
        emit overhead_reduction_event(employer_id, reduction);
    }
}

// 🔹 Function: Get Liquidity Pool Balances (Public View)
fn get_liquidity_balances() -> LiquidityPool {
    return liquidity_pool;
}

// 🔹 Event Emitters
event liquidity_assistance_event(subdao_id: Field, requested_token: String, requested_amount: u64);
event swap_event(requester_id: Field, from_token: String, to_token: String, amount: u64);
event topup_request_event(employer_id: Field, subdao_id: Field, min_required: u64);
event overhead_reduction_event(employer_id: Field, reduction: u64);
