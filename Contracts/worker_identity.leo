// Worker Identity Smart Contract

// Struct to store Worker Identity details
struct WorkerIdentity {
    address worker_address;     // Unique address of the worker
    string name;               // Name of the worker
    bool is_agriculture_worker; // Flag to identify if the worker is an agricultural worker
    u64 industry_verification;  // Industry-specific verification code
    u64 investable_amount;      // Track total investable amount for the worker
    bool is_eligible_for_investment; // Flag to track if the worker is eligible to invest
    u64 investment_threshold;   // Minimum investment threshold for eligibility
    u64 total_investment;       // Total amount invested by the worker
}

// Initialize a worker identity
public fun init_worker(worker_address: address, name: string, industry_verification: u64, investable_amount: u64): WorkerIdentity {
    let industry_threshold = 1000; // Set the threshold for eligibility to invest
    let is_eligible = investable_amount >= industry_threshold;
    
    return WorkerIdentity {
        worker_address,
        name,
        is_agriculture_worker = false, // Default, change based on worker's sector later
        industry_verification,
        investable_amount,
        is_eligible_for_investment = is_eligible,
        investment_threshold = industry_threshold,
        total_investment = 0,
    };
}

// Update worker's investable amount
public fun update_investable_amount(worker: &mut WorkerIdentity, new_amount: u64) {
    worker.investable_amount = new_amount;
    worker.is_eligible_for_investment = new_amount >= worker.investment_threshold;
}

// Mark worker as an agriculture worker
public fun mark_as_agriculture_worker(worker: &mut WorkerIdentity) {
    worker.is_agriculture_worker = true;
}

// Mark worker as eligible for farm investment
public fun mark_as_eligible(worker: &mut WorkerIdentity) {
    worker.is_eligible_for_investment = worker.investable_amount >= worker.investment_threshold;
}

// Function to add investments to the worker's record
public fun add_investment(worker: &mut WorkerIdentity, amount: u64) {
    worker.total_investment = worker.total_investment + amount;
}

// Check if worker is eligible to invest in farm-related projects
public fun can_invest_in_farm(worker: &WorkerIdentity): bool {
    return worker.is_agriculture_worker && worker.is_eligible_for_investment;
}
