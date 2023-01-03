require("@nomicfoundation/hardhat-toolbox");
require("@nomiclabs/hardhat-etherscan");
require("dotenv").config();

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

const GOERLI_URL = process.env.GOERLI_URL;
const PRIVATE_KEY = process.env.PRIVATE_KEY;

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  //solidity: "0.8.17",    // For deploy the principals Smart Contract
  // solidity: "0.6.8", // For deploy the MockPriceFeed
  solidity: {
    compilers: [
      {
        version: "0.8.17",
      },
      {
        version: "0.7.6",
      },
      {
        version: "0.6.12",
      },
    ],
  },
  networks: {
    goerli: {
      url: GOERLI_URL,
      accounts: [PRIVATE_KEY],
    },
  },
  etherscan: {
    apiKey: "4H3N6G1PG17FGV2G968PJ8DIQ3DJSX1W1R", // Your Etherscan API key
  },
  settings: {
    optimizer: {
      enabled: true,
      runs: 1000,
    },
  },
};

task(
  "flat",
  "Flattens and prints contracts and their dependencies (Resolves licenses)"
)
  .addOptionalVariadicPositionalParam(
    "files",
    "The files to flatten",
    undefined,
    types.inputFile
  )
  .setAction(async ({ files }, hre) => {
    let flattened = await hre.run("flatten:get-flattened-sources", { files });

    // Remove every line started with "// SPDX-License-Identifier:"
    flattened = flattened.replace(
      /SPDX-License-Identifier:/gm,
      "License-Identifier:"
    );
    flattened = `// SPDX-License-Identifier: MIXED\n\n${flattened}`;

    // Remove every line started with "pragma experimental ABIEncoderV2;" except the first one
    flattened = flattened.replace(
      /pragma experimental ABIEncoderV2;\n/gm,
      (
        (i) => (m) =>
          !i++ ? m : ""
      )(0)
    );
    console.log(flattened);
  });
