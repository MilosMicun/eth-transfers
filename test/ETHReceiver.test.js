const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("DAY 43 — ETH Transfers", function () {
  let receiver, owner, alice;

  beforeEach(async () => {
    [owner, alice] = await ethers.getSigners();
    const ETHReceiver = await ethers.getContractFactory("ETHReceiver");
    receiver = await ETHReceiver.deploy();
    await receiver.waitForDeployment();
  });

  it("receive(): accepts plain ETH transfer (empty calldata)", async () => {
    const tx = await owner.sendTransaction({
      to: await receiver.getAddress(),
      value: ethers.parseEther("1"),
    });

    await expect(tx).to.emit(receiver, "Received");

    // plain ETH does NOT credit balances mapping
    const bal = await receiver.balances(owner.address);
    expect(bal).to.equal(0n);
  });

  it("fallback(): accepts ETH with calldata", async () => {
    const tx = await owner.sendTransaction({
      to: await receiver.getAddress(),
      value: ethers.parseEther("1"),
      data: "0x1234",
    });

    await expect(tx).to.emit(receiver, "Received");
  });

  it("deposit(): credits user balance + emits Deposit", async () => {
    const value = ethers.parseEther("1");

    const tx = await receiver.connect(alice).deposit({ value });

    await expect(tx)
      .to.emit(receiver, "Deposit")
      .withArgs(alice.address, value);

    const bal = await receiver.balances(alice.address);
    expect(bal).to.equal(value);
  });
});