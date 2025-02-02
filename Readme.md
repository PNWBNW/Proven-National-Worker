# PNW Smart Contract System

## Overview
The **Proven Non-Citizen Workers (PNW) Smart Contract System** is a decentralized, privacy-preserving payroll and governance framework built on **Aleo**, with **EVM** and **Stellar** network integrations for cross-chain payroll processing. It enables **migrant workers** to receive wages securely, ensures **employer compliance with tax laws**, and leverages **zero-knowledge proofs (ZKPs)** to verify work and payment history without exposing sensitive data.

This system is designed to be **tamper-resistant, auditable, and fair**, preventing **exploitative employment practices** while empowering workers with **on-chain governance mechanisms** via **SubDAOs**.

---

## Key Features

### 1️⃣ Worker Identity & Verification
- **Self-sovereign identity**: Workers are issued **non-transferable NFTs** to verify work history.
- **ZPass Integration (Optional)**: Workers can verify identity using ZPass for **enhanced benefits** (higher trust fund APY, priority payroll processing).

### 2️⃣ Payroll Processing
- **Batch payroll execution** to lower gas fees.
- **Workers choose between Aleo USDC or Bridged USDC** (EVM chains).
- **Automated tax deductions & compliance tracking** before payroll disbursement.
- **Employers must pre-fund payroll & taxes** to continue hiring.

### 3️⃣ Employer Compliance & Tax Automation
- **Employer Tax Fund**: Tracks tax payments **separately** from payroll.
- **Automated Tax Payments**: SubDAOs remit taxes to state/country agencies upon payroll execution.
- **Tax Discounts for Early Compliance**: Starting at **1% (votable by SubDAO to increase)**.
- **Compliance Verification System**: Tracks employer tax payments and flags missed payments.
- **Blacklist for Chronic Offenders**: Employers missing **3+ tax payments** require SubDAO voting for reinstatement.
- **Reinstatement Fine**: **Unpaid fees + 25%**, with **an additional 25% to the SubDAO fund**.

### 4️⃣ SubDAO Governance
- **SubDAO Creation**: Automatic when worker limits (**100,000 workers across 50 SubDAOs**) are reached.
- **Employer Penalties Voted by SubDAOs** instead of relying solely on government action.
- **Worker-Driven Fund Allocation**: SubDAOs vote on how to use worker-generated funds.

### 5️⃣ Cross-Chain Payroll & Interoperability
- **Aleo → EVM Bridge**: Supports **EVM chains** instead of Solana.
- **Bridging Fees Paid by Workers** (Rollups enabled for cost reduction).
- **Rollup Batch Processing Every 30 Minutes** for cheaper transactions.
- **Aleo ↔ Stellar Interoperability**: Zero-knowledge proofs (ZKPs) verify Aleo payroll before Stellar executes payments.
- **Stellar as an Optional Payroll Network** for stablecoin-based payments.

---

## Contracts & Components

### **Aleo Contracts**
- `main.leo` – Core contract for PNW system.
- `payroll.leo` – Handles wage distribution.
- `worker_identity.leo` – Manages worker verification.
- `compliance_tracking.leo` – Employer tax tracking.
- `government_api.leo` – Integration for labor agencies.
- `subdao_management.leo` – Handles SubDAO creation & governance.
- `employer_agreement.leo` – Employer compliance enforcement.

### **Solidity (EVM) Contracts**
- `PNWbridgepayroll.sol` – Bridges payroll from Aleo to EVM.
- `IERC20.sol` – Standard ERC-20 interface.
- `IAleoVerifier.sol` – Validates Aleo ZKPs on EVM.
- `Igovtaxapi.sol` – Government tax API integration.

### **Stellar Soroban Contracts**
- `stellar_verifier.rs` – Verifies ZK payroll proofs.
- `stellar_integration.rs` – Processes Stellar payroll transactions.

### **Deployment & Integration**
- `deploy_main.leo` – Deploys Aleo contracts.
- `deploy_subdao.leo` – Initializes new SubDAOs.
- `deployment_script.sh` – Deploys Stellar Soroban contract.
- `network.json` – Stores blockchain network configurations.

---

## Getting Started

### **Requirements**
- **Aleo** development environment.
- **Solidity 0.8.20** for EVM compatibility.
- **Rust & Soroban SDK** for Stellar integration.

### **Deployment**
1. Deploy **Aleo contracts** using:
   ```sh
   leo run deploy_main
