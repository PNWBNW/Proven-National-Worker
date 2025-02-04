// SPDX-License-Identifier: Proprietary
pragma solidity 0.8.20;

import "worker_identity.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract WorkerIdentityTest is Ownable, ReentrancyGuard {
    WorkerIdentity public workerIdentityContract;

    event TestResult(string testName, bool passed);

    constructor(address _workerIdentityContract) {
        require(_workerIdentityContract != address(0), "Invalid worker identity contract address");

        workerIdentityContract = WorkerIdentity(_workerIdentityContract);
    }

    function testWorkerRegistration(address worker, uint8 workerType, uint64 industryType, bytes32 zkProof, bytes32 merkleKYC) external returns (bool) {
        bool success = workerIdentityContract.registerWorker(worker, workerType, industryType, zkProof, merkleKYC);
        emit TestResult("Worker Registration", success);
        return success;
    }

    function testWorkerVerification(address worker) external view returns (bool) {
        bool verified = workerIdentityContract.isVerifiedWorker(worker);
        emit TestResult("Worker Verification", verified);
        return verified;
    }

    function testKYCVerification(address worker, bytes32 merkleKYC) external returns (bool) {
        bool success = workerIdentityContract.verifyKYC(worker, merkleKYC);
        emit TestResult("KYC Verification", success);
        return success;
    }

    function testIndustryUpdate(address worker, uint64 newIndustry) external returns (bool) {
        bool success = workerIdentityContract.updateIndustry(worker, newIndustry);
        emit TestResult("Industry Update", success);
        return success;
    }

    function testUnauthorizedIndustryUpdate(address unauthorizedUser, address worker, uint64 newIndustry) external returns (bool) {
        (bool success, ) = address(workerIdentityContract).call(
            abi.encodeWithSignature("updateIndustry(address,uint64)", worker, newIndustry)
        );

        bool failed = !success;
        emit TestResult("Unauthorized Industry Update Prevention", failed);
        return failed;
    }
}
