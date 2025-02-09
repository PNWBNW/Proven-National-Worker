program compliance_tracking.leo;

mapping employer_tax_compliance:
    key address as field;
    value bool as field;

mapping employer_payroll_compliance:
    key address as field;
    value bool as field;

mapping employer_obligations:
    key address as field;
    value u64 as field;

function verify_employer_compliance(public employer: address) -> bool {
    let tax_compliant = employer_tax_compliance.get_or_use(employer, false);
    let payroll_compliant = employer_payroll_compliance.get_or_use(employer, false);

    ensure(tax_compliant, "Employer has outstanding tax obligations");
    ensure(payroll_compliant, "Employer has payroll compliance issues");

    return true;
}

function flag_employer_for_review(public employer: address) -> bool {
    employer_payroll_compliance.insert(employer, false);
    return true;
}

function clear_employer_compliance(public employer: address) -> bool {
    employer_payroll_compliance.insert(employer, true);
    return true;
}

function update_employer_obligation(public employer: address, public amount: u64) -> bool {
    employer_obligations.insert(employer, amount);
    return true;
}

function get_employer_obligation(public employer: address) -> u64 {
    return employer_obligations.get_or_use(employer, 0u64);
}
