# PNW Smart Contract

## Overview
The **Proven Non-Citizen Workers (PNW) Smart Contract** is designed to provide a secure, transparent, and decentralized system for managing migrant worker payroll, employer compliance, and governance through SubDAOs.

This contract ensures:
- **Decentralized payroll processing** with employer prepaid wage requirements.
- **Automated tax compliance**, including employer and worker tax deductions.
- **On-chain compliance tracking** to prevent employer violations.
- **SubDAO governance** for worker wage agreements and employer penalties.
- **Secure identity verification** with optional ZPass integration.

---

## Features
### **Worker Identity System**
- Registers and verifies migrant workers.
- Optional **ZPass integration** for enhanced verification.
- Enables workers to switch payroll preferences between **Aleo USDC** and **EVM USDC**.

### **Payroll System**
- Employers must **prepay wages & taxes** before hiring workers.
- Workers receive payment via **batch payroll processing** to reduce transaction costs.
- Payroll gas fees are covered by **SubDAOs** (Aleo) or **workers** (sidechain payments).

### **Employer Compliance & Taxes**
- Employers must prepay **State/Country employer taxes** before hiring workers.
- A separate **Employer Tax Fund** ensures taxes are tracked separately from payroll.
- SubDAOs handle **automated tax payments** to governments.
- Non-compliant employers face penalties, with **SubDAO voting required before blacklisting**.
- Blacklisted employers can pay a **fine (unpaid taxes + 25%)**, with an additional **25% going to worker-controlled SubDAO funds**.

### **SubDAO Governance**
- SubDAOs vote on **worker wages, employer penalties, and tax discounts**.
- Tax discounts for early compliance start at **1% (votable increase)**.
- **New SubDAOs auto-create** when 100,000 workers are reached across 50 SubDAOs.

### **Bridging & Sidechain Support**
- Supports **EVM chains** for payroll withdrawals.
- Workers can **choose between direct settlement (faster) or rollups (cheaper)**.
- Rollup batch processing occurs **every 30 minutes automatically**.
- **Government API integration** ensures tax compliance before withdrawals.

---

## Smart Contract Structure
The PNW Smart Contract is structured into multiple **.leo** and **.sol** files, organized as follows:
