// 📌 SubDAO AleoUSDC Reserve Contract
// Manages AleoUSDC payroll with withdrawal limits & auto-notifications.

import oversightdao_combined_reserve.leo;
import aleo_ans::*;

struct SubDAO_AleoUSDC_Pool {
    subdao_id: Field,
    subdao_ans: String,
    balance: u64,
}

// 🔹 Initialize SubDAO AleoUSDC Pool
let subdao_aleo_pools: Map<Field, SubDAO_AleoUSDC_Pool> = {};

// 🔹 Function: Deposit AleoUSDC for Payroll
fn deposit_aleo_usdc(subdao_id: Field, employer_id: Field, amount: u64) {
    let subdao_ans = aleo_ans::get_ans(subdao_id);
    assert!(subdao_ans != "", "Invalid SubDAO ANS registration");

    if subdao_id in subdao_aleo_pools {
        subdao_aleo_pools[subdao_id].balance += amount;
    } else {
        subdao_aleo_pools[subdao_id] = SubDAO_AleoUSDC_Pool {
            subdao_id,
            subdao_ans,
            balance: amount,
        };
    }
}

// 🔹 Function: Process Payroll (Enforces 75% Withdrawal Cap)
fn process_aleo_payroll(subdao_id: Field, worker_id: Field, amount: u64) -> bool {
    assert!(subdao_id in subdao_aleo_pools, "SubDAO not registered");

    let max_withdrawable = subdao_aleo_pools[subdao_id].balance * 75 / 100;
    assert!(amount <= max_withdrawable, "Cannot withdraw more than 75% of reserves");

    subdao_aleo_pools[subdao_id].balance -= amount;
    emit payroll_disbursement_event(subdao_id, worker_id, amount);

    // Auto-notify if balance falls below 50%
    if subdao_aleo_pools[subdao_id].balance < max_withdrawable / 1.5 {
        oversightdao_combined_reserve::notify_low_funds(subdao_id, subdao_aleo_pools[subdao_id].balance);
    }

    return true;
}

// 🔹 Function: Get SubDAO Balance
fn get_subdao_balance(subdao_id: Field) -> u64 {
    if subdao_id in subdao_aleo_pools {
        return subdao_aleo_pools[subdao_id].balance;
    }
    return 0;
}

// 🔹 Event Emitters
event payroll_disbursement_event(subdao_id: Field, worker_id: Field, amount: u64);
