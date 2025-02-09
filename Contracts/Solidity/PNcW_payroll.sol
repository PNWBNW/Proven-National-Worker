pragma solidity ^0.8.20;

contract PNcWPayroll {
    struct Payroll {
        address worker;
        uint256 amount;
        bool processed;
    }

    struct Employer {
        address employerAddress;
        uint256 prepaidWages;
        uint256 prepaidTaxes;
        bool isCompliant;
    }

    mapping(address => Employer) public employers;
    mapping(address => Payroll[]) public payrolls;
    mapping(address => bool) public restrictedEmployers;

    event PayrollProcessed(uint8 actionType, address indexed employer, address indexed worker, uint256 amount, bool processed);
    event EmployerComplianceUpdated(address indexed employer, bool isCompliant);
    
    function payrollManagement(
        uint8 actionType, 
        address _employer, 
        address _worker, 
        uint256 _amount, 
        bool _isCompliant
    ) external {
        if (actionType == 1) { // Process Payroll (Batch or Single)
            require(employers[_employer].prepaidWages >= _amount, "Insufficient employer balance");
            require(employers[_employer].isCompliant, "Employer non-compliant");

            employers[_employer].prepaidWages -= _amount;
            payrolls[_worker].push(Payroll(_worker, _amount, true));

            emit PayrollProcessed(1, _employer, _worker, _amount, true);
        } 
        else if (actionType == 2) { // Update Employer Compliance
            require(employers[_employer].employerAddress != address(0), "Employer not found");
            employers[_employer].isCompliant = _isCompliant;
            emit EmployerComplianceUpdated(_employer, _isCompliant);
        } 
        else if (actionType == 3) { // Restrict Employer
            require(employers[_employer].employerAddress != address(0), "Employer not found");
            restrictedEmployers[_employer] = true;
        } 
        else if (actionType == 4) { // Reinstate Employer
            require(restrictedEmployers[_employer], "Employer is not restricted");
            restrictedEmployers[_employer] = false;
        } 
        else {
            revert("Invalid action type");
        }
    }

    function payrollQueries(uint8 queryType, address _user) external view returns (uint256, bool) {
        if (queryType == 1) { // Get Worker Payroll History
            require(payrolls[_user].length > 0, "No payroll history found");
            Payroll memory latest = payrolls[_user][payrolls[_user].length - 1];
            return (latest.amount, latest.processed);
        } 
        else if (queryType == 2) { // Check Employer Compliance
            return (employers[_user].prepaidWages, employers[_user].isCompliant);
        } 
        else {
            revert("Invalid query type");
        }
    }
}
