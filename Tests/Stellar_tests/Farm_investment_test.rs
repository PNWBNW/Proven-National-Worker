#[cfg(test)]
mod farm_investment_tests {
    use soroban_sdk::{testutils::Address as _, Address, Env, Symbol, Vec};

    use crate::{FarmInvestmentContract, FarmInvestmentClient};

    #[test]
    fn test_farm_investment_creation() {
        let env = Env::default();
        let admin = Address::generate(&env);
        let farmer = Address::generate(&env);
        let contract_id = env.register_contract(None, FarmInvestmentContract);
        let client = FarmInvestmentClient::new(&env, &contract_id);

        client.initialize(&admin);

        let investment_amount: u64 = 100_000;
        let duration_months: u32 = 12;

        client.invest(&farmer, investment_amount, duration_months);

        let details = client.get_investment_details(&farmer);

        assert_eq!(details.amount, investment_amount);
        assert_eq!(details.duration, duration_months);
        assert!(details.start_time > 0);
    }

    #[test]
    fn test_farm_investment_withdrawal() {
        let env = Env::default();
        let admin = Address::generate(&env);
        let farmer = Address::generate(&env);
        let contract_id = env.register_contract(None, FarmInvestmentContract);
        let client = FarmInvestmentClient::new(&env, &contract_id);

        client.initialize(&admin);

        let investment_amount: u64 = 200_000;
        let duration_months: u32 = 24;

        client.invest(&farmer, investment_amount, duration_months);

        env.ledger().fast_forward(24 * 30 * 86400); // Move forward 24 months

        let initial_balance = client.get_balance(&farmer);
        client.withdraw(&farmer);
        let final_balance = client.get_balance(&farmer);

        assert!(final_balance > initial_balance);
        assert_eq!(client.get_investment_details(&farmer).amount, 0);
    }

    #[test]
    fn test_farm_investment_early_withdrawal_penalty() {
        let env = Env::default();
        let admin = Address::generate(&env);
        let farmer = Address::generate(&env);
        let contract_id = env.register_contract(None, FarmInvestmentContract);
        let client = FarmInvestmentClient::new(&env, &contract_id);

        client.initialize(&admin);

        let investment_amount: u64 = 150_000;
        let duration_months: u32 = 18;

        client.invest(&farmer, investment_amount, duration_months);

        env.ledger().fast_forward(9 * 30 * 86400); // Move forward 9 months

        let penalty_applied = client.withdraw(&farmer);

        assert!(penalty_applied);
        assert!(client.get_investment_details(&farmer).amount < investment_amount);
    }

    #[test]
    fn test_farm_investment_delayed_payout() {
        let env = Env::default();
        let admin = Address::generate(&env);
        let farmer = Address::generate(&env);
        let contract_id = env.register_contract(None, FarmInvestmentContract);
        let client = FarmInvestmentClient::new(&env, &contract_id);

        client.initialize(&admin);

        let investment_amount: u64 = 500_000;
        let duration_months: u32 = 36;

        client.invest(&farmer, investment_amount, duration_months);

        env.ledger().fast_forward(36 * 30 * 86400); // Move forward 36 months

        let payout_delay = client.request_payout(&farmer);

        assert!(payout_delay);
        assert_eq!(client.get_payout_status(&farmer), Symbol::new(&env, "Pending"));
    }

    #[test]
    fn test_farm_investment_multiple_stakeholders() {
        let env = Env::default();
        let admin = Address::generate(&env);
        let farmer1 = Address::generate(&env);
        let farmer2 = Address::generate(&env);
        let contract_id = env.register_contract(None, FarmInvestmentContract);
        let client = FarmInvestmentClient::new(&env, &contract_id);

        client.initialize(&admin);

        let investment1: u64 = 120_000;
        let investment2: u64 = 80_000;
        let duration: u32 = 24;

        client.invest(&farmer1, investment1, duration);
        client.invest(&farmer2, investment2, duration);

        let total_investments = client.get_total_investments();
        assert_eq!(total_investments, investment1 + investment2);

        env.ledger().fast_forward(24 * 30 * 86400); // Move forward 24 months

        client.withdraw(&farmer1);
        client.withdraw(&farmer2);

        assert_eq!(client.get_total_investments(), 0);
    }
    }
