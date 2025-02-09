program math_utils.leo;

/// Computes the percentage of a given value.
/// `amount * percent / 100`
function compute_percentage(amount: u64, percent: u64) -> u64 {
    let result: u64 = (amount * percent) / 100u64;
    return result;
}

/// Computes the percentage with fixed-point precision (supports decimal percentages).
/// Uses `scale_factor` to represent decimal values (e.g., 1.5% is represented as `15` with `scale_factor = 10`).
/// Formula: `amount * percent / (100 * scale_factor)`
function compute_percentage_fixed(amount: u64, percent: u64, scale_factor: u64) -> u64 {
    let result: u64 = (amount * percent) / (100u64 * scale_factor);
    return result;
}

/// Rounds a value to the nearest multiple of `round_to` (e.g., nearest 10, 100, etc.).
function round_to_nearest(value: u64, round_to: u64) -> u64 {
    let remainder: u64 = value % round_to;
    if remainder * 2u64 >= round_to {
        return value + (round_to - remainder);
    } else {
        return value - remainder;
    }
}

/// Multiplies two numbers with overflow protection.
/// Ensures that the result does not exceed the maximum `u64` value.
function safe_multiply(a: u64, b: u64) -> u64 {
    assert!(a == 0u64 || b <= (u64::MAX / a), "Multiplication overflow");
    return a * b;
}

/// Divides two numbers with underflow protection.
/// Prevents division by zero.
function safe_divide(numerator: u64, denominator: u64) -> u64 {
    assert!(denominator != 0u64, "Division by zero error");
    return numerator / denominator;
}

/// Converts a fixed-point decimal (with `scale_factor`) back to an integer.
/// Example: If `value = 150` and `scale_factor = 10`, the output is `15`.
function convert_fixed_to_integer(value: u64, scale_factor: u64) -> u64 {
    return value / scale_factor;
}

/// Computes compound interest.
/// Formula: `principal * (1 + rate / 100)^time`
function compute_compound_interest(principal: u64, rate: u64, time: u64) -> u64 {
    let mut result: u64 = principal;
    for _ in 0..time {
        result += (result * rate) / 100u64;
    }
    return result;
}

/// Checks if a number is within a valid range (min, max).
function is_within_range(value: u64, min: u64, max: u64) -> bool {
    return value >= min && value <= max;
}

/// Calculates employer tax deduction.
/// `payroll_amount * tax_rate / 100`
function calculate_tax(payroll_amount: u64, tax_rate: u64) -> u64 {
    return (payroll_amount * tax_rate) / 100u64;
}

/// Calculates worker staking fees based on the user’s ZPass status.
/// Uses different rates: **1% for ZPass users, 2% for non-ZPass users**.
function calculate_staking_fee(amount: u64, is_zpass_verified: bool) -> u64 {
    let fee_rate: u64 = if is_zpass_verified { 1u64 } else { 2u64 };
    return (amount * fee_rate) / 100u64;
}
