// SPDX-License-Identifier: Proprietary
pragma solidity 0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract PNWBridgePayroll is Ownable, ReentrancyGuard {
    IERC20 public usdcToken;

    struct Payroll {
        address worker;
        uint256 amount;
        bool processed;
    }

    struct Employer {
        address employer;
        uint256 totalDeposited;
        uint256 taxPaid;
        bool isCompliant;
    }

    mapping(address => Employer) public employers;
    mapping(address => Payroll) public payrolls;

    event PayrollDeposited(address indexed employer, uint256 amount);
    event PayrollProcessed(address indexed worker, uint256 amount);
    event EmployerComplianceUpdated(address indexed employer, bool isCompliant);
    event TaxPaid(address indexed employer, uint256 amount);
    
    modifier onlyCompliantEmployer() {
        require(employers[msg.sender].isCompliant, "Employer is not compliant");
        _;
    }

    constructor(address _usdcToken) {
        require(_usdcToken != address(0), "Invalid USDC token address");
        usdcToken = IERC20(_usdcToken);
    }

    function depositPayroll(uint256 amount) external nonReentrant {
        require(amount > 0, "Deposit must be greater than zero");
        require(usdcToken.transferFrom(msg.sender, address(this), amount), "Transfer failed");

        employers[msg.sender].totalDeposited += amount;
        emit PayrollDeposited(msg.sender, amount);
    }

    function assignPayroll(address worker, uint256 amount) external onlyCompliantEmployer {
        require(worker != address(0), "Invalid worker address");
        require(amount > 0, "Payroll amount must be greater than zero");
        require(employers[msg.sender].totalDeposited >= amount, "Insufficient employer balance");

        payrolls[worker] = Payroll(worker, amount, false);
        employers[msg.sender].totalDeposited -= amount;
    }

    function processPayroll(address worker) external nonReentrant {
        require(worker != address(0), "Invalid worker address");
        Payroll storage payroll = payrolls[worker];
        require(!payroll.processed, "Payroll already processed");

        payroll.processed = true;
        require(usdcToken.transfer(worker, payroll.amount), "Transfer failed");
        
        emit PayrollProcessed(worker, payroll.amount);
    }

    function payTax(uint256 amount) external {
        require(amount > 0, "Tax amount must be greater than zero");
        require(usdcToken.transferFrom(msg.sender, address(this), amount), "Transfer failed");

        employers[msg.sender].taxPaid += amount;
        employers[msg.sender].isCompliant = true; // Assume compliance upon tax payment

        emit TaxPaid(msg.sender, amount);
        emit EmployerComplianceUpdated(msg.sender, true);
    }

    function verifyEmployerCompliance(address employer) external view returns (bool) {
        return employers[employer].isCompliant;
    }
}
