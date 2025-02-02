program government_api.aleo;

mapping government_access:
    key: address;
    value: bool; // True if the government entity is authorized

mapping worker_tax_records:
    key: address;
    value: (u64, u64); // (total_taxes_paid, last_tax_payment_timestamp)

mapping employer_tax_records:
    key: address;
    value: (u64, u64); // (total_taxes_paid, last_tax_payment_timestamp)

function authorize_government_entity(entity: address) -> bool {
    if government_access.contains(entity) {
        return false; // Already authorized
    }

    government_access[entity] = true;
    return true;
}

function revoke_government_access(entity: address) -> bool {
    if !government_access.contains(entity) {
        return false; // Not authorized
    }

    government_access.remove(entity);
    return true;
}

function record_worker_tax(worker: address, amount: u64) -> bool {
    let timestamp = get_block_height();

    if worker_tax_records.contains(worker) {
        let (total_paid, _) = worker_tax_records[worker];
        worker_tax_records[worker] = (total_paid + amount, timestamp);
    } else {
        worker_tax_records[worker] = (amount, timestamp);
    }

    return true;
}

function record_employer_tax(employer: address, amount: u64) -> bool {
    let timestamp = get_block_height();

    if employer_tax_records.contains(employer) {
        let (total_paid, _) = employer_tax_records[employer];
        employer_tax_records[employer] = (total_paid + amount, timestamp);
    } else {
        employer_tax_records[employer] = (amount, timestamp);
    }

    return true;
}

function get_worker_tax_record(worker: address, entity: address) -> (u64, u64) {
    if !government_access.contains(entity) {
        return (0, 0); // Unauthorized access
    }

    return worker_tax_records[worker];
}

function get_employer_tax_record(employer: address, entity: address) -> (u64, u64) {
    if !government_access.contains(entity) {
        return (0, 0); // Unauthorized access
    }

    return employer_tax_records[employer];
}
