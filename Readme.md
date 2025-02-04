# Proven National Workers (PNW) Smart Contract System  

## Overview  
The **PNW Smart Contract System** is a decentralized payroll, governance, and compliance framework for **Proven National Citizen Workers (PNcW)** and **Proven National Immigrant Workers (PNiW)**. It ensures fair, transparent, and regulatory-compliant employment through **on-chain governance, automated payroll, and verifiable identity records**.  

## Key Features  

### **Worker Identity & Verification**  
- **On-chain identity records** for PNcW & PNiW.  
- **Industry-specific verification fields** for job eligibility.  
- **ZPass Integration (Optional)**:  
  - Verified workers get **faster payroll processing**.  
  - Receive **+0.5% APY** on unpaid wages.  
  - Enhanced employer trust and compliance verification.  

### **Payroll & Compliance**  
- Payroll processed **on-chain** with **optional ZPass verification**.  
- Supports **Aleo-native USDC** and **EVM-bridged USDC**.  
- **Aleo ↔ Stellar Payroll Integration**:  
  - Payroll data converted into a **ZK-proof** before being sent to **Soroban (Stellar’s smart contract layer)**.  
  - Soroban verifies **worker identity, employer compliance, and tax payments** before releasing payouts.  
  - Supports **stablecoin payouts** (USDC, EURC) for international workers.  
  - Future automation: **holding funds until tax compliance confirmation**.  
- Employers must prepay **wages & taxes** before hiring workers.  

### **SubDAO Governance**  
- Workers are grouped into **SubDAOs** based on industry & region.  
- Each worker gets **one vote** in governance decisions.  
- **Employer tax compliance monitoring** with **automated penalties**.  
- SubDAOs vote on:  
  - **Employer penalties** for non-compliance.  
  - **Fund allocation** for community initiatives.  
  - **Farm investment payouts** (via Merkle validation).  

### **Farm Investments & Payouts**  
- **Unified investment pool** for **PNcW & PNiW farms**.  
- Monthly **payouts on the 1st** using **Merkle proofs** for security.  
- SubDAOs can vote to:  
  - Approve **farm investment payout**.  
  - Redirect payout to **worker identity fund**.  
  - Delay payout if network congestion is high.  
  - Deny payout if fraud is suspected.  

## **Smart Contract Components**  
- **Worker Identity Contract** (`worker_identity.leo`)  
- **Payroll Contract** (`pnw_payroll.leo`)  
- **SubDAO Governance Contract** (`subdao_governance.leo`)  
- **Employer Agreement Contract** (`employer_agreement.leo`)  
- **Farm Investment Contract** (`farm_investment.leo`)  
- **Bridge Payroll Contract** (`pnwbridgepayroll.sol`)  
- **Merkle Decision Contract** (`merkle_decision_maker.leo`)  
- **Stellar Integration Contract** (`stellar_payroll.leo`)  

## **Deployment & Testing**  
- **Batch deployment** of all contracts.  
- **Automated testing scripts** for payroll, identity, and governance.  
- **Run `run_tests.sh` before deploying to mainnet**.  

## **Contributors**  
- **Developer**: Joshua Daniel Day  
- **Advisors**: Aleo Team  

---

### **Review & Next Steps**
✅ Stellar integration + ZPass incentives added.  
✅ SubDAO farm investment payout logic updated.  
✅ Payroll compliance & governance sections refined.  

Would you like to add any **roadmap details** for planned expansions? 🚀
