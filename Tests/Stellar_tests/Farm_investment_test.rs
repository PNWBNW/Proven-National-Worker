#[cfg(test)]
mod farm_investment_tests {
    use super::*;
    use soroban_sdk::{testutils::Address as _, Address, Env};

    #[test]
    fn test_farm_investment_creation() {
        let env = Env::default();
        let admin = Address::random(&env);
        let farmer = Address::random(&env);
        let contract_id = env.register_contract(None, FarmInvestmentContract);
        let client = FarmInvestmentClient::new(&env, &contract_id);

        client.initialize(&admin);

        let investment_amount = 100_000u64;
        let duration_months = 12u32;

        client.invest(&farmer, &investment_amount, &duration_months);

        let details = client.get_investment_details(&farmer);

        assert_eq!(details.amount, investment_amount);
        assert_eq!(details.duration, duration_months);
        assert!(details.start_time > 0);
    }

    #[test]
    fn test_farm_investment_withdrawal() {
        let env = Env::default();
        let admin = Address::random(&env);
        let farmer = Address::random(&env);
        let contract_id = env.register_contract(None, FarmInvestmentContract);
        let client = FarmInvestmentClient::new(&env, &contract_id);

        client.initialize(&admin);

        let investment_amount = 200_000u64;
        let duration_months = 24u32;

        client.invest(&farmer, &investment_amount, &duration_months);

        env.advance_time_by(24 * 30 * 86400); // Advance 24 months in seconds

        let initial_balance = client.get_balance(&farmer);
        client.withdraw(&farmer);
        let final_balance = client.get_balance(&farmer);

        assert!(final_balance > initial_balance);
        assert_eq!(client.get_investment_details(&farmer).amount, 0);
    }

    #[test]
    fn test_farm_investment_early_withdrawal_penalty() {
        let env = Env::default();
        let admin = Address::random(&env);
        let farmer = Address::random(&env);
        let contract_id = env.register_contract(None, FarmInvestmentContract);
        let client = FarmInvestmentClient::new(&env, &contract_id);

        client.initialize(&admin);

        let investment_amount = 150_000u64;
        let duration_months = 18u32;

        client.invest(&farmer, &investment_amount, &duration_months);

        env.advance_time_by(9 * 30 * 86400); // Advance 9 months in seconds

        let penalty_applied = client.withdraw(&farmer);

        assert!(penalty_applied);
        assert!(client.get_investment_details(&farmer).amount < investment_amount);
    }

    #[test]
    fn test_farm_investment_delayed_payout() {
        let env = Env::default();
        let admin = Address::random(&env);
        let farmer = Address::random(&env);
        let contract_id = env.register_contract(None, FarmInvestmentContract);
        let client = FarmInvestmentClient::new(&env, &contract_id);

        client.initialize(&admin);

        let investment_amount = 500_000u64;
        let duration_months = 36u32;

        client.invest(&farmer, &investment_amount, &duration_months);

        env.advance_time_by(36 * 30 * 86400); // Advance 36 months in seconds

        let payout_delay = client.request_payout(&farmer);

        assert!(payout_delay);
        assert_eq!(client.get_payout_status(&farmer), "Pending");
    }
      } 
