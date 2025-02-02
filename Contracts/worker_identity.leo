program worker_identity.aleo;

mapping worker_registry:
    key: address;
    value: (string, u64, bool); // (worker_id, timestamp, zpass_verified)

mapping zpass_status:
    key: address;
    value: bool; // True if the worker is ZPass verified

function register_worker(worker: address, worker_id: string, zpass_opt_in: bool) -> bool {
    if worker_registry.contains(worker) {
        return false; // Worker already registered
    }

    let timestamp = get_block_height(); // Record registration time
    worker_registry[worker] = (worker_id, timestamp, zpass_opt_in);
    zpass_status[worker] = zpass_opt_in;

    return true;
}

function update_worker_status(worker: address, zpass_verified: bool) -> bool {
    if !worker_registry.contains(worker) {
        return false; // Worker not registered
    }

    let (worker_id, timestamp, _) = worker_registry[worker];
    worker_registry[worker] = (worker_id, timestamp, zpass_verified);
    zpass_status[worker] = zpass_verified;

    return true;
}

function get_worker_info(worker: address) -> (string, u64, bool) {
    return worker_registry[worker];
}

function is_zpass_verified(worker: address) -> bool {
    return zpass_status[worker];
}
