// 🔹 OversightDAO Combined Reserve Contract 🔹
// Manages extra 25% liquidity (50% CircleUSDC / 50% AleoUSDC).
// Supports SubDAOs by assisting payroll solvency & enabling swaps.

import aleo_std::*;
import subdao_circle_usdc_reserve::*;
import subdao_aleo_usdc_reserve::*;

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

// 🔹 Function: Request Emergency Liquidity
fn request_liquidity(subdao_id: Field, requested_token: String, requested_amount: u64) -> bool {
    assert!(requested_token == "CircleUSDC" || requested_token == "AleoUSDC", "Invalid token request");

    // Check liquidity availability
    if requested_token == "CircleUSDC" {
        assert!(liquidity_pool.circle_usdc_balance >= requested_amount, "Insufficient CircleUSDC");
        liquidity_pool.circle_usdc_balance -= requested_amount;
        subdao_circle_usdc_reserve::receive_liquidity(subdao_id, requested_amount);
    } else {
        assert!(liquidity_pool.aleo_usdc_balance >= requested_amount, "Insufficient AleoUSDC");
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

// 🔹 Function: Get Liquidity Pool Balances (Public View)
fn get_liquidity_balances() -> LiquidityPool {
    return liquidity_pool;
}

// 🔹 Event Emitters
event liquidity_assistance_event(subdao_id: Field, requested_token: String, requested_amount: u64);
event swap_event(requester_id: Field, from_token: String, to_token: String, amount: u64);
