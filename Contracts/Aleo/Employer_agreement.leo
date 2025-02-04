// employer_agreement.leo

// Required libraries for contract and utilities
import "std/contract.leo";

// Contract definition for employer agreement
contract EmployerAgreement {

    // Define a struct to store employer information
    struct Employer {
        address employerAddress;
        string companyName;
        string industry;
        uint64 taxId;
        bool isVerified;
        bool agreementSigned;
    }

    // State variables
    public employerData: map<address, Employer>;
    public agreementApproval: map<address, bool>;

    // Events to notify when certain actions occur
    event AgreementSigned(employer: address);
    event AgreementDenied(employer: address);
    event EmployerVerified(employer: address);

    // Function to verify the employer's details
    public fun verifyEmployer(employer: address, companyName: string, taxId: uint64) {
        // Ensure the employer has not been verified before
        assert!(!self.employerData.contains(employer), "Employer already verified");

        // Store the verified employer details
        self.employerData[employer] = Employer {
            employerAddress: employer,
            companyName: companyName,
            industry: "Unknown",  // Placeholder until industry is updated
            taxId: taxId,
            isVerified: true,
            agreementSigned: false
        };

        // Emit an event to notify that the employer has been verified
        self.emit(EmployerVerified(employer));
    }

    // Function for employer to sign the agreement
    public fun signAgreement(employer: address) {
        // Ensure the employer is verified before they can sign the agreement
        assert!(self.employerData.contains(employer), "Employer must be verified before signing");

        // Update the employer's agreement status to signed
        self.employerData[employer].agreementSigned = true;

        // Emit an event to notify that the agreement has been signed
        self.emit(AgreementSigned(employer));
    }

    // Function for employer to deny the agreement
    public fun denyAgreement(employer: address) {
        // Ensure the employer is verified before denying the agreement
        assert!(self.employerData.contains(employer), "Employer must be verified before denying");

        // Set the agreement approval to false for the employer
        self.agreementApproval[employer] = false;

        // Emit an event to notify that the agreement has been denied
        self.emit(AgreementDenied(employer));
    }

    // Check if the employer has signed the agreement
    public fun checkAgreementStatus(employer: address): bool {
        if (self.employerData.contains(employer)) {
            return self.employerData[employer].agreementSigned;
        }
        return false;
    }
}
