// SPDX-License-Identifier: Proprietary
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract PNiWTrustPool is Ownable, ReentrancyGuard {
    IERC20 public usdcToken;

    struct TrustPoolRecord {
        address worker;
        uint256 totalContributed;
        uint256 lastContributionTimestamp;
    }

    mapping(address => TrustPoolRecord) public trustPool;
    mapping(address => bool) public verifiedChildren;

    event ContributionMade(address indexed worker, uint256 amount);
    event FundsRedeemed(address indexed worker, uint256 amount);

    constructor(address _usdcToken) {
        require(_usdcToken != address(0), "Invalid USDC token address");
        usdcToken = IERC20(_usdcToken);
    }

    // Function to contribute to the trust pool
    function contributeToTrustPool(address worker, uint256 amount) external onlyOwner {
        require(amount > 0, "Contribution must be greater than zero");
        TrustPoolRecord storage record = trustPool[worker];
        record.totalContributed += amount;
        record.lastContributionTimestamp = block.timestamp;

        // Transfer USDC to the contract
        require(usdcToken.transferFrom(msg.sender, address(this), amount), "Transfer failed");
        emit ContributionMade(worker, amount);
    }

    // Function to check worker's trust pool balance
    function getTrustPoolBalance(address worker) external view returns (uint256) {
        return trustPool[worker].totalContributed;
    }

    // Function to redeem funds after turning 18 with KYC verification
    function redeemFunds(address worker, uint256 amount, address child) external nonReentrant {
        require(verifiedChildren[child], "Child must be KYC verified");
        TrustPoolRecord storage record = trustPool[worker];
        require(record.totalContributed >= amount, "Insufficient funds");
        require(amount > 0, "Amount must be greater than zero");

        // Transfer USDC to the child (implement Aleo network integration here)
        require(usdcToken.transfer(child, amount), "Transfer failed");

        record.totalContributed -= amount;
        emit FundsRedeemed(worker, amount);
    }

    // Function for KYC verification of the child (for funds redemption)
    function verifyKYC(address child) external onlyOwner {
        verifiedChildren[child] = true;
    }

    // Function to revoke KYC of the child
    function revokeKYC(address child) external onlyOwner {
        verifiedChildren[child] = false;
    }
}
