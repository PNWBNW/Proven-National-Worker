# Proven National Worker (PNW) System  

## Overview  
The **Proven National Worker (PNW) System** is a decentralized, blockchain-based framework designed to facilitate fair, transparent, and compliant employment for both **Proven National Citizen Workers (PNcW)** and **Proven National Immigrant Workers (PNiW)**. It leverages smart contracts, SubDAO governance, and privacy-preserving zero-knowledge proofs to ensure worker protections, payroll security, and investment accountability.

---

## Core Features  

### **1. Worker Identity & Verification**  
- Workers are issued **PNcW** or **PNiW** NFTs upon verification.  
- Identity verification can be enhanced with **ZPass integration** (optional).  
- Each worker has an **industry-specific verification field**.  

### **2. Payroll & Compliance**  
- Supports payroll in **native Aleo USDC** and **bridged USDC** (switchable).  
- Payroll gas fees:  
  - **Aleo ecosystem** → Covered by SubDAOs.  
  - **Sidechain payrolls** → Covered by workers.  
- **Employer tax fund:** Tracks required tax payments separately.  
- **Automated tax compliance:** Ensures employer tax obligations are met.  
- **Blacklist system:** Employers with 3+ missed tax payments require SubDAO voting for reinstatement.  

### **3. SubDAO Governance**  
- Each worker belongs to a **SubDAO** with **100,000 workers per 50 SubDAOs**.  
- **Voting rights:** Workers can vote on SubDAO fund usage.  
- **Employer penalties:** SubDAOs decide on employer infractions & penalties.  

### **4. Farm Investments & Co-Ops**  
- Farm investments are open to both **PNcW and PNiW**, but payroll and trust pools remain separate.  
- **Farm payouts:** Occur **only on the 1st of each month**.  
- **Merkle validation:** Ensures investment legitimacy using local farm data centers.  
- **SubDAO vote:** Required if network issues or high gas fees arise.  

### **5. Bridge & Interoperability**  
- **EVM-based bridge:** Supports payroll bridging to Ethereum-compatible chains.  
- **Aleo ↔ Stellar integration:** Uses **ZK verification** for secure, on-chain Stellar payroll interoperability.  
- **Rollups for cost efficiency:** Workers can choose between direct settlement (faster) or rollups (cheaper).  

---

## Smart Contract Structure  

### **1. Worker Identity & Governance**  
- `worker_identity.leo` – Handles worker verification, NFT issuance, and governance integration.  
- `subdao_governance.leo` – Manages SubDAO voting, employer penalties, and worker fund decisions.  

### **2. Payroll & Tax Compliance**  
- `payroll_processor.leo` – Executes payroll, tracks taxes, and enforces compliance.  
- `employer_agreement.leo` – Defines employer obligations, tax payments, and penalties.  

### **3. Farm Investments & Payouts**  
- `farm_investments.leo` – Manages farm investment registration and payouts.  
- `merkle_decision_maker.leo` – Verifies farm investments using local merkle trees.  

### **4. Bridging & Interoperability**  
- `pnw_bridgepayroll.sol` – EVM contract handling cross-chain payroll transactions.  
- `zk_verifier.leo` – Enables **Aleo ↔ Stellar payroll verification** using zero-knowledge proofs.  

---

## Deployment & Testing  

### **Deployment Process**  
- **Smart Contracts:** Deployed in a unified manner to ensure system integrity.  
- **Worker Identity & Payroll:** Must be initialized before employer registrations.  
- **Farm Investments:** Deployed after worker identity contracts for seamless integration.  

### **Testing Strategy**  
- **run_tests.sh:** Automates testing of all smart contracts.  
- **Python test scripts:** Validate payroll, tax compliance, and SubDAO voting behavior.  
- **Gas fee simulation:** Ensures transactions remain cost-effective.  

---

## Future Roadmap  

✅ **Phase 1:** Aleo-based Payroll & Compliance  
✅ **Phase 2:** Farm Investments & SubDAO Governance  
✅ **Phase 3:** EVM Payroll Bridge & ZK Interoperability  
🔲 **Phase 4:** Multi-Nation Implementation & Custom Regulations  

---

## Conclusion  
The **PNW System** is a fully on-chain, **worker-first** employment framework designed for **fair wages, transparent governance, and decentralized compliance**. By leveraging **SubDAO voting, zero-knowledge proofs, and blockchain automation**, PNW ensures a **secure, efficient, and scalable** employment solution for both citizens and immigrants worldwide.  

---

## Contributors  
- **Core Developer:** Joshua Daniel Day  
- **Advisors:** Aleo Team  

---

## License  
This project is released under a **proprietary license** and **not open-source**.  

For inquiries about partnerships or contributions, please contact **[Your Contact Info]**.
