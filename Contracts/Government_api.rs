// 📌 Government API Backend (Rust)
// ✅ Handles External Tax Compliance Checks for Employers
// ✅ Integrates with Aleo Payroll System for Verification

use actix_web::{post, web, App, HttpResponse, HttpServer, Responder};
use serde::{Deserialize, Serialize};
use std::collections::HashMap;
use std::sync::Mutex;

// Mock database for employer tax records
struct AppState {
    employer_taxes: Mutex<HashMap<u64, u64>>, // Stores tax payments
}

// Struct for incoming employer verification requests
#[derive(Deserialize)]
struct EmployerRequest {
    employer_id: u64,
}

// Struct for employer tax compliance response
#[derive(Serialize)]
struct ComplianceResponse {
    employer_id: u64,
    is_compliant: bool,
}

// Simulated government API function to verify employer tax compliance
#[post("/verify_tax")]
async fn verify_tax(
    data: web::Data<AppState>,
    request: web::Json<EmployerRequest>,
) -> impl Responder {
    let employer_id = request.employer_id;
    let taxes_paid = data.employer_taxes.lock().unwrap().get(&employer_id).copied().unwrap_or(0);

    // Simulated tax compliance threshold
    let required_taxes = 10000; // Example required tax amount
    let is_compliant = taxes_paid >= required_taxes;

    HttpResponse::Ok().json(ComplianceResponse {
        employer_id,
        is_compliant,
    })
}

// Simulated endpoint for employers to pay taxes
#[post("/pay_taxes")]
async fn pay_taxes(
    data: web::Data<AppState>,
    request: web::Json<EmployerRequest>,
) -> impl Responder {
    let employer_id = request.employer_id;
    let mut tax_db = data.employer_taxes.lock().unwrap();

    // Simulate tax payment
    let new_total = tax_db.entry(employer_id).or_insert(0);
    *new_total += 12000; // Employer pays 12,000 in taxes

    HttpResponse::Ok().body(format!(
        "Employer {} has paid taxes. New balance: {}",
        employer_id, new_total
    ))
}

// Start the government API server
#[actix_web::main]
async fn main() -> std::io::Result<()> {
    let app_state = web::Data::new(AppState {
        employer_taxes: Mutex::new(HashMap::new()),
    });

    println!("🚀 Government API Server Running on http://127.0.0.1:8080");

    HttpServer::new(move || {
        App::new()
            .app_data(app_state.clone())
            .service(verify_tax)
            .service(pay_taxes)
    })
    .bind("127.0.0.1:8080")?
    .run()
    .await
}
