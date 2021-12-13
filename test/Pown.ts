import { expect } from "chai";
import { ethers, waffle } from "hardhat";
// eslint-disable-next-line node/no-missing-import
import { Pown } from "../typechain";

describe("Pown", function () {
  let pown: Pown;
  const provider = waffle.provider;
  beforeEach(async () => {
    const Pown = await ethers.getContractFactory("Pown");
    pown = await Pown.deploy();
    pown.initialize("Pown", "POWN", "https://baseuri.com/");
    await pown.deployed();
  });

  it("should initialize", async function () {
    expect(await pown.tokenURI(1)).to.equal("https://baseuri.com/0/1");

    await pown.setBaseURI("https://baseuri2.com/");

    expect(await pown.tokenURI(1)).to.equal("https://baseuri2.com/0/1");
  });

  it("should mint token", async function () {
    const [wallet] = provider.getWallets();
    const mintTx = await pown.mintToken(1, wallet.address);

    await mintTx.wait();

    expect(await pown.ownerOf(1)).to.equal(wallet.address);
  });

  it("should emit event when minted", async function () {
    const [wallet] = provider.getWallets();

    await expect(await pown.mintToken(1, wallet.address))
      .to.emit(pown, "MintPown")
      .withArgs(1, 1);

    expect(await pown.ownerOf(1)).to.equal(wallet.address);
  });
});
