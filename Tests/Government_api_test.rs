// 📌 Government API Compliance Test Suite (Rust)
// ✅ Simulates External Government API Calls for Tax Compliance Verification
// ✅ Ensures Employers Must Be Verified Before Payroll Execution

use reqwest;
use serde_json::Value;
use std::time::{SystemTime, UNIX_EPOCH};

// Mock API Endpoint (Replace with actual government API)
const GOVERNMENT_API_URL: &str = "https://mock-government-api.com/verify_tax";

// Function to simulate API request to verify employer tax compliance
async fn verify_employer_tax_compliance(employer_id: u64) -> Result<bool, reqwest::Error> {
    let client = reqwest::Client::new();
    let response = client
        .post(GOVERNMENT_API_URL)
        .json(&serde_json::json!({ "employer_id": employer_id }))
        .send()
        .await?;

    let json: Value = response.json().await?;
    
    // Extract compliance status from API response
    Ok(json["is_compliant"].as_bool().unwrap_or(false))
}

// Test case: Ensure employer is tax compliant before payroll execution
#[tokio::test]
async fn test_government_api_tax_compliance() {
    let employer_id = 3001;

    // Simulate tax compliance check
    let is_compliant = verify_employer_tax_compliance(employer_id).await.unwrap();

    // Print result for debugging
    println!("Employer {} tax compliance status: {}", employer_id, is_compliant);

    // Ensure employer is compliant
    assert!(is_compliant, "Employer failed tax compliance check");
}

// Mock function to get current Unix timestamp
fn current_timestamp() -> u64 {
    SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .unwrap()
        .as_secs()
}

// Test case: Ensure payroll execution is blocked if employer fails tax compliance
#[tokio::test]
async fn test_payroll_execution_blocked_for_non_compliant_employers() {
    let employer_id = 3002;
    let payroll_amount = 15000;

    // Simulate tax compliance check
    let is_compliant = verify_employer_tax_compliance(employer_id).await.unwrap();

    // Employer should not be compliant
    assert!(!is_compliant, "Employer should not be tax compliant");

    // Attempt payroll execution (mocked)
    let payroll_allowed = if is_compliant { payroll_amount } else { 0 };

    // Payroll should be blocked
    assert_eq!(payroll_allowed, 0, "Payroll should not be processed for non-compliant employers");
}

// Test case: Ensure payroll is allowed after compliance verification
#[tokio::test]
async fn test_payroll_execution_allowed_after_compliance() {
    let employer_id = 3003;
    let payroll_amount = 18000;

    // Simulate employer paying taxes (mock API update)
    println!("Simulating tax payment for Employer ID: {}", employer_id);

    // Simulate government API verification
    let is_compliant = verify_employer_tax_compliance(employer_id).await.unwrap();

    // Ensure employer is now compliant
    assert!(is_compliant, "Employer should be tax compliant after payment");

    // Mock payroll execution check
    let payroll_allowed = if is_compliant { payroll_amount } else { 0 };

    // Payroll should be processed successfully
    assert_eq!(payroll_allowed, payroll_amount, "Payroll should be executed for compliant employer");
  }
