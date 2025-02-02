
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract PNWBridge {
    address public owner;
    mapping(address => uint256) public lockedFunds;

    event Bridged(address indexed user, uint256 amount, string targetChain);
    event Withdrawn(address indexed user, uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not contract owner");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function bridgeTokens(uint256 amount, string memory targetChain) external payable {
        require(msg.value == amount, "Incorrect amount sent");
        lockedFunds[msg.sender] += amount;
        emit Bridged(msg.sender, amount, targetChain);
    }

    function withdrawTokens(uint256 amount) external {
        require(lockedFunds[msg.sender] >= amount, "Insufficient funds");
        lockedFunds[msg.sender] -= amount;
        payable(msg.sender).transfer(amount);
        emit Withdrawn(msg.sender, amount);
    }

    function emergencyWithdraw(address to, uint256 amount) external onlyOwner {
        payable(to).transfer(amount);
    }
}
