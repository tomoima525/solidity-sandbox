import { expect } from "chai";
import { ethers, upgrades } from "hardhat";
import { Box } from "typechain";

describe("BoxV2.Proxy", () => {
  let box: Box;
  beforeEach(async () => {
    const BoxContract = await ethers.getContractFactory("Box");
    box = (await upgrades.deployProxy(BoxContract, [42], {
      initializer: "initialize",
    })) as Box;
  });

  // Test case
  it("retrieve returns a value previously initialized", async function () {
    // Test if the returned value is the same one
    // Note that we need to use strings to compare the 256 bit integers
    expect((await box.retrieve()).toString()).to.equal("42");
  });

  it("retrieve returns a value previously incremented", async function () {
    // Increment
    await box.increment();

    // Test if the returned value is the same one
    // Note that we need to use strings to compare the 256 bit integers
    expect((await box.retrieve()).toString()).to.equal("43");
  });
});
