pragma solidity ^0.8.20;

contract EmployerContract {
    struct Employer {
        address employerAddress;
        uint256 prepaidWages;
        uint256 prepaidTaxes;
        uint256 fiatUSDCpool;
        bool isCompliant;
    }

    mapping(address => Employer) public employers;
    mapping(address => bool) public restrictedEmployers;

    event EmployerAction(
        uint8 actionType, 
        address indexed employer, 
        uint256 prepaidWages, 
        uint256 prepaidTaxes, 
        uint256 fiatUSDCpool, 
        bool isCompliant
    );

    function employerManagement(
        uint8 actionType, 
        address _employer, 
        uint256 _prepaidWages, 
        uint256 _prepaidTaxes, 
        uint256 _fiatUSDCpool, 
        bool _isCompliant
    ) external {
        if (actionType == 1) { // Register Employer
            require(employers[msg.sender].employerAddress == address(0), "Employer already registered");
            require(_prepaidWages > 0 && _prepaidTaxes > 0, "Prepaid wages and taxes must be positive");
            employers[msg.sender] = Employer(msg.sender, _prepaidWages, _prepaidTaxes, _fiatUSDCpool, true);
            emit EmployerAction(1, msg.sender, _prepaidWages, _prepaidTaxes, _fiatUSDCpool, true);
        } 
        else if (actionType == 2) { // Update Compliance Status
            require(employers[_employer].employerAddress != address(0), "Employer not found");
            employers[_employer].isCompliant = _isCompliant;
            emit EmployerAction(2, _employer, employers[_employer].prepaidWages, employers[_employer].prepaidTaxes, employers[_employer].fiatUSDCpool, _isCompliant);
        } 
        else if (actionType == 3) { // Restrict Employer
            require(employers[_employer].employerAddress != address(0), "Employer not found");
            restrictedEmployers[_employer] = true;
        } 
        else if (actionType == 4) { // Reinstate Employer
            require(restrictedEmployers[_employer], "Employer is not restricted");
            restrictedEmployers[_employer] = false;
        } 
        else if (actionType == 5) { // Fund Fiat USDC Pool
            require(_fiatUSDCpool > 0, "Deposit must be greater than zero");
            employers[msg.sender].fiatUSDCpool += _fiatUSDCpool;
            emit EmployerAction(5, msg.sender, employers[msg.sender].prepaidWages, employers[msg.sender].prepaidTaxes, employers[msg.sender].fiatUSDCpool, employers[msg.sender].isCompliant);
        } 
        else {
            revert("Invalid action type");
        }
    }

    function employerQueries(uint8 queryType, address _employer) external view returns (uint256, uint256, uint256, bool) {
        if (queryType == 1) { // Get Employer Payroll & Fiat Pool Balance
            Employer memory e = employers[_employer];
            return (e.prepaidWages, e.prepaidTaxes, e.fiatUSDCpool, e.isCompliant);
        } 
        else {
            revert("Invalid query type");
        }
    }
}
