program helpers.leo;


/// Validates a worker's identity based on a provided ID format.
/// This can be modified to incorporate **ZPass verification** in the future.
function validate_worker_id(worker_id: u64) -> bool {
    return worker_id > 1000000000u64; // Ensuring ID follows a valid numerical range.
}

/// Converts a boolean value to a u64 (1 = true, 0 = false).
function bool_to_u64(value: bool) -> u64 {
    return if value { 1u64 } else { 0u64 };
}

/// Converts a u64 value to a boolean (0 = false, all other values = true).
function u64_to_bool(value: u64) -> bool {
    return value != 0u64;
}

/// Converts an address to a shortened format (for display purposes).
/// Example: `aleo1xyz...abcd` → `aleo1xyz***abcd`
function shorten_address(addr: address) -> string {
    let addr_str: string = address_to_string(addr);
    return addr_str[0..6] + "***" + addr_str[-4..]; // Displaying first 6 and last 4 characters.
}

/// Ensures that an input value does not exceed a certain length.
/// Can be used for string-based worker metadata or IDs.
function validate_length(input: string, max_length: u64) -> bool {
    return input.len() <= max_length;
}

/// Converts an Aleo `address` to a string representation.
function address_to_string(addr: address) -> string {
    return addr.to_string();
}

/// Computes a unique hash ID from an input string.
/// Useful for **creating worker or employer records**.
function generate_hash_id(input: string) -> u64 {
    return hash_to_u64(input);
}

/// Checks if an employer is **eligible for hiring workers** based on their compliance score.
/// Employers with a compliance score below `min_score` are restricted.
function is_eligible_employer(compliance_score: u64, min_score: u64) -> bool {
    return compliance_score >= min_score;
}

/// Calculates the difference between two timestamps (in seconds).
/// This can be used for **worker tenure tracking** or **contract expiry checks**.
function time_difference(start_time: u64, end_time: u64) -> u64 {
    return if end_time > start_time { end_time - start_time } else { 0u64 };
}

/// Ensures a numeric input falls within an allowed range.
/// Example: **Validating payroll amounts, investment caps, or worker hours.**
function enforce_range(value: u64, min: u64, max: u64) -> u64 {
    assert!(value >= min && value <= max, "Value out of allowed range");
    return value;
}

/// Combines two u64 values into a single unique identifier.
/// This is useful for **mapping payroll records, contracts, or SubDAO transactions.**
function combine_ids(id1: u64, id2: u64) -> u64 {
    return (id1 << 32) | (id2 & 0xFFFFFFFFu64);
}

/// Converts a string input to uppercase.
/// Ensures uniform formatting for **worker names, farm types, or employer records**.
function to_uppercase(input: string) -> string {
    return input.to_uppercase();
}
