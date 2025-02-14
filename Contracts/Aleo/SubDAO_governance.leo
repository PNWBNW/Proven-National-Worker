program subDAO_governance.leo;

mapping subDAO_members: mapping(address, address);          // Worker → SubDAO mapping
mapping subDAO_governance_funds: mapping(address, u64);     // Treasury for each SubDAO
mapping subDAO_voting_records: mapping(address, mapping(address, bool));  // SubDAO votes per proposal
mapping subDAO_proposals: mapping(address, Proposal);       // Active proposals per SubDAO
mapping employer_penalty_status: mapping(address, u64);     // Employer penalty tracking

// Struct for governance proposals
struct Proposal {
    proposer: address,
    proposal_type: u8,  // 0 = Payroll Approval, 1 = Compliance Penalty
    target: address,
    amount: u64,
    votes_for: u64,
    votes_against: u64,
    executed: bool,
}

// Assign workers to SubDAOs based on their state
function assign_worker_to_subDAO(worker: address, subDAO: address) {
    ensure!(subDAO_members[worker] == null, "Worker already assigned to a SubDAO");
    subDAO_members[worker] = subDAO;
}

// Function to submit governance proposals
function submit_proposal(subDAO: address, proposal_type: u8, target: address, amount: u64) -> address {
    let proposal_id = compute_proposal_id(subDAO, target);
    
    let new_proposal = Proposal {
        proposer: env::caller(),
        proposal_type,
        target,
        amount,
        votes_for: 0,
        votes_against: 0,
        executed: false,
    };

    subDAO_proposals[proposal_id] = new_proposal;
    return proposal_id;
}

// Voting function for SubDAO members
function vote_on_proposal(subDAO: address, proposal_id: address, vote: bool) {
    ensure!(subDAO_proposals[proposal_id].executed == false, "Proposal already executed");

    if (vote) {
        subDAO_proposals[proposal_id].votes_for += 1;
    } else {
        subDAO_proposals[proposal_id].votes_against += 1;
    }

    subDAO_voting_records[subDAO][env::caller()] = vote;
}

// Execute approved proposals
function execute_proposal(subDAO: address, proposal_id: address) {
    let proposal = subDAO_proposals[proposal_id];

    ensure!(proposal.executed == false, "Proposal already executed");
    ensure!(proposal.votes_for > proposal.votes_against, "Proposal rejected by SubDAO");

    if (proposal.proposal_type == 0) {
        // Payroll Approval: Allocate funds to employer/worker
        ensure!(subDAO_governance_funds[subDAO] >= proposal.amount, "Insufficient SubDAO funds");
        subDAO_governance_funds[subDAO] -= proposal.amount;
        send_funds(proposal.target, proposal.amount);
    } else if (proposal.proposal_type == 1) {
        // Compliance Penalty: Deduct from employer and send to treasury
        employer_penalty_status[proposal.target] += proposal.amount;
        send_funds(subDAO, proposal.amount);
    }

    subDAO_proposals[proposal_id].executed = true;
}

// Utility functions
function compute_proposal_id(subDAO: address, target: address) -> address {
    return hash(subDAO, target, env::block_height());
}

function send_funds(recipient: address, amount: u64) {
    transfer_to(recipient, amount);
}
