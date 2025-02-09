// pragma solidity ^0.8.20;

interface IFiatUSDCPool {
    function withdrawForPayroll(address _employer, uint256 _amount) external returns (bool);
    function fiatPoolQueries(uint8 queryType, address _employer) external view returns (uint256, uint256, bool);
}

interface IAleoUSDCPool {
    function withdraw_for_payroll(address employer, uint64 amount) external returns (bool);
    function get_employer_balance(address employer) external view returns (uint64);
    function set_employer_obligation(address employer, uint64 obligation) external returns (bool);
    function get_required_pool_balance(address employer) external view returns (uint64);
}

contract PNWPayrollBridge {
    IFiatUSDCPool public fiatUSDCPool;
    IAleoUSDCPool public aleoUSDCPool;

    struct Employer {
        address employerAddress;
        uint256 prepaidWages;
        uint256 prepaidTaxes;
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

    event PayrollProcessed(
        uint8 actionType, 
        address indexed employer, 
        address indexed worker, 
        uint256 amount, 
        bool success, 
        bool usedFiatPool
    );
    event EmployerComplianceUpdated(address indexed employer, bool isCompliant);
    event EmployerObligationSet(address indexed employer, uint64 obligation);

    constructor(address _fiatUSDCPoolAddress, address _aleoUSDCPoolAddress) {
        fiatUSDCPool = IFiatUSDCPool(_fiatUSDCPoolAddress);
        aleoUSDCPool = IAleoUSDCPool(_aleoUSDCPoolAddress);
    }

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

            // Update employer obligations in AleoUSDC Pool
            require(aleoUSDCPool.set_employer_obligation(_employer, uint64(_amount)), "Failed to update employer obligation");

            employers[_employer].prepaidWages -= _amount;
            payrolls[_worker].push(Payroll(_worker, _amount, true, false));

            emit EmployerObligationSet(_employer, uint64(_amount));
            emit PayrollProcessed(1, _employer, _worker, _amount, true, false);
        } 
        else if (actionType == 2) { // Withdraw from Fiat Pool, Use AleoUSDC If Insufficient
            uint256 fiatBalance;
            uint256 aleoBalance;
            bool isAllowed;

            (fiatBalance, aleoBalance, isAllowed) = fiatUSDCPool.fiatPoolQueries(1, _employer);
            require(isAllowed, "Employer is restricted");

            uint256 fee = isZPass ? (_amount * 1) / 100 : (_amount * 2) / 100;
            uint256 finalPayout = _amount - fee;

            if (fiatBalance >= _amount) {
                // Use Fiat Pool
                require(fiatUSDCPool.withdrawForPayroll(_employer, _amount), "Fiat Pool withdrawal failed");
                emit PayrollProcessed(2, _employer, _worker, finalPayout, true, true);
            } 
            else {
                // Insufficient Fiat Pool, verify AleoUSDC pool compliance
                uint256 shortfall = _amount - fiatBalance;
                uint64 requiredBalance = aleoUSDCPool.get_required_pool_balance(_employer);
                uint64 currentBalance = aleoUSDCPool.get_employer_balance(_employer);

                require(currentBalance >= requiredBalance, "AleoUSDC Pool balance below 25% threshold");
                require(currentBalance >= shortfall, "Insufficient AleoUSDC to cover shortfall");

                // Deduct from AleoUSDC pool
                require(aleoUSDCPool.withdraw_for_payroll(_employer, uint64(shortfall)), "AleoUSDC withdrawal failed");

                emit PayrollProcessed(2, _employer, _worker, finalPayout, true, true);
            }
        } 
        else if (actionType == 3) { // Update Employer Compliance
            require(employers[_employer].employerAddress != address(0), "Employer not found");
            employers[_employer].isCompliant = true;
            emit EmployerComplianceUpdated(_employer, true);
        } 
        else if (actionType == 4) { // Restrict Employer
            require(employers[_employer].employerAddress != address(0), "Employer not found");
            restrictedEmployers[_employer] = true;
        } 
        else if (actionType == 5) { // Reinstate Employer
            require(restrictedEmployers[_employer], "Employer is not restricted");
            restrictedEmployers[_employer] = false;
        } 
        else {
            revert("Invalid action type");
        }
    }

    function payrollQueries(uint8 queryType, address _user) external view returns (uint256, bool, bool) {
        if (queryType == 1) { // Get Last Payroll for Worker
            require(payrolls[_user].length > 0, "No payroll history found");
            Payroll memory latest = payrolls[_user][payrolls[_user].length - 1];
            return (latest.amount, latest.processed, latest.usedFiatPool);
        } 
        else if (queryType == 2) { // Get Employer Fiat & AleoUSDC Pool Balance
            (uint256 fiatBalance, uint256 aleoBalance, bool isAllowed) = fiatUSDCPool.fiatPoolQueries(1, _user);
            uint64 requiredBalance = aleoUSDCPool.get_required_pool_balance(_user);
            uint64 aleoCurrentBalance = aleoUSDCPool.get_employer_balance(_user);
            bool meetsThreshold = aleoCurrentBalance >= requiredBalance;

            return (fiatBalance, isAllowed, meetsThreshold);
        } 
        else {
            revert("Invalid query type");
        }
    }
}
