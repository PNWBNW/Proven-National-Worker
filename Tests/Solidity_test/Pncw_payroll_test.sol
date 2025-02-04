// SPDX-License-Identifier: Proprietary
pragma solidity 0.8.20;

import "pncw_payroll.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract PNcWPayrollTest is Ownable, ReentrancyGuard {
    PNcWPayroll public payrollContract;
    IERC20 public usdcToken;

    event TestResult(string testName, bool passed);

    constructor(address _payrollContract, address _usdcToken) {
        require(_payrollContract != address(0), "Invalid payroll contract address");
        require(_usdcToken != address(0), "Invalid USDC token address");

        payrollContract = PNcWPayroll(_payrollContract);
        usdcToken = IERC20(_usdcToken);
    }

    function testPayrollSubmission(address employer, address worker, uint256 amount) external returns (bool) {
        require(amount > 0, "Amount must be greater than zero");

        bool success = payrollContract.submitPayroll(employer, worker, amount);
        emit TestResult("Payroll Submission", success);
        return success;
    }

    function testBatchPayrollSubmission(address employer, address[] memory workers, uint256[] memory amounts) external returns (bool) {
        require(workers.length == amounts.length, "Workers and amounts array length mismatch");

        bool success = payrollContract.submitBatchPayroll(employer, workers, amounts);
        emit TestResult("Batch Payroll Submission", success);
        return success;
    }

    function testPayrollProcessing(address worker) external returns (bool) {
        bool success = payrollContract.processPayroll(worker);
        emit TestResult("Payroll Processing", success);
        return success;
    }

    function testBatchPayrollProcessing(address[] memory workers) external returns (bool) {
        bool success = payrollContract.processBatchPayroll(workers);
        emit TestResult("Batch Payroll Processing", success);
        return success;
    }

    function testEmployerCompliance(address employer) external view returns (bool) {
        bool compliant = payrollContract.checkEmployerCompliance(employer);
        emit TestResult("Employer Compliance Check", compliant);
        return compliant;
    }

    function testRollupBatchProcessing(address employer) external returns (bool) {
        bool success = payrollContract.processRollupBatch(employer);
        emit TestResult("Rollup Batch Processing", success);
        return success;
    }

    function testPayrollRollupUnderHighNetworkCongestion(address employer, address[] memory workers, uint256[] memory amounts) external returns (bool) {
        require(workers.length == amounts.length, "Workers and amounts array length mismatch");

        // Simulate high congestion conditions
        uint256 gasLimit = block.gaslimit;
        require(gasLimit < 15_000_000, "Network congestion not simulated properly");

        bool success = payrollContract.processRollupBatch(employer);
        emit TestResult("Payroll Rollup Under High Network Congestion", success);
        return success;
    }
}
