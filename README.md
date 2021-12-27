# Minting NFT Contract

This project demonstrates minting NFT(ERC721) with AccessControl and Upgradeable Contract.

# Running

- Use Either Remix or Hardhat

```shell
npx hardhat accounts
npx hardhat compile
npx hardhat clean
npx hardhat test
npx hardhat node
npx hardhat help
REPORT_GAS=true npx hardhat test
npx hardhat coverage
npx hardhat run scripts/deploy.ts
TS_NODE_FILES=true npx ts-node scripts/deploy.ts
npx eslint '**/*.{js,ts}'
npx eslint '**/*.{js,ts}' --fix
npx prettier '**/*.{json,sol,md}' --check
npx prettier '**/*.{json,sol,md}' --write
npx solhint 'contracts/**/*.sol'
npx solhint 'contracts/**/*.sol' --fix
```

# Etherscan verification

To try out Etherscan verification, you first need to deploy a contract to an Ethereum network that's supported by Etherscan, such as Ropsten.

In this project, copy the .env.example file to a file named .env, and then edit it to fill in the details. Enter your Etherscan API key, your Ropsten node URL (eg from Alchemy), and the private key of the account which will send the deployment transaction. With a valid .env file in place, first deploy your contract:

```shell
hardhat run --network ropsten scripts/sample-script.ts
```

Then, copy the deployment address and paste it in to replace `DEPLOYED_CONTRACT_ADDRESS` in this command:

```shell
npx hardhat verify --network ropsten DEPLOYED_CONTRACT_ADDRESS "Hello, Hardhat!"
```

# Contract Upgrade using Gnosis + Hardhat + Openzeppelin

- Based on https://forum.openzeppelin.com/t/openzeppelin-upgrades-step-by-step-tutorial-for-hardhat/3580 and 
- By using Gnosis, we can update Contract throug Gnosis contract

### Write Contract
- Use `@openzeppelin/contracts-upgradeable`
- See how to write upgradable contract in https://docs.openzeppelin.com/learn/upgrading-smart-contracts

### Deploy Contract

- Setup Gnosis Safe 
- Deploy + Transfer ownership

```
async function main() {
  const gnosisSafe = "0x4BACf63107d0B56D6E0BD00945DFdd0ddfF49c45";

  const BoxContract = await ethers.getContractFactory("Box");
  const box = (await upgrades.deployProxy(BoxContract, [42], {
    initializer: "initialize",
  })) as Box;

  await box.deployed();

  console.log("Box Proxy deployed to:", box.address);

  // The owner of the ProxyAdmin can upgrade our contracts
  await upgrades.admin.transferProxyAdminOwnership(gnosisSafe);
  console.log("Transferred ownership of ProxyAdmin to:", gnosisSafe);
}
```

### Upgrade Contract
- Update Contract
  - Add code to Contract directly. There are some limitations(The order of state variables can not be updated) [https://docs.openzeppelin.com/learn/upgrading-smart-contracts#upgrading](https://docs.openzeppelin.com/learn/upgrading-smart-contracts#upgrading)
  ```
  // Box.sol
    // Increments the stored value by 1 (Added for V2)
    function increment() public {
        value = value + 1;
        emit ValueChanged(value);
    }
  ```
- Prepare upgrade
  - This updates Underlying contract so that Proxy can switch later  
    ```javascript
    npx hardhat run --network rinkeby scripts/prepare_upgrade.ts   
    No need to generate any newer typings.
    Preparing upgrade...
    BoxV2 at: 0xF69d41D4ada8B87D92DF5bb04137E829DD368498
    ```
- Upgrade throug Gnosis
  - This will swap implementation Contract under Proxy
  - Select OpenZeppelin App from Gnosis Console  
    ![Screen Shot 2021-12-27 at 2 56 30 PM](https://user-images.githubusercontent.com/6277118/147513263-f25a7d5a-a89b-4c96-9a49-87f0cd748451.png)

  - Set Proxy Address as `Contract address` and Implementation Contract as `New Implementation address`    
    ![Screen Shot 2021-12-27 at 2 49 58 PM](https://user-images.githubusercontent.com/6277118/147513276-4f000dde-868a-4fec-80cc-cdf5ad41d65f.png)

  - Deploy  
    ![Screen Shot 2021-12-27 at 2 50 47 PM](https://user-images.githubusercontent.com/6277118/147513284-8ac39a8a-cbb0-4c59-9581-1394f297b76f.png)

- Testing

```
// Box V1
npx hardhat console --network rinkeby
No need to generate any newer typings.
Welcome to Node.js v14.17.5.
Type ".help" for more information.
> const Box = await ethers.getContractFactory("Box")
undefined
> const box = await Box.attach("0x9dF5A1d59Df0B88F63F280D4AD95b238A885E391")
undefined
> (await box.retrieve()).toString()
'42'
```

```
// Box V2
npx hardhat console --network rinkeby                          
No need to generate any newer typings.
Welcome to Node.js v14.17.5.
Type ".help" for more information.
> const Box = await ethers.getContractFactory("Box")
undefined
> const box = await Box.attach("0x9dF5A1d59Df0B88F63F280D4AD95b238A885E391")
undefined
> (await box.retrieve()).toString()
'42'
> (await box.increment())
{
  hash: '0x768411b26de55ebc1660046bdd70c153575b341a7f1ada12cddcf6efda224b83',
  type: 2,
  accessList: [],
  blockHash: null,
  blockNumber: null,
  transactionIndex: null,
  confirmations: 0,
  from: '0x69D49390a5748454F28611EbC90D0f5a2d679556',
  gasPrice: BigNumber { value: "2500000012" },
  maxPriorityFeePerGas: BigNumber { value: "2500000000" },
  maxFeePerGas: BigNumber { value: "2500000012" },
  gasLimit: BigNumber { value: "35121" },
  to: '0x9dF5A1d59Df0B88F63F280D4AD95b238A885E391',
  value: BigNumber { value: "0" },
  nonce: 9,
  data: '0xd09de08a',
  r: '0x2da8ebec079c05d8f8436fe634bc91638651d0fbe245310c45bb69a401bc729e',
  s: '0x100b951fd63ef080277b6ccec64a21f9aa20328c7fd1fe849cff71377e13a993',
  v: 1,
  creates: null,
  chainId: 4,
  wait: [Function (anonymous)]
}
> (await box.retrieve()).toString()
'42'
> (await box.retrieve()).toString()
'43'
```
