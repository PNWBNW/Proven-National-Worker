program deploy_main.aleo;

function main:
    input r0 as address.private;
    input r1 as u64.private;
    
    // Deploy the main PNW smart contract
    deploy main.leo r0 r1;
    
    // Output confirmation
    output r0 as address.public;
    output r1 as u64.public;
