// SPDX-License-Identifier: Proprietary
pragma solidity ^0.8.20;

/**
 * @dev Interface for interacting with government tax APIs.
 */
interface IGovTaxAPI {
    /**
     * @dev Event emitted when an employer makes a tax payment.
     */
    event TaxPaid(address indexed employer, uint256 amount, uint256 timestamp);

    /**
     * @dev Retrieves the required tax amount for an employer.
     * @param employer The address of the employer.
     * @return taxAmount The tax amount owed.
     */
    function getTaxAmount(address employer) external view returns (uint256 taxAmount);

    /**
     * @dev Reports a tax payment to the government API.
     * @param employer The address of the employer.
     * @param amount The amount of tax paid.
     * @return success Returns true if the report was successful.
     * @return reason A string describing the reason for failure, if any.
     */
    function reportTaxPayment(address employer, uint256 amount) external returns (bool success, string memory reason);

    /**
     * @dev Checks if an employer is compliant with tax payments.
     * @param employer The address of the employer.
     * @return isCompliant Returns true if the employer is compliant, false otherwise.
     */
    function isEmployerCompliant(address employer) external view returns (bool isCompliant);
}
