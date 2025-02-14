program ANS_test.leo;

// 🏷️ Mappings for Testing
mapping test_workers: mapping(string, address);  // Simulated worker ANS assignments
mapping test_subDAOs: mapping(string, address);  // Simulated SubDAO ANS assignments

// ✅ Test: Register and verify a worker's ANS name
function test_worker_ans_registration(worker: address, ans_name: string) -> bool {
    ans_registry[worker] = ans_name;
    ans_reverse_lookup[ans_name] = worker;

    let resolved_worker = lookup_worker_by_ans(ans_name);
    ensure!(resolved_worker == worker, "ANS worker lookup failed");
    
    return true;
}

// ✅ Test: Register and verify a SubDAO's ANS name
function test_subDAO_ans_registration(subDAO: address, ans_name: string) -> bool {
    subDAO_ans_registry[subDAO] = ans_name;
    subDAO_reverse_lookup[ans_name] = subDAO;

    let resolved_subDAO = lookup_subDAO_by_ans(ans_name);
    ensure!(resolved_subDAO == subDAO, "ANS SubDAO lookup failed");
    
    return true;
}

// ✅ Test: Assign a worker to a SubDAO using ANS names
function test_assign_worker_to_subDAO_by_ans(worker_ans: string, subDAO_ans: string) -> bool {
    let worker = lookup_worker_by_ans(worker_ans);
    let subDAO = lookup_subDAO_by_ans(subDAO_ans);
    
    assign_worker_to_subDAO(worker, subDAO);

    let assigned_subDAO = subDAO_members[worker];
    ensure!(assigned_subDAO == subDAO, "ANS worker-to-SubDAO assignment failed");
    
    return true;
}

// ✅ Test: Submit and vote on a proposal using ANS names
function test_governance_proposal_and_vote_by_ans(subDAO_ans: string, target_ans: string, amount: u64) -> bool {
    let subDAO = lookup_subDAO_by_ans(subDAO_ans);
    let target = lookup_worker_by_ans(target_ans);
    
    let proposal_id = submit_proposal(subDAO, 0, target, amount);
    vote_on_proposal(subDAO, proposal_id, true);
    
    let proposal = subDAO_proposals[proposal_id];
    ensure!(proposal.votes_for > 0, "ANS governance vote failed");
    
    return true;
}

// ✅ Test: Execute a proposal using ANS names
function test_execute_proposal_by_ans(subDAO_ans: string, proposal_id: address) -> bool {
    let subDAO = lookup_subDAO_by_ans(subDAO_ans);
    execute_proposal(subDAO, proposal_id);
    
    let proposal = subDAO_proposals[proposal_id];
    ensure!(proposal.executed == true, "ANS proposal execution failed");
    
    return true;
}
