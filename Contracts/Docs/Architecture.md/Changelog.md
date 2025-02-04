# PNW System Changelog

## [feb 3,2025]
### Added
- Implemented **PNiW Trust Pool (`pniw_trust_pool.sol`)** with **child KYC-based withdrawals**.
- Integrated **rollup-based batch payroll processing** in `PNWbridgepayroll.sol` and `pniw_payroll.sol` to **reduce gas fees**.
- Added **Stellar Soroban Integration** for **cross-chain payroll verification & processing**.
- Implemented **Zero-Knowledge (ZK) Proofs** for **worker identity & payroll validation** in `zk_payroll.rs`.
- Introduced **fallback KYC verification** in `worker_identity.rs` using **Merkle proofs or Aleo network validation**.

### Updated
- **Refactored `worker_contract.sol`** to track **PNcW & PNiW employment history**.
- Adjusted **staking rewards structure**, transitioning from **employer prefunding to DAO-based funding** once profitable.
- Updated **`stellar_integration.rs`** to include **ZK payroll verification & Stellar SDK integration**.

### Fixed
- Resolved **employer compliance tracking inconsistencies** in `employer_contract.sol`.
- Fixed **data persistence issues** in `pncw_trust_pool.rs`.

---
