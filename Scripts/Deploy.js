// scripts/deploy.js
const hre = require("hardhat");

async function main() {
    console.log("Deploying PNW Contracts...");

    // Deploy the PNWBridgePayroll contract
    const PNWBridgePayroll = await hre.ethers.getContractFactory("PNWBridgePayroll");
    const pnwBridgePayroll = await PNWBridgePayroll.deploy();
    await pnwBridgePayroll.deployed();
    console.log(`PNWBridgePayroll deployed to: ${pnwBridgePayroll.address}`);

    // Deploy the IGovTaxAPI contract (if not using an existing external API)
    const IGovTaxAPI = await hre.ethers.getContractFactory("IGovTaxAPI");
    const govTaxAPI = await IGovTaxAPI.deploy();
    await govTaxAPI.deployed();
    console.log(`IGovTaxAPI deployed to: ${govTaxAPI.address}`);

    // Verify integration
    console.log("Verifying integration...");
    const taxAmount = await govTaxAPI.getTaxAmount(pnwBridgePayroll.address);
    console.log(`Initial tax requirement for deployment: ${taxAmount} wei`);

    console.log("Deployment completed successfully!");
}

// Handle errors and execute deployment
main().catch((error) => {
    console.error("Deployment failed:", error);
    process.exitCode = 1;
});
