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
  const VegetationCitiesUpdf = await hre.ethers.getContractFactory(
    "VegetationCitiesUpdf"
  );

  // We set the intervals
  const updateInterval = 10;
  // We set the Mock Price Feed’s address deploy by our
  const PricontractAddress = "0x19bE1625bA1a2f1e3e191C52a6283F4AB2F9f9Dc";
  // We set the Verify address deploy by ChainLink for Goerli
  const VerfcontractAddress = "0x2Ca8E0C643bDe4C2E08ab1fA0da3401AdAD7734D";
  // Deploy the Smart Contract
  const vegetation_CitiesUpdf = await VegetationCitiesUpdf.deploy(
    updateInterval,
    PricontractAddress,
    VerfcontractAddress
  );

  await vegetation_CitiesUpdf.deployed();

  console.log(
    "VegetationCitiesUpdf deployed to:",
    vegetation_CitiesUpdf.address
  );
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
