import { ethers, upgrades } from "hardhat";

async function main() {
  const proxyAddress = "0x9dF5A1d59Df0B88F63F280D4AD95b238A885E391";

  const BoxV2 = await ethers.getContractFactory("Box");
  console.log("Preparing upgrade...");
  const boxV2Address = await upgrades.prepareUpgrade(proxyAddress, BoxV2);
  console.log("BoxV2 at:", boxV2Address);
}

main()
  .then(() => {
    process.exitCode = 0;
  })
  .catch((error) => {
    console.error(error);
    process.exitCode = 1;
  });
