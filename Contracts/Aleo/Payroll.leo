// Payroll Smart Contract

// Struct to store payroll details
struct Payroll {
    address employer_address;     // Employer's address
    address worker_address;       // Worker’s address
    u64 wage_amount;              // Wage to be paid to the worker
    u64 total_paid;               // Total amount paid to the worker
    bool is_agriculture_worker;   // Flag to check if worker is an agriculture worker
    u64 farm_investment;          // Investment the worker has made in farms (if any)
}

// Initialize a payroll record
public fun init_payroll(employer_address: address, worker_address: address, wage_amount: u64, is_agriculture_worker: bool): Payroll {
    return Payroll {
        employer_address,
        worker_address,
        wage_amount,
        total_paid = 0,
        is_agriculture_worker,
        farm_investment = 0, // Default to no investment
    };
}

// Function to update the worker’s wage
public fun update_wage(payroll: &mut Payroll, new_wage: u64) {
    payroll.wage_amount = new_wage;
}

// Function to record a payment to a worker
public fun make_payment(payroll: &mut Payroll) {
    payroll.total_paid = payroll.total_paid + payroll.wage_amount;
}

// Function for workers to invest in farm(s) via payroll
public fun invest_in_farm(payroll: &mut Payroll, investment_amount: u64) {
    // Only agricultural workers can invest
    assert(payroll.is_agriculture_worker, 101, "Non-agriculture workers cannot invest in farms.");
    payroll.farm_investment = payroll.farm_investment + investment_amount;
}

// Function to check if the worker has made an investment in the farm
public fun has_invested_in_farm(payroll: &Payroll): bool {
    return payroll.farm_investment > 0;
}

// Function to withdraw investment from the farm (if allowed)
public fun withdraw_farm_investment(payroll: &mut Payroll, withdrawal_amount: u64) {
    // Ensure the worker has enough invested
    assert(payroll.farm_investment >= withdrawal_amount, 102, "Insufficient farm investment to withdraw.");
    payroll.farm_investment = payroll.farm_investment - withdrawal_amount;
}
