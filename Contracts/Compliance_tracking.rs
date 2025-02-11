// 📌 Compliance Tracking Backend (Rust)
// ✅ Verifies Employer Compliance Before Payroll Execution
// ✅ Tracks Real-Time Tax Payments & Payroll Funding Status

use actix_web::{post, web, App, HttpResponse, HttpServer, Responder};
use serde::{Deserialize, Serialize};
use std::collections::HashMap;
use std::sync::Mutex;

// Mock storage for employer compliance records
struct AppState {
    employer_compliance: Mutex<HashMap<u64, bool>>, // Employer compliance status
    employer_taxes: Mutex<HashMap<u64, u64>>, // Employer tax payments
    employer_payroll_funds: Mutex<HashMap<u64, u64>>, // Employer payroll funding status
}

// Struct for employer verification requests
#[derive(Deserialize)]
struct EmployerRequest {
    employer_id: u64,
}

// Struct for employer compliance response
#[derive(Serialize)]
struct ComplianceResponse {
    employer_id: u64,
    is_compliant: bool,
}

// Simulated function to check employer compliance status
#[post("/check_compliance")]
async fn check_compliance(
    data: web::Data<AppState>,
    request: web::Json<EmployerRequest>,
) -> impl Responder {
    let employer_id = request.employer_id;
    let compliance_status = data
        .employer_compliance
        .lock()
        .unwrap()
        .get(&employer_id)
        .copied()
        .unwrap_or(false);

    HttpResponse::Ok().json(ComplianceResponse {
        employer_id,
        is_compliant: compliance_status,
    })
}

// Simulated function to update employer tax payments
#[post("/update_tax_payment")]
async fn update_tax_payment(
    data: web::Data<AppState>,
    request: web::Json<EmployerRequest>,
) -> impl Responder {
    let employer_id = request.employer_id;
    let mut tax_db = data.employer_taxes.lock().unwrap();

    // Simulate tax payment update
    let new_total = tax_db.entry(employer_id).or_insert(0);
    *new_total += 15000; // Example: Employer pays 15,000 in taxes

    // Update compliance status
    let mut compliance_db = data.employer_compliance.lock().unwrap();
    compliance_db.insert(employer_id, true);

    HttpResponse::Ok().body(format!(
        "Employer {} has updated tax payment. New total: {}",
        employer_id, new_total
    ))
}

// Simulated function to update employer payroll funding
#[post("/update_payroll_funding")]
async fn update_payroll_funding(
    data: web::Data<AppState>,
    request: web::Json<(u64, u64)>, // (employer_id, payroll_funds)
) -> impl Responder {
    let (employer_id, payroll_funds) = *request;

    let mut payroll_db = data.employer_payroll_funds.lock().unwrap();
    payroll_db.insert(employer_id, payroll_funds);

    HttpResponse::Ok().body(format!(
        "Employer {} payroll funding updated to {}",
        employer_id, payroll_funds
    ))
}

// Simulated function to enforce penalties for non-compliance
#[post("/enforce_penalty")]
async fn enforce_penalty(
    data: web::Data<AppState>,
    request: web::Json<EmployerRequest>,
) -> impl Responder {
    let employer_id = request.employer_id;
    let mut compliance_db = data.employer_compliance.lock().unwrap();

    // If employer is non-compliant, issue penalty
    if !compliance_db.get(&employer_id).copied().unwrap_or(false) {
        let mut tax_db = data.employer_taxes.lock().unwrap();
        let penalty = 5000; // Example: $5000 penalty for non-compliance
        *tax_db.entry(employer_id).or_insert(0) -= penalty;

        HttpResponse::Ok().body(format!(
            "Employer {} penalized. Tax balance adjusted by -{}",
            employer_id, penalty
        ))
    } else {
        HttpResponse::Ok().body(format!(
            "Employer {} is compliant. No penalty applied.",
            employer_id
        ))
    }
}

// Start the Compliance Tracking API server
#[actix_web::main]
async fn main() -> std::io::Result<()> {
    let app_state = web::Data::new(AppState {
        employer_compliance: Mutex::new(HashMap::new()),
        employer_taxes: Mutex::new(HashMap::new()),
        employer_payroll_funds: Mutex::new(HashMap::new()),
    });

    println!("🚀 Compliance Tracking API Server Running on TBD");

    HttpServer::new(move || {
        App::new()
            .app_data(app_state.clone())
            .service(check_compliance)
            .service(update_tax_payment)
            .service(update_payroll_funding)
            .service(enforce_penalty)
    })
    .bind("TBD")?
    .run()
    .await
}
