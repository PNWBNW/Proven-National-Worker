program subdao_management.aleo;

mapping subdao_registry:
    key: u64;
    value: (address, u64, u64); // (creator, total_members, funds_balance)

mapping worker_subdao:
    key: address;
    value: u64; // SubDAO ID the worker belongs to

mapping employer_subdao:
    key: address;
    value: u64; // SubDAO ID the employer belongs to

mapping subdao_votes:
    key: u64;
    value: (u64, u64); // (total_votes, required_votes_for_approval)

function create_subdao(creator: address) -> u64 {
    let subdao_id = get_block_height(); // Unique SubDAO ID based on block height

    subdao_registry[subdao_id] = (creator, 0, 0); // Initialize with zero members and funds
    return subdao_id;
}

function join_subdao(worker: address, subdao_id: u64) -> bool {
    if !subdao_registry.contains(subdao_id) {
        return false; // SubDAO does not exist
    }

    let (creator, members, funds) = subdao_registry[subdao_id];
    subdao_registry[subdao_id] = (creator, members + 1, funds);
    worker_subdao[worker] = subdao_id;

    return true;
}

function employer_join_subdao(employer: address, subdao_id: u64) -> bool {
    if !subdao_registry.contains(subdao_id) {
        return false; // SubDAO does not exist
    }

    employer_subdao[employer] = subdao_id;
    return true;
}

function contribute_to_subdao(subdao_id: u64, amount: u64) -> bool {
    if !subdao_registry.contains(subdao_id) {
        return false; // SubDAO does not exist
    }

    let (creator, members, funds) = subdao_registry[subdao_id];
    subdao_registry[subdao_id] = (creator, members, funds + amount);

    return true;
}

function propose_vote(subdao_id: u64, required_votes: u64) -> bool {
    if !subdao_registry.contains(subdao_id) {
        return false; // SubDAO does not exist
    }

    subdao_votes[subdao_id] = (0, required_votes);
    return true;
}

function cast_vote(subdao_id: u64, voter: address) -> bool {
    if !subdao_registry.contains(subdao_id) || !subdao_votes.contains(subdao_id) {
        return false; // Invalid vote
    }

    let (current_votes, required_votes) = subdao_votes[subdao_id];
    subdao_votes[subdao_id] = (current_votes + 1, required_votes);

    return current_votes + 1 >= required_votes; // Returns true if vote passes
}
