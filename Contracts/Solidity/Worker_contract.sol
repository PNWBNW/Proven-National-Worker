pragma solidity ^0.8.20;

contract WorkerIdentity {
    struct Worker {
        address workerAddress;
        bool isVerified;
        bool isZPass;
        string industry;
        bool isEligibleForPayroll;
    }

    mapping(address => Worker) public workers;
    mapping(address => bool) public restrictedWorkers;

    event WorkerAction(uint8 actionType, address indexed worker, string industry, bool isVerified, bool isEligible);
    event WorkerReported(address indexed worker, address indexed reporter, string reason);

    function workerManagement(
        uint8 actionType, 
        address _worker, 
        string memory _industry, 
        bool _isVerified, 
        bool _isEligible
    ) external {
        if (actionType == 1) { // Register Worker
            require(workers[msg.sender].workerAddress == address(0), "Worker already registered");
            workers[msg.sender] = Worker(msg.sender, _isVerified, false, _industry, _isEligible);
            emit WorkerAction(1, msg.sender, _industry, _isVerified, _isEligible);
        } 
        else if (actionType == 2) { // Update Worker Verification (ZPass Optional)
            require(workers[_worker].workerAddress != address(0), "Worker not found");
            workers[_worker].isVerified = _isVerified;
            workers[_worker].isZPass = _isVerified; // If verified, assume ZPass usage
            emit WorkerAction(2, _worker, workers[_worker].industry, _isVerified, workers[_worker].isEligibleForPayroll);
        } 
        else if (actionType == 3) { // Update Payroll Eligibility
            require(workers[_worker].workerAddress != address(0), "Worker not found");
            workers[_worker].isEligibleForPayroll = _isEligible;
            emit WorkerAction(3, _worker, workers[_worker].industry, workers[_worker].isVerified, _isEligible);
        } 
        else if (actionType == 4) { // Restrict Worker
            require(workers[_worker].workerAddress != address(0), "Worker not found");
            restrictedWorkers[_worker] = true;
        } 
        else if (actionType == 5) { // Reinstate Worker
            require(restrictedWorkers[_worker], "Worker is not restricted");
            restrictedWorkers[_worker] = false;
        } 
        else {
            revert("Invalid action type");
        }
    }

    function reportWorker(address _worker, string memory _reason) external {
        require(workers[_worker].workerAddress != address(0), "Worker not found");
        emit WorkerReported(_worker, msg.sender, _reason);
    }

    function workerQueries(uint8 queryType, address _worker) external view returns (bool, bool, string memory, bool) {
        if (queryType == 1) { // Get Worker Details
            Worker memory w = workers[_worker];
            return (w.isVerified, w.isZPass, w.industry, w.isEligibleForPayroll);
        } 
        else {
            revert("Invalid query type");
        }
    }
}
