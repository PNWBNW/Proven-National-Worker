#[cfg(test)]
mod payroll_tests {
    use soroban_sdk::{testutils::Address as _, Address, Env, Symbol, Vec};

    use crate::{PayrollContract, PayrollClient};

    #[test]
    fn test_payroll_initialization() {
        let env = Env::default();
        let admin = Address::generate(&env);
        let contract_id = env.register_contract(None, PayrollContract);
        let client = PayrollClient::new(&env, &contract_id);

        client.initialize(&admin);

        let stored_admin = client.get_admin();
        assert_eq!(stored_admin, admin);
    }

    #[test]
    fn test_employee_registration() {
        let env = Env::default();
        let admin = Address::generate(&env);
        let employee = Address::generate(&env);
        let contract_id = env.register_contract(None, PayrollContract);
        let client = PayrollClient::new(&env, &contract_id);

        client.initialize(&admin);

        let salary: u64 = 5000;
        client.register_employee(&admin, &employee, salary);

        let details = client.get_employee_details(&employee);
        assert_eq!(details.salary, salary);
        assert_eq!(details.status, Symbol::new(&env, "Active"));
    }

    #[test]
    fn test_payroll_processing() {
        let env = Env::default();
        let admin = Address::generate(&env);
        let employee = Address::generate(&env);
        let contract_id = env.register_contract(None, PayrollContract);
        let client = PayrollClient::new(&env, &contract_id);

        client.initialize(&admin);

        let salary: u64 = 7500;
        client.register_employee(&admin, &employee, salary);

        env.ledger().fast_forward(30 * 86400); // Advance by one month

        let initial_balance = client.get_balance(&employee);
        client.process_payroll();
        let final_balance = client.get_balance(&employee);

        assert!(final_balance > initial_balance);
    }

    #[test]
    fn test_payroll_batch_processing() {
        let env = Env::default();
        let admin = Address::generate(&env);
        let employee1 = Address::generate(&env);
        let employee2 = Address::generate(&env);
        let contract_id = env.register_contract(None, PayrollContract);
        let client = PayrollClient::new(&env, &contract_id);

        client.initialize(&admin);

        let salary1: u64 = 6000;
        let salary2: u64 = 8000;

        client.register_employee(&admin, &employee1, salary1);
        client.register_employee(&admin, &employee2, salary2);

        env.ledger().fast_forward(30 * 86400); // Move forward by one month

        let initial_balance_1 = client.get_balance(&employee1);
        let initial_balance_2 = client.get_balance(&employee2);

        client.process_batch_payroll(Vec::from_array(&env, &[employee1.clone(), employee2.clone()]));

        let final_balance_1 = client.get_balance(&employee1);
        let final_balance_2 = client.get_balance(&employee2);

        assert!(final_balance_1 > initial_balance_1);
        assert!(final_balance_2 > initial_balance_2);
    }

    #[test]
    fn test_employee_deregistration() {
        let env = Env::default();
        let admin = Address::generate(&env);
        let employee = Address::generate(&env);
        let contract_id = env.register_contract(None, PayrollContract);
        let client = PayrollClient::new(&env, &contract_id);

        client.initialize(&admin);

        let salary: u64 = 5000;
        client.register_employee(&admin, &employee, salary);

        client.deregister_employee(&admin, &employee);

        let details = client.get_employee_details(&employee);
        assert_eq!(details.status, Symbol::new(&env, "Inactive"));
    }

    #[test]
    fn test_withholding_taxes() {
        let env = Env::default();
        let admin = Address::generate(&env);
        let employee = Address::generate(&env);
        let contract_id = env.register_contract(None, PayrollContract);
        let client = PayrollClient::new(&env, &contract_id);

        client.initialize(&admin);

        let salary: u64 = 9000;
        let tax_rate: u64 = 10; // 10% withholding tax
        client.register_employee(&admin, &employee, salary);
        client.set_tax_rate(&admin, tax_rate);

        env.ledger().fast_forward(30 * 86400); // Move forward by one month

        let tax_amount = (salary * tax_rate) / 100;
        let expected_salary_after_tax = salary - tax_amount;

        client.process_payroll();
        let details = client.get_employee_details(&employee);

        assert_eq!(details.last_salary_paid, expected_salary_after_tax);
    }

    #[test]
    fn test_insufficient_funds_handling() {
        let env = Env::default();
        let admin = Address::generate(&env);
        let employee = Address::generate(&env);
        let contract_id = env.register_contract(None, PayrollContract);
        let client = PayrollClient::new(&env, &contract_id);

        client.initialize(&admin);

        let salary: u64 = 50_000_000; // Exceeding available balance
        client.register_employee(&admin, &employee, salary);

        env.ledger().fast_forward(30 * 86400); // Move forward by one month

        let payroll_result = client.process_payroll();

        assert_eq!(payroll_result, Symbol::new(&env, "Insufficient Funds"));
    }
}
