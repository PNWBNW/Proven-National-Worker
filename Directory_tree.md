PNW-Smart-Contract/
├── contracts/

│   ├── aleo/

│   │   ├── employer_agreement.leo
│   │   ├── farm_investment.leo
│   │   ├── government_api.leo
│   │   ├── main.leo
│   │   ├── merkle_decision_maker.leo
│   │   ├── merkle_helper.leo
│   │   ├── payroll.leo
│   │   ├── pncw_farm_investment.leo
│   │   ├── pncw_governance.leo
│   │   ├── pncw_payroll.leo
│   │   ├── pncw_trust_pool.leo
│   │   ├── pniw_farm_investment.leo
│   │   ├── pniw_governance.leo
│   │   ├── pniw_payroll.leo
│   │   ├── pniw_trust_pool.leo
│   │   ├── process_tax_compliance.leo
│   │   ├── worker_identity.leo
│   │   ├── zk_verifier.leo

│   ├── solidity/
│   │   ├── employer_contract.sol
│   │   ├── PNWbridgepayroll.sol
│   │   ├── pncw_payroll.sol
│   │   ├── pniw_payroll.sol
│   │   ├── staking_contract.sol
│   │   ├── worker_contract.sol

│   ├── stellar/
│   │   ├── farm_investment.rs
│   │   ├── payroll_rs.rs
│   │   ├── stellar_integration.rs
│   │   ├── worker_identity_rs.rs
│   │   ├── zpass_rs.rs
│   │   ├── pncw_trust_pool.rs
│   │   ├── pniw_trust_pool.rs

├── docs/
│   ├── architecture.md
│   │   ├── changelog.md
│   │   ├── readme.md
│   │   ├── whitepaper.md

├── scripts/
│   ├── compile.sh
│   ├── deploy.sh
│   ├── run_tests.sh
│   ├── verify_zpass.sh

├── tests/
│   ├── aleo_tests/
│   │   ├── employer_agreement_test.leo
│   │   ├── farm_investment_test.leo
│   │   ├── main_test.leo
│   │   ├── pncw_payroll_test.leo
│   │   ├── pniw_payroll_test.leo
│   │   ├── worker_identity_test.leo
│   ├── solidity_tests/
│   │   ├── employer_contract_test.sol
│   │   ├── PNWbridgepayroll_test.sol
│   │   ├── pncw_payroll_test.sol
│   │   ├── pniw_payroll_test.sol
│   │   ├── worker_contract_test.sol
│   ├── stellar_tests/
│   │   ├── farm_investment_test.rs
│   │   ├── payroll_test.rs
│   │   ├── stellar_integration_test.rs
│   │   ├── worker_identity_test.rs
│   │   ├── zpass_test.rs
│   │   ├── pncw_trust_pool_test.rs
│   │   ├── pniw_trust_pool_test.rs
├── .gitignore
└── LICENSE
