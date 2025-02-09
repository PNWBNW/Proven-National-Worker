// pragma solidity ^0.8.20;

interface IAleoBridge {
    function bridgePayroll(address employer, address evmWorker, uint256 amount) external returns (bool);
}

contract PNWPayrollBridge {
    IAleoBridge public aleoBridge;

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
    }

    mapping(address => Employer) public employers;
    mapping(address => Payroll[]) public payrolls;
    mapping(address => bool) public restrictedEmployers;
    mapping(address => address) public workerEVMWallets; // Maps Aleo workers to EVM wallets

    event PayrollProcessed(address indexed employer, address indexed worker, uint256 amount, bool success);
    event WorkerEVMWalletRegistered(address indexed worker, address indexed evmWallet);

    constructor(address _aleoBridge) {
        aleoBridge = IAleoBridge(_aleoBridge);
    }

    function registerWorkerEVMWallet(address evmWallet) external {
        workerEVMWallets[msg.sender] = evmWallet;
        emit WorkerEVMWalletRegistered(msg.sender, evmWallet);
    }

    function processPayroll(address employer, address worker, uint256 amount) external {
        require(employers[employer].prepaidWages >= amount, "Insufficient employer balance");
        require(employers[employer].isCompliant, "Employer non-compliant");

        address evmWallet = workerEVMWallets[worker];
        require(evmWallet != address(0), "Worker has not registered an EVM wallet");

        employers[employer].prepaidWages -= amount;
        payrolls[worker].push(Payroll(worker, amount, true));

        // Directly bridge Aleo payroll funds to the worker's EVM wallet
        require(aleoBridge.bridgePayroll(employer, evmWallet, amount), "Aleo-EVM bridge failed");

        emit PayrollProcessed(employer, worker, amount, true);
    }

    function getWorkerEVMWallet(address worker) external view returns (address) {
        return workerEVMWallets[worker];
    }

    function getLastPayroll(address worker) external view returns (Payroll memory) {
        require(payrolls[worker].length > 0, "No payroll history found");
        return payrolls[worker][payrolls[worker].length - 1];
    }
}
