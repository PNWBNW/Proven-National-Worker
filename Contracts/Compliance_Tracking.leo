// SPDX-License-Identifier: proprietary
// Compliance Tracking contract for PNW Smart Contracts (Agricultural & Non-Agricultural)

// Import relevant modules for integration with worker identity and subDAO contracts
import 0x1::worker_identity;
import 0x1::subdao_management;
import 0x1::tax_management;

// Enum for compliance status (tax payments)
enum ComplianceStatus {
    Compliant,       // Employer is compliant with all regulations
    NonCompliant,    // Employer has missed required payments
    Blacklisted,     // Employer has been blacklisted for repeated violations
}

// Struct to track employer compliance data
struct EmployerCompliance {
    employer_address: address,
    tax_paid: u64,                     // Total taxes paid by employer
    last_tax_payment_date: u64,        // Date of the last tax payment
    compliance_status: ComplianceStatus, // Compliance status of the employer
    penalty_count: u64,                // Number of penalties issued for missed payments
    is_blacklisted: bool,              // Whether the employer is blacklisted
}

// State to store compliance records of all employers
state employer_compliance: map<address, EmployerCompliance>;

// Function to initialize a new employer compliance record
public fun initialize_compliance_record(employer_address: address) {
    // Check if compliance record already exists
    if (employer_compliance.contains(employer_address)) {
        error("Compliance record already exists for this employer.");
    }

    // Initialize the new compliance record with default values
    let new_compliance_record = EmployerCompliance {
        employer_address: employer_address,
        tax_paid: 0,
        last_tax_payment_date: 0,
        compliance_status: ComplianceStatus::Compliant,
        penalty_count: 0,
        is_blacklisted: false,
    };

    // Store the new compliance record in the state
    employer_compliance.insert(employer_address, new_compliance_record);
}

// Function to track an employer's tax payment
public fun track_tax_payment(employer_address: address, tax_amount: u64, payment_date: u64) {
    let mut compliance_record = employer_compliance.get(employer_address).unwrap_or(error("Employer not found."));

    // Update the tax paid and the last payment date
    compliance_record.tax_paid = compliance_record.tax_paid + tax_amount;
    compliance_record.last_tax_payment_date = payment_date;

    // Update the compliance status
    if (compliance_record.tax_paid >= tax_amount) {
        compliance_record.compliance_status = ComplianceStatus::Compliant;
    }

    // Store the updated compliance record in the state
    employer_compliance.insert(employer_address, compliance_record);
}

// Function to issue a penalty for missed tax payments
public fun issue_penalty(employer_address: address, penalty_amount: u64) {
    let mut compliance_record = employer_compliance.get(employer_address).unwrap_or(error("Employer not found."));

    // If the employer is non-compliant, issue a penalty
    if (compliance_record.compliance_status != ComplianceStatus::Compliant) {
        compliance_record.penalty_count = compliance_record.penalty_count + 1;

        // If the penalty count exceeds a threshold, blacklist the employer
        if (compliance_record.penalty_count >= 3) {
            compliance_record.is_blacklisted = true;
            compliance_record.compliance_status = ComplianceStatus::Blacklisted;
        }

        // Update the employer compliance status in state
        employer_compliance.insert(employer_address, compliance_record);
    } else {
        error("Employer is compliant, no penalty necessary.");
    }
}

// Function to check the compliance status of an employer
public fun get_compliance_status(employer_address: address) -> ComplianceStatus {
    let compliance_record = employer_compliance.get(employer_address).unwrap_or(error("Employer not found."));
    return compliance_record.compliance_status;
}

// Function to reset an employer's compliance status after payment
public fun reset_compliance_status(employer_address: address) {
    let mut compliance_record = employer_compliance.get(employer_address).unwrap_or(error("Employer not found."));

    // Reset the compliance status and penalty count after the employer pays overdue taxes
    compliance_record.compliance_status = ComplianceStatus::Compliant;
    compliance_record.penalty_count = 0;

    // Update the employer compliance record in state
    employer_compliance.insert(employer_address, compliance_record);
}

// Function to allow blacklisted employers to pay a fine for reinstatement
public fun reinstate_employer(employer_address: address, fine_amount: u64) {
    let mut compliance_record = employer_compliance.get(employer_address).unwrap_or(error("Employer not found."));

    // Check if employer is blacklisted
    if (!compliance_record.is_blacklisted) {
        error("Employer is not blacklisted.");
    }

    // Calculate the fine and allow the employer to pay
    let fine_due = compliance_record.tax_paid + (fine_amount / 4);
    if (fine_amount < fine_due) {
        error("Insufficient fine amount to reinstate.");
    }

    // Remove the blacklisting status after paying the fine
    compliance_record.is_blacklisted = false;
    compliance_record.compliance_status = ComplianceStatus::Compliant;

    // Update the compliance status in state
    employer_compliance.insert(employer_address, compliance_record);
}

// Function to get a blacklist status for an employer
public fun is_blacklisted(employer_address: address) -> bool {
    let compliance_record = employer_compliance.get(employer_address).unwrap_or(error("Employer not found."));
    return compliance_record.is_blacklisted;
}

// Function to get the penalty count for an employer
public fun get_penalty_count(employer_address: address) -> u64 {
    let compliance_record = employer_compliance.get(employer_address).unwrap_or(error("Employer not found."));
    return compliance_record.penalty_count;
}
