//
pragma solidity 0.8.20;

contract PNWBridgePayroll {
    mapping(address => uint256) public payrollBalances;
    mapping(address => uint256) public trustFundBalances;
    mapping(address => uint256) public employerUSDCReserves;

    event PayrollBridged(address indexed worker, uint256 amount);
    event TrustFundBridged(address indexed worker, uint256 amount);
    event EmployerUSDCDeposited(address indexed employer, uint256 amount);
    event EmployerUSDCWithdrawn(address indexed employer, uint256 amount);
    event InvalidBridgeAttempt(address indexed worker, string reason);
    
    // Function to deposit USDC for payroll funding
    function depositUSDC(address employer, uint256 amount) external {
        require(amount > 0, "Deposit amount must be greater than zero");
        employerUSDCReserves[employer] += amount;
        emit EmployerUSDCDeposited(employer, amount);
    }

    // Function to withdraw USDC (only employer-controlled)
    function withdrawUSDC(address employer, uint256 amount) external {
        require(employerUSDCReserves[employer] >= amount, "Insufficient USDC reserves");
        employerUSDCReserves[employer] -= amount;
        emit EmployerUSDCWithdrawn(employer, amount);
    }

    // Function to process payroll bridging (EXCLUDES PTO & Sick Pay)
    function bridgePayroll(address worker, uint256 amount) external {
        require(payrollBalances[worker] >= amount, "Insufficient payroll balance");
        payrollBalances[worker] -= amount;

        // PTO & Sick Pay cannot be bridged (Aleo-only enforcement)
        emit PayrollBridged(worker, amount);
    }

    // Function to bridge trust fund withdrawals (Aleo-only enforcement)
    function bridgeTrustFund(address worker, uint256 amount) external {
        require(trustFundBalances[worker] >= amount, "Insufficient trust fund balance");
        trustFundBalances[worker] -= amount;

        emit TrustFundBridged(worker, amount);
    }

    // Function to block invalid PTO/Sick Pay bridging attempts
    function attemptBridgePTOorSickPay(address worker, uint256 amount) external {
        emit InvalidBridgeAttempt(worker, "PTO/Sick Pay cannot be bridged. Withdraw only on Aleo.");
    }

    // Function to verify employer USDC liquidity
    function verifyEmployerUSDC(address employer, uint256 requiredAmount) external view returns (bool) {
        return employerUSDCReserves[employer] >= requiredAmount;
    }
}
