// 📌 Merkle Decision Maker Backend (Rust)
// ✅ Handles Off-Chain Merkle Proof Verification
// ✅ Simulates Network Health Checks for SubDAO Voting
// ✅ Determines Whether Payouts Should Be Processed

use actix_web::{post, web, App, HttpResponse, HttpServer, Responder};
use serde::{Deserialize, Serialize};
use std::collections::HashMap;
use std::sync::Mutex;
use chrono::prelude::*;

// Mock storage for Merkle roots and network status
struct AppState {
    merkle_roots: Mutex<HashMap<String, String>>, // Stores contract Merkle roots
    last_gas_fee: Mutex<u64>, // Stores last recorded gas fee
    last_network_latency: Mutex<u64>, // Stores last recorded latency
}

// Struct for incoming Merkle verification requests
#[derive(Deserialize)]
struct MerkleRequest {
    contract_name: String,
    merkle_root: String,
}

// Struct for decision-making response
#[derive(Serialize)]
struct DecisionResponse {
    contract_name: String,
    decision: String,
}

// Simulated function to verify Merkle proof and determine payout contract
#[post("/decide_payout_contract")]
async fn decide_payout_contract(
    data: web::Data<AppState>,
    request: web::Json<MerkleRequest>,
) -> impl Responder {
    let contract_name = &request.contract_name;
    let provided_root = &request.merkle_root;
    let mut merkle_roots = data.merkle_roots.lock().unwrap();

    // Retrieve stored Merkle root for comparison
    let stored_root = merkle_roots.get(contract_name).cloned().unwrap_or_default();

    // Determine if Merkle proof is valid
    let valid_proof = stored_root == *provided_root;

    // Simulate network health check
    let gas_fee = *data.last_gas_fee.lock().unwrap();
    let latency = *data.last_network_latency.lock().unwrap();
    let network_healthy = gas_fee < 100 && latency < 500; // Mock thresholds

    let decision = if !network_healthy {
        "Network congestion detected: SubDAO vote required".to_string()
    } else if valid_proof {
        contract_name.clone()
    } else {
        "undecided".to_string()
    };

    HttpResponse::Ok().json(DecisionResponse {
        contract_name: contract_name.clone(),
        decision,
    })
}

// Simulated function to update Merkle root for a contract
#[post("/update_merkle_root")]
async fn update_merkle_root(
    data: web::Data<AppState>,
    request: web::Json<MerkleRequest>,
) -> impl Responder {
    let mut merkle_roots = data.merkle_roots.lock().unwrap();
    merkle_roots.insert(request.contract_name.clone(), request.merkle_root.clone());

    HttpResponse::Ok().body(format!(
        "Merkle root for {} updated successfully",
        request.contract_name
    ))
}

// Simulated function to update network status
#[post("/update_network_status")]
async fn update_network_status(
    data: web::Data<AppState>,
    request: web::Json<(u64, u64)>, // (gas_fee, latency)
) -> impl Responder {
    let (gas_fee, latency) = *request;

    *data.last_gas_fee.lock().unwrap() = gas_fee;
    *data.last_network_latency.lock().unwrap() = latency;

    HttpResponse::Ok().body(format!(
        "Network status updated - Gas Fee: {}, Latency: {}ms",
        gas_fee, latency
    ))
}

// Function to check if today is the 1st of the month (for payout validation)
fn is_payout_day() -> bool {
    let today = Utc::now().day();
    today == 1
}

// Start the Merkle Decision API server
#[actix_web::main]
async fn main() -> std::io::Result<()> {
    let app_state = web::Data::new(AppState {
        merkle_roots: Mutex::new(HashMap::new()),
        last_gas_fee: Mutex::new(50), // Default values
        last_network_latency: Mutex::new(200),
    });

    println!("🚀 Merkle Decision API Server Running on http://127.0.0.1:8081");

    HttpServer::new(move || {
        App::new()
            .app_data(app_state.clone())
            .service(decide_payout_contract)
            .service(update_merkle_root)
            .service(update_network_status)
    })
    .bind("127.0.0.1:8081")?
    .run()
    .await
      }
