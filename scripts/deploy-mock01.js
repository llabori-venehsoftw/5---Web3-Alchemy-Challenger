// scripts/deploy.js
// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.

const hre = require("hardhat");

async function main() {
  // We get the contract to deploy.
  const MockPrice = await hre.ethers.getContractFactory("MockPriceFeed01");
  const mock_price = await MockPrice.deploy(8, 3034715771688);

  await mock_price.deployed();

  console.log("MockPriceFeed01 deployed to:", mock_price.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
