//pragma solidity ^0.8.20

contract PNWPayrollBridge {
    struct Employer {
        address employerAddress;
        uint256 prepaidWages;
        uint256 prepaidTaxes;
        uint256 fiatUSDCpool;
        uint256 aleoUSDCpool;
        bool isCompliant;
    }

    struct Payroll {
        address worker;
        uint256 amount;
        bool processed;
        bool usedFiatPool;
    }

    mapping(address => Employer) public employers;
    mapping(address => Payroll[]) public payrolls;
    mapping(address => bool) public restrictedEmployers;

    event PayrollProcessed(uint8 actionType, address indexed employer, address indexed worker, uint256 amount, bool success, bool usedFiatPool);
    event EmployerComplianceUpdated(address indexed employer, bool isCompliant);
    event FiatPoolFunded(address indexed employer, uint256 amount);
    event AleoUSDCUsed(address indexed employer, uint256 amount);

    function payrollManagement(
        uint8 actionType, 
        address _employer, 
        address _worker, 
        uint256 _amount, 
        bool isRollup, 
        bool isZPass
    ) external {
        if (actionType == 1) { // Process Payroll (Direct or Rollup)
            require(employers[_employer].prepaidWages >= _amount, "Insufficient employer balance");
            require(employers[_employer].isCompliant, "Employer non-compliant");

            employers[_employer].prepaidWages -= _amount;
            payrolls[_worker].push(Payroll(_worker, _amount, true, false));

            emit PayrollProcessed(1, _employer, _worker, _amount, true, false);
        } 
        else if (actionType == 2) { // Withdraw from Fiat Pool (Pull AleoUSDC if Insufficient)
            uint256 fee = isZPass ? (_amount * 1) / 100 : (_amount * 2) / 100;
            uint256 finalPayout = _amount - fee;

            if (employers[_employer].fiatUSDCpool >= _amount) {
                // Use Fiat Pool
                employers[_employer].fiatUSDCpool -= _amount;
                employers[_employer].fiatUSDCpool += fee; // Recycle fee into Fiat pool
                emit PayrollProcessed(2, _employer, _worker, finalPayout, true, true);
            } 
            else {
                // Insufficient Fiat Pool, pull from AleoUSDC
                uint256 shortfall = _amount - employers[_employer].fiatUSDCpool;
                require(employers[_employer].aleoUSDCpool >= shortfall, "Insufficient AleoUSDC to cover shortfall");

                // Deduct from both pools
                employers[_employer].aleoUSDCpool -= shortfall;
                employers[_employer].fiatUSDCpool = 0; // Fully depleted
                employers[_employer].fiatUSDCpool += fee; // Fee goes into Fiat pool

                emit AleoUSDCUsed(_employer, shortfall);
                emit PayrollProcessed(2, _employer, _worker, finalPayout, true, true);
            }
        } 
        else if (actionType == 3) { // Fund Fiat Pool
            require(_amount > 0, "Deposit must be greater than zero");
            employers[msg.sender].fiatUSDCpool += _amount;
            emit FiatPoolFunded(msg.sender, _amount);
        } 
        else if (actionType == 4) { // Fund AleoUSDC Pool
            require(_amount > 0, "Deposit must be greater than zero");
            employers[msg.sender].aleoUSDCpool += _amount;
            emit AleoUSDCUsed(msg.sender, _amount);
        } 
        else if (actionType == 5) { // Update Employer Compliance
            require(employers[_employer].employerAddress != address(0), "Employer not found");
            employers[_employer].isCompliant = true;
            emit EmployerComplianceUpdated(_employer, true);
        } 
        else if (actionType == 6) { // Restrict Employer
            require(employers[_employer].employerAddress != address(0), "Employer not found");
            restrictedEmployers[_employer] = true;
        } 
        else if (actionType == 7) { // Reinstate Employer
            require(restrictedEmployers[_employer], "Employer is not restricted");
            restrictedEmployers[_employer] = false;
        } 
        else {
            revert("Invalid action type");
        }
    }

    function payrollQueries(uint8 queryType, address _user) external view returns (uint256, uint256, bool, bool) {
        if (queryType == 1) { // Get Last Payroll for Worker
            require(payrolls[_user].length > 0, "No payroll history found");
            Payroll memory latest = payrolls[_user][payrolls[_user].length - 1];
            return (latest.amount, 0, latest.processed, latest.usedFiatPool);
        } 
        else if (queryType == 2) { // Get Employer Fiat & AleoUSDC Balances
            return (employers[_user].fiatUSDCpool, employers[_user].aleoUSDCpool, employers[_user].isCompliant, false);
        } 
        else {
            revert("Invalid query type");
        }
    }
}
