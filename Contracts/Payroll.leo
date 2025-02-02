program payroll.aleo;

mapping payroll_balances:
    key: address;
    value: u64;

mapping employer_tax_fund:
    key: address;
    value: u64;

mapping worker_taxes:
    key: address;
    value: u64;

function deposit_payroll_funds(employer: address, amount: u64) -> bool {
    payroll_balances[employer] += amount;
    return true;
}

function deposit_tax_funds(employer: address, tax_amount: u64) -> bool {
    employer_tax_fund[employer] += tax_amount;
    return true;
}

function process_payroll(worker: address, employer: address, wage: u64, tax_rate: u64) -> bool {
    let total_tax = (wage * tax_rate) / 100;
    let net_pay = wage - total_tax;

    if payroll_balances[employer] < wage {
        return false;
    }

    if employer_tax_fund[employer] < total_tax {
        return false;
    }

    payroll_balances[employer] -= wage;
    employer_tax_fund[employer] -= total_tax;
    worker_taxes[worker] += total_tax;

    return credit_worker(worker, net_pay);
}

function credit_worker(worker: address, amount: u64) -> bool {
    payroll_balances[worker] += amount;
    return true;
}

function pay_government(worker: address, government: address) -> bool {
    let tax_due = worker_taxes[worker];

    if tax_due == 0 {
        return false;
    }

    worker_taxes[worker] = 0;
    payroll_balances[government] += tax_due;

    return true;
}
