# Proven National Workers (PNW) System  
A **decentralized payroll, compliance, and governance** solution for **Proven National Citizen Workers (PNcW)** and **Proven National Immigrant Workers (PNiW)**. The system integrates **Aleo, Stellar Soroban, and EVM-based smart contracts** to ensure **worker rights, payroll automation, and tax compliance**.

---

## 🔹 Key Features  

✔ **Payroll Processing** – Supports **PNcW & PNiW workers** through **automated, auditable payroll execution**.  
✔ **Employer Compliance** – Tracks **tax contributions, payroll deposits, and employer reputation**.  
✔ **Worker Trust Pools** – Worker earnings **locked until child KYC verification (at age 18)**.  
✔ **Zero-Knowledge (ZK) Verification** – Privacy-preserving **identity & payroll validation**.  
✔ **Cross-Chain Payroll Settlement** – **Aleo, Stellar, and EVM interoperability** for secure fund transfers.  

---

## 📌 Technical Architecture  

The **PNW System** leverages **Zero-Knowledge Proofs (ZK)** and **cross-chain payroll processing** to ensure **decentralized and auditable employment practices**.  

### **🔹 Smart Contract Integrations**  
| Component        | Network   | Smart Contract |
|-----------------|-----------|----------------|
| **Worker Identity** | Stellar | `worker_identity.rs` |
| **Payroll Processing** | EVM | `pncw_payroll.sol`, `pniw_payroll.sol` |
| **Employer Compliance** | EVM | `employer_contract.sol` |
| **Trust Pool Management** | EVM | `pncw_trust_pool.sol`, `pniw_trust_pool.sol` |
| **Cross-Chain Payroll** | Stellar ↔ Aleo | `stellar_integration.rs`, `zk_payroll.rs` |

---

## 🔄 Governance & Compliance  

- **Employer Compliance Tracking** – Employers **must meet tax and payroll obligations** before processing payments.  
- **Decentralized SubDAO Voting** – **SubDAOs govern penalties & compliance enforcement**.  
- **ZK-Proof-Based Worker Verification** – Ensures **workers remain anonymous while proving employment eligibility**.  

---

## 🔹 Payroll & Staking  

- **Payroll Gas Fees** – **SubDAOs cover payroll fees on Aleo**; **workers pay bridging fees** for EVM sidechains.  
- **Employer Prefunding** – Employers must **pre-fund payroll deposits & taxes**.  
- **Staking Rewards** – Initially **employer-funded**, later **sustained by worker fees** (**1% ZPass, 2% non-ZPass**).  

---

## 🔄 Deployment  

### **📌 Running Smart Contracts**  
Ensure dependencies are installed before running:  
```bash
sh deploy_scripts/run_tests.sh
