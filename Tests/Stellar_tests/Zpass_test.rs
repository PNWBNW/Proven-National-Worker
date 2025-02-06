#![no_std]

use soroban_sdk::{contract, contractimpl, Env, Address, BytesN, Map};

#[contract]
pub struct ZPassTestContract;

#[derive(Clone)]
pub struct WorkerVerification {
    worker: Address,
    zk_proof: BytesN<32>,
    kyc_verified: bool,
}

#[contractimpl]
impl ZPassTestContract {
    // Test ZPass worker registration
    pub fn test_worker_registration(env: Env, worker: Address, zk_proof: BytesN<32>) -> bool {
        let mut verification_records: Map<Address, WorkerVerification> = env.storage().persistent().get().unwrap_or_default();

        verification_records.set(worker.clone(), WorkerVerification {
            worker: worker.clone(),
            zk_proof: zk_proof.clone(),
            kyc_verified: false,
        });

        env.storage().persistent().set(&verification_records);
        return true;
    }

    // Test KYC verification through ZPass
    pub fn test_kyc_verification(env: Env, worker: Address, zk_proof: BytesN<32>) -> bool {
        let mut verification_records: Map<Address, WorkerVerification> = env.storage().persistent().get().unwrap_or_default();
        let mut record = verification_records.get(&worker).expect("Worker not found");

        assert!(record.zk_proof == zk_proof, "Zero-knowledge proof does not match");
        
        record.kyc_verified = true;
        verification_records.set(worker.clone(), record);
        env.storage().persistent().set(&verification_records);

        return true;
    }

    // Test worker eligibility for payroll after KYC
    pub fn test_worker_eligibility_for_payroll(env: Env, worker: Address) -> bool {
        let verification_records: Map<Address, WorkerVerification> = env.storage().persistent().get().unwrap_or_default();
        let record = verification_records.get(&worker).expect("Worker not found");

        assert!(record.kyc_verified, "Worker is not KYC verified");
        return true;
    }

    // Test worker eligibility for staking rewards
    pub fn test_worker_eligibility_for_staking_rewards(env: Env, worker: Address) -> bool {
        let verification_records: Map<Address, WorkerVerification> = env.storage().persistent().get().unwrap_or_default();
        let record = verification_records.get(&worker).expect("Worker not found");

        assert!(record.kyc_verified, "Worker is not KYC verified");
        return true;
    }
}
