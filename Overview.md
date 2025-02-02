# Proven Non-Citizen Workers (PNW) Smart Contract - Overview  

## Introduction  
The **Proven Non-Citizen Workers (PNW) Smart Contract** is a decentralized system designed to facilitate fair, transparent, and compliant employment for migrant workers. It ensures secure payroll processing, employer accountability, and worker protections while integrating with government APIs for compliance enforcement.  

---

## Key Objectives  
- **Ensure fair wages** by requiring employers to prepay worker salaries and taxes.  
- **Enhance compliance** by tracking employer payments and enforcing penalties.  
- **Facilitate decentralized governance** through SubDAO voting on wage rates and employer penalties.  
- **Streamline payroll** with batch processing, bridging, and automated tax payments.  
- **Improve worker protections** with on-chain reporting and compliance verification.  

---

## System Components  

### **1. Worker Identity & Payroll**  
- Workers are registered on-chain with optional **ZPass verification**.  
- Payroll is managed via **batch processing** to reduce transaction costs.  
- Workers can choose between **Aleo USDC** or **bridged USDC (EVM chains)** for payments.  
- Employers **must prepay wages and taxes** before hiring workers.  

### **2. Employer Compliance & Taxation**  
- Employers are required to **prepay State/Country taxes** before hiring workers.  
- A **separate Employer Tax Fund** tracks tax obligations separately from payroll.  
- **SubDAOs automatically process tax payments** to the appropriate authorities.  
- Employers who fail to comply face penalties, including **fines and blacklisting**.  
- **Blacklisted employers must pay unpaid taxes + 25% fine** (with an extra 25% going to worker-controlled SubDAO funds).  

### **3. SubDAO Governance**  
- Each SubDAO votes on **wage rates, tax discounts, and employer penalties**.  
- Early tax compliance **earns discounts (starting at 1%, votable by SubDAOs)**.  
- New SubDAOs **automatically generate** when worker limits reach 100,000 across 50 existing SubDAOs.  

### **4. Cross-Chain Bridging & Government API Integration**  
- Supports **EVM-based payroll withdrawals** with direct or rollup processing.  
- Workers can choose **fast settlements (higher fees) or rollups (cheaper, slower)**.  
- Rollups are **automatically processed every 30 minutes**.  
- Government APIs are integrated to **verify tax compliance before withdrawals**.  

---

## Compliance & Security Features  
- **Zero-Knowledge Proofs (ZKP)** ensure privacy while proving compliance.  
- **Automated tax tracking** prevents employer underpayment.  
- **On-chain compliance history** logs employer tax records and violations.  
- **SubDAO-controlled penalty system** enforces fair consequences for non-compliance.  

---

## Future Roadmap  
- **Multi-currency payroll support** (Stablecoins, CBDCs).  
- **Advanced compliance automation** using AI-based tracking.  
- **Expansion to more jurisdictions** for global migrant worker support.  

---

### **License**  
The PNW Smart Contract is released under a **proprietary license** and is not open-source.  

---
