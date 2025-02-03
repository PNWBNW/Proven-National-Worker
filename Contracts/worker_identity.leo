// Worker Identity - worker_identity.leo

// Worker states
struct Worker {
    address: address,
    is_agricultural_worker: bool,
    has_investment: bool,
}

state workers: map<address, Worker>;

function create_worker(address: address, is_agricultural_worker: bool) -> Worker {
    let new_worker = Worker {
        address: address,
        is_agricultural_worker: is_agricultural_worker,
        has_investment: false,
    };

    workers.insert(address, new_worker);
    return new_worker;
}

function mark_investment(address: address) {
    let worker = workers.get(address).unwrap();
    worker.has_investment = true;
}

function remove_investment(address: address) {
    let worker = workers.get(address).unwrap();
    worker.has_investment = false;
}

function is_agricultural_worker(address: address) -> bool {
    let worker = workers.get(address).unwrap();
    return worker.is_agricultural_worker;
}

function has_investment(address: address) -> bool {
    let worker = workers.get(address).unwrap();
    return worker.has_investment;
}
