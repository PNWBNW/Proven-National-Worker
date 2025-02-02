program test_payroll.aleo;

import payroll.leo;

function main:
    input r0 as address.private;   // Employer address
    input r1 as address.private;   // Worker address
    input r2 as u64.private;       // Wage amount
    input r3 as u64.private;       // Tax amount
    input r4 as u64.private;       // Payroll cycle ID

    // Simulate payroll processing
    call payroll.process_payroll r0 r1 r2 r3 r4;

    // Output confirmation
    output r1 as address.public;
    output r2 as u64.public;
