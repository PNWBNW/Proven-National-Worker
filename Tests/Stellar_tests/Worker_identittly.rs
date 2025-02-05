#![no_std]
use soroban_sdk::{contract, contractimpl, contracttype, Address, Env, Symbol};

#[contract]
pub struct WorkerIdentityContract;

#[contracttype]
#[derive(Clone, Debug, Eq, PartialEq)]
pub struct WorkerProfile {
    pub industry: Symbol,
    pub verified: bool,
    pub kyc_timestamp: u64,
}

#[contractimpl]
impl WorkerIdentityContract {
    pub fn initialize(env: &Env, admin: Address) {
        env.storage().instance().set(&Symbol::new(env, "admin"), &admin);
    }

    pub fn register_worker(env: &Env, admin: Address, worker: Address, industry: Symbol) {
        let stored_admin: Address = env.storage().instance().get(&Symbol::new(env, "admin")).unwrap();
        assert_eq!(stored_admin, admin, "Unauthorized");

        let profile = WorkerProfile {
            industry,
            verified: false,
            kyc_timestamp: 0,
        };

        env.storage().persistent().set(&worker, &profile);
    }

    pub fn verify_worker(env: &Env, admin: Address, worker: Address, kyc_timestamp: u64) {
        let stored_admin: Address = env.storage().instance().get(&Symbol::new(env, "admin")).unwrap();
        assert_eq!(stored_admin, admin, "Unauthorized");

        let mut profile: WorkerProfile = env.storage().persistent().get(&worker).unwrap();
        profile.verified = true;
        profile.kyc_timestamp = kyc_timestamp;

        env.storage().persistent().set(&worker, &profile);
    }

    pub fn get_worker_profile(env: &Env, worker: Address) -> Option<WorkerProfile> {
        env.storage().persistent().get(&worker)
    }

    pub fn update_industry(env: &Env, admin: Address, worker: Address, industry: Symbol) {
        let stored_admin: Address = env.storage().instance().get(&Symbol::new(env, "admin")).unwrap();
        assert_eq!(stored_admin, admin, "Unauthorized");

        let mut profile: WorkerProfile = env.storage().persistent().get(&worker).unwrap();
        profile.industry = industry;

        env.storage().persistent().set(&worker, &profile);
    }

    pub fn get_admin(env: &Env) -> Address {
        env.storage().instance().get(&Symbol::new(env, "admin")).unwrap()
    }
}
