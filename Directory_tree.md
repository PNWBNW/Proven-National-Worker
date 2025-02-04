# Proven National Worker (PNW) Smart Contract System  

## **Project Structure**  

```plaintext
PNW-Smart-Contract/
├── contracts/
│   ├── aleo/
│   │   ├── main.leo
│   │   ├── worker_identity.leo
│   │   ├── employer_agreement.leo
│   │   ├── payroll.leo
│   │   ├── farm_investment.leo
│   │   ├── merkle_helper.leo
│   │   ├── merkle_decision_maker.leo
│   │   └── zk_verifier.leo
│   ├── solidity/
│   │   ├── PNWbridgepayroll.sol
│   │   ├── employer_contract.sol
│   │   ├── worker_contract.sol
│   │   └── staking_contract.sol
│   └── rust/
│       ├── stellar_integration.rs
│       ├── farm_investment.rs
│       ├── payroll_rs.rs
│       ├── worker_identity_rs.rs
│       └── zpass_rs.rs
├── scripts/
│   ├── deploy.sh
│   ├── run_tests.sh
│   ├── compile.sh
│   └── verify_zpass.sh
├── tests/
│   ├── aleo_tests/
│   │   ├── main_test.leo
│   │   ├── farm_investment_test.leo
│   │   ├── worker_identity_test.leo
│   │   └── employer_agreement_test.leo
│   ├── solidity_tests/
│   │   ├── PNWbridgepayroll_test.sol
│   │   ├── employer_contract_test.sol
│   │   └── worker_contract_test.sol
│   └── rust_tests/
│       ├── stellar_integration_test.rs
│       ├── farm_investment_test.rs
│       ├── payroll_test.rs
│       ├── worker_identity_test.rs
│       └── zpass_test.rs
├── docs/
│   ├── whitepaper.md
│   ├── readme.md
│   ├── architecture.md
│   └── changelog.md
├── .gitignore
└── LICENSE
