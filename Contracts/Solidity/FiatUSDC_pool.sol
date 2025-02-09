// pragma solidity ^0.8.20;

contract FiatUSDCPool {
    struct EmployerPool {
        address employer;
        uint256 fiatUSDCbalance;
        uint256 aleoUSDCbalance;
    }

    mapping(address => EmployerPool) public employerPools;
    mapping(address => bool) public restrictedEmployers;

    event FiatUSDCUpdated(uint8 actionType, address indexed employer, uint256 amount);
    event AleoUSDCUpdated(address indexed employer, uint256 amount);
    event EmployerRestricted(address indexed employer);
    event EmployerReinstated(address indexed employer);

    function fiatPoolManagement(
        uint8 actionType, 
        address _employer, 
        uint256 _amount
    ) external {
        if (actionType == 1) { // Deposit Fiat USDC
            require(_amount > 0, "Deposit must be greater than zero");
            employerPools[msg.sender].fiatUSDCbalance += _amount;
            emit FiatUSDCUpdated(1, msg.sender, _amount);
        } 
        else if (actionType == 2) { // Deposit AleoUSDC
            require(_amount > 0, "Deposit must be greater than zero");
            employerPools[msg.sender].aleoUSDCbalance += _amount;
            emit AleoUSDCUpdated(msg.sender, _amount);
        } 
        else if (actionType == 3) { // Restrict Employer
            restrictedEmployers[_employer] = true;
            emit EmployerRestricted(_employer);
        } 
        else if (actionType == 4) { // Reinstate Employer
            require(restrictedEmployers[_employer], "Employer is not restricted");
            restrictedEmployers[_employer] = false;
            emit EmployerReinstated(_employer);
        } 
        else {
            revert("Invalid action type");
        }
    }

    function withdrawForPayroll(address _employer, uint256 _amount) external returns (bool) {
        require(employerPools[_employer].fiatUSDCbalance >= _amount, "Insufficient Fiat USDC balance");
        employerPools[_employer].fiatUSDCbalance -= _amount;
        emit FiatUSDCUpdated(2, _employer, _amount);
        return true;
    }

    function fiatPoolQueries(uint8 queryType, address _employer) external view returns (uint256, uint256, bool) {
        if (queryType == 1) { // Get Fiat USDC & AleoUSDC Balances
            EmployerPool memory e = employerPools[_employer];
            return (e.fiatUSDCbalance, e.aleoUSDCbalance, !restrictedEmployers[_employer]);
        } 
        else {
            revert("Invalid query type");
        }
    }
}
