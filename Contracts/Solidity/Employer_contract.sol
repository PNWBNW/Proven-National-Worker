pragma solidity ^0.8.20;

contract EmployerContract {
    struct Employer {
        address employerAddress;
        uint256 prepaidWages;
        uint256 prepaidTaxes;
        uint256 investmentLimit;
        bool isCompliant;
    }

    mapping(address => Employer) public employers;
    mapping(address => bool) public restrictedEmployers;

    event EmployerAction(
        uint8 actionType, 
        address indexed employer, 
        uint256 prepaidWages, 
        uint256 prepaidTaxes, 
        uint256 investmentLimit, 
        bool isCompliant, 
        bool isRestricted
    );

    function employerManagement(
        uint8 actionType, 
        address _employer, 
        uint256 _prepaidWages, 
        uint256 _prepaidTaxes, 
        uint256 _investmentLimit, 
        bool _isCompliant
    ) external {
        if (actionType == 1) { // Register Employer
            require(employers[msg.sender].employerAddress == address(0), "Employer already registered");
            require(_prepaidWages > 0 && _prepaidTaxes > 0, "Prepaid wages and taxes must be positive");
            employers[msg.sender] = Employer(msg.sender, _prepaidWages, _prepaidTaxes, _investmentLimit, true);
            emit EmployerAction(1, msg.sender, _prepaidWages, _prepaidTaxes, _investmentLimit, true, false);
        } 
        else if (actionType == 2) { // Update Compliance
            require(employers[_employer].employerAddress != address(0), "Employer not found");
            employers[_employer].isCompliant = _isCompliant;
            emit EmployerAction(2, _employer, 0, 0, 0, _isCompliant, restrictedEmployers[_employer]);
        } 
        else if (actionType == 3) { // Set Investment Limit
            require(employers[_employer].employerAddress != address(0), "Employer not found");
            employers[_employer].investmentLimit = _investmentLimit;
            emit EmployerAction(3, _employer, 0, 0, _investmentLimit, employers[_employer].isCompliant, restrictedEmployers[_employer]);
        } 
        else if (actionType == 4) { // Restrict Employer
            require(employers[_employer].employerAddress != address(0), "Employer not found");
            restrictedEmployers[_employer] = true;
            emit EmployerAction(4, _employer, 0, 0, 0, employers[_employer].isCompliant, true);
        } 
        else if (actionType == 5) { // Reinstate Employer
            require(restrictedEmployers[_employer], "Employer is not restricted");
            restrictedEmployers[_employer] = false;
            emit EmployerAction(5, _employer, 0, 0, 0, employers[_employer].isCompliant, false);
        } 
        else {
            revert("Invalid action type");
        }
    }

    function employerQueries(uint8 queryType, address _employer) external view returns (
        address employerAddress, uint256 prepaidWages, uint256 prepaidTaxes, uint256 investmentLimit, bool isCompliant, bool isRestricted
    ) {
        if (queryType == 1) { // Check if Employer is Restricted
            return (_employer, 0, 0, 0, true, restrictedEmployers[_employer]);
        } 
        else if (queryType == 2) { // Get Employer Details
            Employer memory e = employers[_employer];
            return (e.employerAddress, e.prepaidWages, e.prepaidTaxes, e.investmentLimit, e.isCompliant, restrictedEmployers[_employer]);
        } 
        else {
            revert("Invalid query type");
        }
    }
}
