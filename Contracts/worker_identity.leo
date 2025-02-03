program worker_identity.aleo;

// Worker data storage
mapping worker_data:
    address as worker -> (string, u8, address);  // (Name, Industry Flag, Assigned Farm)

mapping industry_flags:
    address as worker -> u8;  // Industry flags per worker, using bitmask

// Registers a worker with their name, industry, and farm assignments
function register_worker(worker: address, name: string, industry_flag: u8, farm_address: address) -> bool {
    if worker_data.contains(worker) {
        return false;  // Worker already registered
    }

    // Store worker data
    worker_data.insert(worker, (name, industry_flag, farm_address));
    industry_flags.insert(worker, industry_flag);
    return true;
}

// Updates worker's name
function update_worker_name(worker: address, new_name: string) -> bool {
    if !worker_data.contains(worker) {
        return false;  // Worker not found
    }

    let (_, industry_flag, farm_address) = worker_data.get(worker);
    worker_data.update(worker, (new_name, industry_flag, farm_address));
    return true;
}

// Updates the industry flag for a worker
function update_industry_flag(worker: address, new_industry_flag: u8) -> bool {
    if !worker_data.contains(worker) {
        return false;  // Worker not found
    }

    let (name, _, farm_address) = worker_data.get(worker);
    worker_data.update(worker, (name, new_industry_flag, farm_address));
    industry_flags.update(worker, new_industry_flag);
    return true;
}

// Assign a worker to a farm
function assign_worker_to_farm(worker: address, farm_address: address) -> bool {
    if !worker_data.contains(worker) {
        return false;  // Worker not found
    }

    let (name, industry_flag, _) = worker_data.get(worker);

    // Check if worker is an agricultural worker based on the industry flag
    if industry_flag & 0b01 == 0 {
        return false;  // Non-agriculture worker cannot be assigned to a farm
    }

    // Update farm assignment
    worker_data.update(worker, (name, industry_flag, farm_address));
    return true;
}

// Checks if worker is assigned to a valid industry
function is_assigned_to_valid_industry(worker: address) -> bool {
    if !worker_data.contains(worker) {
        return false;  // Worker not found
    }

    let (_, industry_flag, _) = worker_data.get(worker);
    return industry_flag != 0;  // Valid industry flag should not be 0
}

// Retrieves the farm a worker is assigned to (if any)
function get_assigned_farm(worker: address) -> address {
    if !worker_data.contains(worker) {
        return address(0);  // Worker not found, return an empty address
    }

    let (_, _, farm_address) = worker_data.get(worker);
    return farm_address;
}

// Get the industry flag for a specific worker
function get_industry_flag(worker: address) -> u8 {
    if !worker_data.contains(worker) {
        return 0;  // Worker not found, return 0 flag
    }

    return industry_flags.get(worker);
}

// Retrieves worker's name
function get_worker_name(worker: address) -> string {
    if !worker_data.contains(worker) {
        return "";  // Worker not found
    }

    let (name, _, _) = worker_data.get(worker);
    return name;
}
