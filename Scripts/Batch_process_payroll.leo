program batch_process_payroll.aleo;

import payroll.leo;

function main:
    input r0 as address.private;   // Employer address
    input r1 as [address; 100].private;   // Array of worker addresses (batch limit: 100)
    input r2 as [u64; 100].private;       // Array of wages
    input r3 as [u64; 100].private;       // Array of taxes
    input r4 as u64.private;              // Payroll cycle ID

    // Loop through each worker and process payroll
    iterate r5 from 0 to 100 {
        call payroll.process_payroll r0 r1[r5] r2[r5] r3[r5] r4;
    }

    // Output confirmation
    output r0 as address.public;
    output r4 as u64.public;
