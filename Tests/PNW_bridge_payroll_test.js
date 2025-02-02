const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("PNWBridgePayroll Contract", function () {
    let PNWBridgePayroll, pnwBridgePayroll, owner, employer, worker, govAuthority;

    beforeEach(async function () {
        // Get signers
        [owner, employer, worker, govAuthority] = await ethers.getSigners();

        // Deploy the contract
        PNWBridgePayroll = await ethers.getContractFactory("PNWBridgePayroll");
        pnwBridgePayroll = await PNWBridgePayroll.deploy();
        await pnwBridgePayroll.deployed();
    });

    it("Should set the correct owner", async function () {
        expect(await pnwBridgePayroll.owner()).to.equal(owner.address);
    });

    it("Should allow employers to fund payroll", async function () {
        await pnwBridgePayroll.connect(employer).fundPayroll({ value: ethers.utils.parseEther("10") });
        expect(await ethers.provider.getBalance(pnwBridgePayroll.address)).to.equal(ethers.utils.parseEther("10"));
    });

    it("Should process payroll and distribute funds correctly", async function () {
        await pnwBridgePayroll.connect(employer).fundPayroll({ value: ethers.utils.parseEther("10") });

        await expect(pnwBridgePayroll.connect(owner).processPayroll(worker.address, ethers.utils.parseEther("5")))
            .to.emit(pnwBridgePayroll, "PayrollProcessed")
            .withArgs(worker.address, ethers.utils.parseEther("5"));

        expect(await ethers.provider.getBalance(pnwBridgePayroll.address)).to.equal(ethers.utils.parseEther("5"));
    });

    it("Should enforce tax compliance before allowing withdrawals", async function () {
        await pnwBridgePayroll.connect(employer).fundPayroll({ value: ethers.utils.parseEther("10") });

        // Attempt withdrawal before tax compliance
        await expect(pnwBridgePayroll.connect(worker).withdraw(ethers.utils.parseEther("5")))
            .to.be.revertedWith("Tax compliance check failed");

        // Mock tax compliance
        await pnwBridgePayroll.connect(govAuthority).markTaxCompliant(worker.address);

        // Attempt withdrawal after tax compliance
        await expect(pnwBridgePayroll.connect(worker).withdraw(ethers.utils.parseEther("5")))
            .to.emit(pnwBridgePayroll, "WithdrawalProcessed")
            .withArgs(worker.address, ethers.utils.parseEther("5"));
    });

    it("Should not allow non-owners to process payroll", async function () {
        await expect(pnwBridgePayroll.connect(worker).processPayroll(worker.address, ethers.utils.parseEther("5")))
            .to.be.revertedWith("Ownable: caller is not the owner");
    });

    it("Should handle employer tax penalties correctly", async function () {
        await pnwBridgePayroll.connect(employer).fundPayroll({ value: ethers.utils.parseEther("10") });

        // Employer fails to pay tax
        await expect(pnwBridgePayroll.connect(govAuthority).penalizeEmployer(employer.address))
            .to.emit(pnwBridgePayroll, "EmployerPenalized")
            .withArgs(employer.address);

        expect(await pnwBridgePayroll.getEmployerStatus(employer.address)).to.equal("Penalized");
    });
});
