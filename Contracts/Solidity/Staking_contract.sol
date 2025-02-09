pragma solidity ^0.8.20;

contract EmployerStaking {
    struct Employer {
        address employerAddress;
        uint256 fiatUSDCpool;
        bool isCompliant;
    }

    mapping(address => Employer) public employers;
    mapping(address => bool) public restrictedEmployers;

    event FiatPoolUpdated(uint8 actionType, address indexed employer, uint256 amount, bool isCompliant);
    event PayrollWithdrawn(address indexed worker, uint256 amount, uint256 fee, bool success);

    function fiatPoolManagement(
        uint8 actionType, 
        address _employer, 
        uint256 _amount, 
        bool _isCompliant
    ) external {
        if (actionType == 1) { // Employer Deposits into Fiat Pool
            require(_amount > 0, "Deposit must be greater than zero");
            employers[msg.sender].fiatUSDCpool += _amount;
            emit FiatPoolUpdated(1, msg.sender, _amount, employers[msg.sender].isCompliant);
        } 
        else if (actionType == 2) { // Update Employer Compliance
            require(employers[_employer].employerAddress != address(0), "Employer not found");
            employers[_employer].isCompliant = _isCompliant;
            emit FiatPoolUpdated(2, _employer, employers[_employer].fiatUSDCpool, _isCompliant);
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

    function payrollWithdraw(address _worker, uint256 _amount, bool isZPass) external {
        require(employers[msg.sender].fiatUSDCpool >= _amount, "Insufficient Fiat Pool");
        
        uint256 fee = isZPass ? (_amount * 1) / 100 : (_amount * 2) / 100;
        uint256 finalPayout = _amount - fee;

        employers[msg.sender].fiatUSDCpool -= _amount;
        employers[msg.sender].fiatUSDCpool += fee; // Fee gets recycled into the Fiat pool

        emit PayrollWithdrawn(_worker, finalPayout, fee, true);
    }

    function fiatPoolQueries(uint8 queryType, address _employer) external view returns (uint256, bool) {
        if (queryType == 1) { // Get Employer Fiat Pool Balance
            return (employers[_employer].fiatUSDCpool, employers[_employer].isCompliant);
        } 
        else {
            revert("Invalid query type");
        }
    }
}
