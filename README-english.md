# Solution to Challenger #5 Alchemy University

Objetives:

In this tutorial, you're going to build a Dynamic NFT using Chainlink’s decentralized and cryptographically 
secured oracle network to get and track asset price data.

Then, you will use the automations from the Chainlink Keepers Network to automate your NFT smart contract to 
update the NFTs according to the asset price data you're tracking.

If the market price moves up, the smart contract will randomly pick the NFT’s URI to point to one of these 
three bullish images and the NFT will be dynamically updated.

## Beginning 🚀

These instructions will allow you to get a copy of the project running on your local machine for
development and testing purposes.

See **Deployment** for how to deploy the project.

### Prerequisites 📋

1. IDE

In this tutorial, we're going to use the VS Code IDE and the built-in “London VM” blockchain network, but
using Hardhat Smart Contract development framework.

2. Github Repo

Here, there is a [Github repo for the Dynamic NFT tutoriallinks text](https://github.com/zeuslawyer/
chainlink-dynamic-nft-alchemy) that we made for you.

The repo reflects the structure we will follow.

- The main branch

The main branch contains the baseline ERC721 Token using the OpenZeppelin Wizard.

- The price-feeds branch

The price-feeds branch adds the Chainlink Keepers implementation and connects to the Chainlink Asset price
data that we'll use to track a specific asset’s price.

- The randomness branch

The randomness branch contains the logic to add randomness so that our Dynamic NFT is chosen randomly from
the NFT metadata URIs we have in our smart contract.

This bit is for you to do as a special assignment to build your skills!

3. IPFS Companion

Install the IPFS Companion Browser Extension (for any Chromium based browser).

This will hold your token’s URI and metadata information.

4. Faucets and Testnet Tokens

Make sure your MetaMask wallet is connected to Rinkeby.

Once your wallet is connected to Goerli, get Goerli ETH from Alchemy's Goerli faucet.

You will also need to get testnet LINK tokens.

For your assignment, you will add randomness, but you’ll deploy to Ethereum's Goerli testnet.

If you need Goerli testnet tokens, get Goerli ETH from Alchemy's Goerli faucet.

### Instalation 🔧

_Installation of all the necessary framework/libraries_

Open your terminal and create a new directory:

```
mkdir 5-APIsSmartContractsChainlink
cd 5-APIsSmartContractsChainlink
```

Install Hardhat running the following command:

```
yarn install hardhat
```

Then initialize hardhat to create the project boilerplates:

```
npx hardhat init
```

You should then see a welcome message and options on what you can do. Select Create a JavaScript
project (All default setting are cool):

```
llabori@Xubuntu64Bits-virtual-machine:~/BlockChains/AlchemyUniversity/5-APIsSmartContractsChainlink$ npx
hardhat init
888    888                      888 888               888
888    888                      888 888               888
888    888                      888 888               888
8888888888  8888b.  888d888 .d88888 88888b.   8888b.  888888
888    888     "88b 888P"  d88" 888 888 "88b     "88b 888
888    888 .d888888 888    888  888 888  888 .d888888 888
888    888 888  888 888    Y88b 888 888  888 888  888 Y88b.
888    888 "Y888888 888     "Y88888 888  888 "Y888888  "Y888

Welcome to Hardhat v2.12.4

✔ What do you want to do? · Create a JavaScript project
✔ Hardhat project root: · /home/llabori/BlockChains/AlchemyUniversity/5-APIsSmartContractsChainlink
✔ Do you want to add a .gitignore? (Y/n) · y
✔ Do you want to install this sample project's dependencies with yarn (@nomicfoundation/
hardhat-toolbox @nomicfoundation/hardhat-network-helpers @nomicfoundation/hardhat-chai-matchers
@nomiclabs/hardhat-ethers @nomiclabs/hardhat-etherscan chai ethers hardhat-gas-reporter
solidity-coverage @typechain/hardhat typechain @typechain/ethers-v5 @ethersproject/abi @ethersproject/
providers)? (Y/n) · y
```

To check if everything works properly, run:

```
npx hardhat test
```

If all is good, you must see:

```
llabori@Xubuntu64Bits-virtual-machine:~/BlockChains/AlchemyUniversity/5-APIsSmartContractsChainlink$ npx
hardhat test
Compiled 1 Solidity file successfully


  Lock
    Deployment
      ✔ Should set the right unlockTime (2757ms)
      ✔ Should set the right owner (41ms)
      ✔ Should receive and store the funds to lock
      ✔ Should fail if the unlockTime is not in the future (79ms)
    Withdrawals
      Validations
        ✔ Should revert with the right error if called too soon (66ms)
        ✔ Should revert with the right error if called from another account (58ms)
        ✔ Shouldn't fail if the unlockTime has arrived and the owner calls it (82ms)
      Events
        ✔ Should emit an event on withdrawals (76ms)
      Transfers
        ✔ Should transfer the funds to the owner (79ms)


  9 passing (3s)
```

Now we'll need to install the OpenZeppelin package to get access to the ERC721 smart contract standard
that we'll use as a template to build our NFTs smart contract.

```
yarn add @openzeppelin/contracts
```

We should observe something similar to:

```
llabori@Xubuntu64Bits-virtual-machine:~/BlockChains/AlchemyUniversity/5-APIsSmartContractsChainlink$ yarn
add @openzeppelin/contracts
yarn add v1.22.17
warning package.json: No license field
warning No license field
[1/4] Resolving packages...
[2/4] Fetching packages...
[3/4] Linking dependencies...
warning " > @nomicfoundation/hardhat-toolbox@2.0.0" has unmet peer dependency "@types/chai@^4.2.0".
warning " > @nomicfoundation/hardhat-toolbox@2.0.0" has unmet peer dependency "@types/mocha@^9.1.0".
warning " > @nomicfoundation/hardhat-toolbox@2.0.0" has unmet peer dependency "@types/node@>=12.0.0".
warning " > @nomicfoundation/hardhat-toolbox@2.0.0" has unmet peer dependency "ts-node@>=8.0.0".
warning " > @nomicfoundation/hardhat-toolbox@2.0.0" has unmet peer dependency "typescript@>=4.5.0".
warning " > @typechain/ethers-v5@10.2.0" has unmet peer dependency "@ethersproject/bytes@^5.0.0".
warning " > @typechain/ethers-v5@10.2.0" has unmet peer dependency "typescript@>=4.3.0".
warning "@typechain/ethers-v5 > ts-essentials@7.0.3" has unmet peer dependency "typescript@>=3.7.0".
warning " > typechain@8.1.1" has unmet peer dependency "typescript@>=4.3.0".
[4/4] Building fresh packages...
success Saved lockfile.
warning No license field
success Saved 1 new dependency.
info Direct dependencies
└─ @openzeppelin/contracts@4.8.0
info All dependencies
└─ @openzeppelin/contracts@4.8.0
Done in 25.94s.Your inputs will now store in their respective variables the addresses we'll write inside.
```

Now we download or copy the source code of the main Smart Contract found in the Main Branch of the GitHub
repository referenced above [Github repo for the Dynamic NFT tutoriallinks text](https://github.com/zeuslawyer/chainlink-dynamic-nft-alchemy)

## Development of changes in the source Code ⚙️

The firs steps to creating a updatable NFT on our case are:

_Installation of the necessary dependencies_

Open your terminal and type the follow:

```
yarn add @chainlink/contracts
```

You should observe something similar to:

```
llabori@Xubuntu64Bits-virtual-machine:~/BlockChains/AlchemyUniversity/5-APIsSmartContractsChainlink$ yarn
add @chainlink/contracts
yarn add v1.22.17
warning package.json: No license field
warning No license field
[1/4] Resolving packages...
[2/4] Fetching packages...
[3/4] Linking dependencies...
warning " > @nomicfoundation/hardhat-toolbox@2.0.0" has unmet peer dependency "@types/chai@^4.2.0".
warning " > @nomicfoundation/hardhat-toolbox@2.0.0" has unmet peer dependency "@types/mocha@^9.1.0".
warning " > @nomicfoundation/hardhat-toolbox@2.0.0" has unmet peer dependency "@types/node@>=12.0.0".
warning " > @nomicfoundation/hardhat-toolbox@2.0.0" has unmet peer dependency "ts-node@>=8.0.0".
warning " > @nomicfoundation/hardhat-toolbox@2.0.0" has unmet peer dependency "typescript@>=4.5.0".
warning " > @typechain/ethers-v5@10.2.0" has unmet peer dependency "@ethersproject/bytes@^5.0.0".
warning " > @typechain/ethers-v5@10.2.0" has unmet peer dependency "typescript@>=4.3.0".
warning "@typechain/ethers-v5 > ts-essentials@7.0.3" has unmet peer dependency "typescript@>=3.7.0".
warning " > typechain@8.1.1" has unmet peer dependency "typescript@>=4.3.0".
[4/4] Building fresh packages...
success Saved lockfile.
warning No license field
success Saved 5 new dependencies.
info Direct dependencies
└─ @chainlink/contracts@0.5.1
info All dependencies
├─ @chainlink/contracts@0.5.1
├─ @eth-optimism/contracts@0.5.39
├─ @eth-optimism/core-utils@0.12.0
├─ @openzeppelin/contracts-v0.7@3.4.2
└─ bufio@1.2.0
Done in 122.84s.
```

_We update the values and variables that are needed in our Smart Contract_

Update the links in the IPFS URIs:

Now you need to make sure you update the links in the IPFS URIs for vegetationUrisIpfs and citiesUrisIpfs
to point to the files hosted on you IPFS.

There are a few ways to host files and documents on the IPFS network. Mainly we could establish two ways:
a.- Install your own network node (for which you will need to meet certain hardware requirements as well as install certain software).

b.- Use the potential of services provided by third parties (e.g. Infura, Chainlink, others, etc.).

In our case we use a service provided by a third party with which we have the possibility to host both the images and their corresponding metadata files on the network; with which we obtain:

```
// For Images

"https://ipfs.io/ipfs/Qme2nQTmjPJ1gqFZdC8rVS3AEae9fXtYzbcPi6opRu3nFD?filename=vegetation01.png"
"https://ipfs.io/ipfs/QmZZUBWLi9CAjzEGRnyCB2LTnEUYdSSzSHtjarqkwzfK3J?filename=vegetation02.png"
"https://ipfs.io/ipfs/QmZic4h6kf3xRS9sqhAwbtKFeLtwrb2QcezygDKRuUuyXM?filename=vegetation03.png"

"https://ipfs.io/ipfs/QmfZ4qx9U9CAJif3RhqgV2CZjMtp5ptpRS6LvFXKJiNiFC?filename=cities01.png"
"https://ipfs.io/ipfs/QmS1MsNFdZxYsiVBKKB4Dz5VSznuZfLfzZR8bjwc8gsmay?filename=cities02.png"
"https://ipfs.io/ipfs/Qmej59n5SumntWipapMLrsrLPptCchuifSgozMm99axf2f?filename=cities03.png"

// For Metadata
"https://ipfs.io/ipfs/QmbqiQuNFYuTX55UdSyCSzaPnPWGvduQnq2WbLwwhA9o49?filename=vegetation01.json"
"https://ipfs.io/ipfs/QmQESBNenESMZ6i3BpYLnHigiRHHNh2mCg9hrHGE66EyZS?filename=vegetation02.json"
"https://ipfs.io/ipfs/QmQh3tXJ1NF6gauVGxeW9pumtiBS4NfepBN8C1xVzWjRWx?filename=vegetation03.json"

"https://ipfs.io/ipfs/QmZM76tG6opdKPTXnUsmniATac2ti237WDLrJgdZfSRuw1?filename=cities01.json"
"https://ipfs.io/ipfs/QmVnifCC387zLCafq5X4dKSWpPzGhmRTNU6AaUYUfp2GEQ?filename=cities02.json"
"https://ipfs.io/ipfs/QmQeU4uypSGgop7V8x6Xt5vZsRSKGMft4Lu6kLWao89d6m?filename=cities03.json"

```

_Deploy your Vegetation&Cities.sol smart contract to the Ethereum Goerli testnet using Alchemy and_
_MetaMask_

When you open your hardhat.config.js file, you will see some sample deploy code. Delete that and paste
this version in:

```
// hardhat.config.js

require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config()

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

const GOERLI_URL = process.env.GOERLI_URL;
const PRIVATE_KEY = process.env.PRIVATE_KEY;

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  solidity: "0.8.17",
  networks: {
    goerli: {
      url: GOERLI_URL,
      accounts: [PRIVATE_KEY]
    }
  },
  settings: {
    optimizer: {
      enabled: true,
      runs: 1000,
    }
  }
};
```

Now before we can do our deployment, we need to make sure we get one last tool installed, the dotenv
module. As its name implies, dotenv helps us connect a .env file to the rest of our project. Let's set
it up.

Install dotenv:

```
llabori@Xubuntu64Bits-virtual-machine:~/BlockChains/AlchemyUniversity/5-APIsSmartContractsChainlink$ npm
install dotenv

added 1 package, and audited 924 packages in 34s

129 packages are looking for funding
  run `npm fund` for details
```

Create a .env file (Using of VSCode IDE) Populate the .env file with the variables that we need:

```
GOERLI_URL=https://eth-goerli.alchemyapi.io/v2/<your api key>
GOERLI_API_KEY=<your api key>
PRIVATE_KEY=<your metamask api key>
```

Also, in order to get what you need for environment variables, you can use the following resources:

    GOERLI_URL - sign up for an account on Alchemy, create an Ethereum -> Goerli app, and use the HTTP
    URL
    GOERLI_API_KEY - from your same Alchemy Ethereum Goerli app, you can get the last portion of the
    URL, and that will be your API KEY
    PRIVATE_KEY - Follow these instructions from MetaMask to export your private key.

Make sure that .env is listed in your .gitignore:

```
node_modules
.env
coverage
coverage.json
typechain
typechain-types

#Hardhat files
cache
artifacts
```

Let's create a new file scripts/deploy.js that will be super simple, just for deploying our
contract to any network we choose later (we'll choose Goerli later if you haven't noticed).

The deploy.js file should look like this:

```
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
  const Vegetation_Cities = await hre.ethers.getContractFactory("Vegetation&Cities");
  const vegetation_Cities = await Vegetation_Cities.deploy();

  await buyMeACoffee.deployed();

  console.log("Vegetation&Cities deployed to:", vegetation_Cities.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
```

Now with this deploy.js script coded and saved, if you run the following command:

```
npx hardhat run scripts/deploy.js --network goerli
```

You'll see one single line printed out:

```
llabori@Xubuntu64Bits-virtual-machine:~/BlockChains/AlchemyUniversity/5-APIsSmartContractsChainlink$ npx
hardhat run scripts/deploy.js --network goerli
Compiled 23 Solidity files successfully
VegetationCities deployed to: 0xAB6bA7Ad6d17F196083b1c7Ff4d442A1AD11aBcf (The address of your Smart
contrat must be different from this one )
```

We verify that the SmartContract is truly deployed on the Goerli Tesnet using
https://goerli.etherscan.io/

![Alt text](https://www.github.com/assets.digitalocean.com/articles/alligator/boo.svg "a title")

_Verify & Publish Contract Source Code_

We go to the following address:

https://goerli.etherscan.io/verifyContract

and fill in all the requested data. For this particular case, as the Smart Contract imports other Smart
Contracts in its code, it will not be possible to paste only the source code of the Smart Contract, but
we will have to resort to a Hardhat feature to join the code of all the Smart Contracts in a single
file. For the generation of such a file we use:

```
npx hardhat flatten contracts/VegetationCities.sol > contracts/VegetationCities_flat.sol
```

We now copy the code from the newly generated file and use it in the EtherScan Web interface to verify
and publish the Smart Contract.

Then we to see:

```
ParserError: Multiple SPDX license identifiers found in source file. Use "AND" or "OR" to combine multiple licenses. Please see https://spdx.org for more information.
```

Looking for a solution to this eventuality, we came across the option of including a task in the code of
the hardhat.config.js file that takes care of both merging all Smart Contracts into a single file as well
as unifying their licenses into a single one to bridge the incompatibility of them. The code to include in
the hardhat.config.js file is:

```
task("flat", "Flattens and prints contracts and their dependencies (Resolves licenses)")
  .addOptionalVariadicPositionalParam("files", "The files to flatten", undefined, types.inputFile)
  .setAction(async ({ files }, hre) => {
    let flattened = await hre.run("flatten:get-flattened-sources", { files });

    // Remove every line started with "// SPDX-License-Identifier:"
    flattened = flattened.replace(/SPDX-License-Identifier:/gm, "License-Identifier:");
    flattened = `// SPDX-License-Identifier: MIXED\n\n${flattened}`;

    // Remove every line started with "pragma experimental ABIEncoderV2;" except the first one
    flattened = flattened.replace(/pragma experimental ABIEncoderV2;\n/gm, ((i) => (m) => (!i++ ? m : ""))(0));
    console.log(flattened);
  });
```

Now the verification and publication of the source code for the Smart Contract will be executed through the
command window (Terminal) of the IDE. To do this we must add the following code to our hardhat.config.js
file:

```
etherscan: {
    apiKey: "4H3N6G1PG17FGV2G968PJ8DIQ3DJSX1W1R", // Your Etherscan API key
  },
```

The API Keys are obtained by logging into the Web system https://etherscan.io and generating a new
application for which in the configuration section we will obtain the respective API Key.

We then execute the following instruction from the command window:

```
npx hardhat verify --contract contracts/VegetationCities_flat.sol:VegetationCities --network goerli 0xAB6bA7Ad6d17F196083b1c7Ff4d442A1AD11aBcf
```

Finally we to see:

```
llabori@Xubuntu64Bits-virtual-machine:~/BlockChains/AlchemyUniversity/5-APIsSmartContractsChainlink$ npx hardhat verify --contract contracts/VegetationCities_flat.sol:VegetationCities --network goerli 0xAB6bA7Ad6d17F196083b1c7Ff4d442A1AD11aBcf
Nothing to compile
Successfully submitted source code for contract
contracts/VegetationCities_flat.sol:VegetationCities at 0xAB6bA7Ad6d17F196083b1c7Ff4d442A1AD11aBcf
for verification on the block explorer. Waiting for verification result...

Successfully verified contract VegetationCities on Etherscan.
https://goerli.etherscan.io/address/0xAB6bA7Ad6d17F196083b1c7Ff4d442A1AD11aBcf#code
```

With this we can now interact with our Smart Contract from the EtherScan web interface.

_Interact with our Smart Contract_

Copy your Metamask wallet address and paste it in the safeMint field to mint a token (Use the Web Interface
of goerli.etherscan.io, Write Contract):

![Alt text](https://www.github.com/assets.digitalocean.com/articles/alligator/boo.svg "a title")

Use the Web Interface of goerli.etherscan.io, Read Contract; Select TokenURI and type de 0 numeral in this field:

![Alt text](https://www.github.com/assets.digitalocean.com/articles/alligator/boo.svg "a title")

Because your first token has a token ID of zero, it will return the tokenURI that points to the
‘vegetation01` JSON file.

![Alt text](https://www.github.com/assets.digitalocean.com/articles/alligator/boo.svg "a title")

_Make your contract Keepers Compatible_

Now, we can make our NFT Contract not just dynamic, but automatically dynamic!

This code is referenced in the [price-feeds branch](https://github.com/zeuslawyer/chainlink-dynamic-nft-alchemy/tree/price-feeds/contracts) of the repo.

First, we add the automation layer with Chainlink Keepers, which means we need to extend our NFT smart
contract to make it “Keepers Compatible”.

Here are the key steps:

    * Import "@chainlink/contracts/src/v0.8/KeeperCompatible.sol"
    * Make your contract inherit from KeeperCompatibleInterface
    * Adjust your constructor to take in an interval period that gets set as a contract statevariable and
    this sets the intervals at which the automation will occur.
    * Implement checkUpkeep and performUpkeep functions in the NFT smart contract so that we satisfy the
    interface.
    * [Register the “upkeep” contract](https://docs.chain.link/chainlink-automation/register-upkeep) with
    the Chainlink Keeper Network.

The Chainlink Keepers Network will check our checkUpkeep() function every time a new block is added to the 
blockchain and simulate the execution of our function off-chain!

That function returns a boolean:

    If it's false, that means no automated upkeep is due yet.
    If it returns true, that means the interval we set has passed, and an upkeep action is due.

The Keepers Network calls our performUpkeep() function automatically, and run logic on-chain.

No developer action is needed.

It’s like magic!

Our checkUpkeep will be straightforward because we just want to check if the interval has expired and
return that boolean, but our performUpkeep needs to check a price feed.

For that, we need to get our Smart Contract to interact with Chainlinks price feed oracles.

We will use the [BTC/USD feed proxy contract on Goerli](https://goerli.etherscan.io/address/
0xA39434A63A52E749F02807ae27335515BA4b07F7), but you can [choose another one](https://docs.chain.link/data-feeds/price-feeds/addresses/?network=ethereum#Goerli%20Testnet) from the Goerli network.

![Alt text](https://www.github.com/assets.digitalocean.com/articles/alligator/boo.svg "a title")

_Interact with Chainlink Price Feeds_

To interact with the Price Feed oracle of choice, we need to use the AggregatorV3Interface.

In our reference code in the [price-feeds branch](https://github.com/zeuslawyer/
chainlink-dynamic-nft-alchemy/tree/price-feeds/contracts), the constructor accepts the address of the
aggregator oracle as a parameter in the constructor. Accepting a parameter at deploy time is super useful
as it makes it configurable when we develop locally.

To interact with a live oracle on Goerli, our contract needs to be deployed to Goerli. That's necessary
for integration testing but while developing it slows us down a bit.

How do we speed up our local edit-compile-debug development loop?

_Mocking Live Net Smart Contracts_

Instead of constantly re-deploying to a test network like Goerli, paying test ETH, etc, we can (while
iteracting on our smart contract) use mocks.

For example we can mock the price feed aggregator contract using this [mock price feed contract](https://
github.com/zeuslawyer/chainlink-dynamic-nft-alchemy/blob/price-feeds/contracts/MockPriceFeed.sol).

The advantage is that we can deploy the mock in our Remix, in-browser London VM environment and adjust
the values it returns to test different scenarios, without having to constantly deploy new contracts to
live networks, then approve transactions via MetaMask and pay test ETH each time.

Here's what to do:

    Copy that file over to your Remix
    Save it as MockPriceFeed
    Deploy it

It’s simply importing the [mock that Chainlink has written](https://github.com/smartcontractkit/
chainlink/blob/develop/contracts/src/v0.6/tests/MockV3Aggregator.sol) for the price feed aggregator
proxy. NOTE = You must change the compiler to 0.6.x to compile this mock.

When deploying a mock you need to pass in the decimals the price feed will calculate prices with.

You can find these from a [list of price feed contract addresses](https://docs.chain.link/docs/
ethereum-addresses/), after clicking “Show More Details”

The BTC/USD feed takes in 8 decimals.

You also need to pass in the initial value of the feed.

Since I randomly chose the BTC/USD asset price, I passed it an old value I got when I was testing:
3034715771688

NOTE = When you deploy it locally, be sure to note the contract address that Remix gives you.

This is what you pass into the constructor of your NFT Smart Contract so that it knows to use the mock as
the price feed.

You should also play around with your locally deployed mock price feed.

Call latestRoundData to see the latest price from the mock price feed, and other data that conforms to
the Chainlink Price Feed API.

You can update the price by calling updateAnswer and passing in a higher or lower value (to simulate the
rise and fall of prices).

You could make the price drop by passing 2534715771688 or rise by passing in 4534715771688.

Super handy for in-browser testing of your NFT smart contract!

Going back to the NFT smart contract, be sure to update it to reflect the reference code.

So here’s what I suggest you do:

    First read this short doc on how to make our NFT smart contract Keepers compatible
    Read the simple way to use data feeds
    Deploy the mock data feed
    Read its source code to understand how Chainlink Price Feed smart contracts are written

Once you've read these resources, give it a shot yourself.

If you want to jump straight to our implementation, it is on the price-feeds branch.

Note that we set the price feed as a public state variable so we can change it, using the setPriceFeed()
helper method, and we also added the key dynamic NFT logic to performUpkeep().

Every time the Chainlink Keepers network calls that, it will execute that logic on-chain and if the
Chainlink Price Feed reports a price different from what we last tracked, the URIs are updated.

This demo doesn’t optimize for the gas costs of updating all Token URIs in the smart contract. We focus
on how NFTs can be made dynamic. The costs of updating all NFTs that are in circulation could be
extremely high on the Ethereum network so consider that carefully, and explore layer 2 solutions or other
architectures to optimize gas fees.

Summarizing the activities:

1.- Generate and deploy the MockPriceFeed01 Smart Contract

```
llabori@Xubuntu64Bits-virtual-machine:~/BlockChains/AlchemyUniversity/
5-APIsSmartContractsChainlink$ npx hardhat run --network goerli scripts/deploy-mock01.js

Compiled 31 Solidity files successfully
MockPriceFeed01 deployed to: 0x19bE1625bA1a2f1e3e191C52a6283F4AB2F9f9Dc (NOTE = You contract address must be diferent to this)
```

2.- Generate the only one file with all source code's (The Smart Contract principal + library imported) using the follow instruction:

```
llabori@Xubuntu64Bits-virtual-machine:~/BlockChains/AlchemyUniversity/5-APIsSmartContractsChainlink$ npx hardhat flat contracts/MockPriceFeed01.sol > contracts/MockPriceFeed01_flat.sol
```

We must to get a new file in the contracts folder (MockPriceFeed01.sol)

3.- Verify and publish the MockPriceFeed Smart Contract Code using in the terminal the follow instruction:

```
llabori@Xubuntu64Bits-virtual-machine:~/BlockChains/AlchemyUniversity/5-APIsSmartContractsChainlink$ npx
hardhat verify --contract contracts/MockPriceFeed01_flat.sol:MockPriceFeed01 --constructor-args argumentsMock.js --network goerli 0x19bE1625bA1a2f1e3e191C52a6283F4AB2F9f9Dc (NOTE = You contract address must be diferent to this)
```

We must see:

```
llabori@Xubuntu64Bits-virtual-machine:~/BlockChains/AlchemyUniversity/5-APIsSmartContractsChainlink$ npx
hardhat verify --contract contracts/MockPriceFeed01_flat.sol:MockPriceFeed01 --constructor-args argumentsMock.js --network goerli 0x19bE1625bA1a2f1e3e191C52a6283F4AB2F9f9Dc
Nothing to compile
Successfully submitted source code for contract
contracts/MockPriceFeed01_flat.sol:MockPriceFeed01 at 0x19bE1625bA1a2f1e3e191C52a6283F4AB2F9f9Dc
for verification on the block explorer. Waiting for verification result...

Successfully verified contract MockPriceFeed01 on Etherscan.
https://goerli.etherscan.io/address/0x19bE1625bA1a2f1e3e191C52a6283F4AB2F9f9Dc#code
```

![Alt text](https://www.github.com/assets.digitalocean.com/articles/alligator/boo.svg "a title")

4.- Deploy the VegetationCitiesUpd Smart token contract (Remember to update the compiler version). For
the constructor arguments, you can pass in 10 seconds for the interval and the Mock Price Feed’s address 
as the second argument.

```
llabori@Xubuntu64Bits-virtual-machine:~/BlockChains/AlchemyUniversity/5-APIsSmartContractsChainlink$ npx hardhat run --network goerli scripts/deployUpd.js
Warning: Unnamed return variable can remain unassigned. Add an explicit return with value to all non-reverting code paths or name the variable.
   --> contracts/VegetationCitiesUpd.sol:110:109:
    |
110 |     function checkUpkeep(bytes calldata /* checkData */) external view override returns (bool upkeepNeeded, bytes memory /*performData*/) {
    |                                                                                                             ^^^^^^^^^^^^


Compiled 32 Solidity files successfully
VegetationCitiesUpd deployed to: 0x42E7121856440E2886b5914Ae10e2391569F1f79 (NOTE = You
contract address must be diferent to this)
```

5.- Generate the only one file with all source code's (The Smart Contract principal + library
imported) using the follow instruction:

```
llabori@Xubuntu64Bits-virtual-machine:~/BlockChains/AlchemyUniversity/
5-APIsSmartContractsChainlink$ npx hardhat flat contracts/VegetationCitiesUpd.sol > contracts/
VegetationCitiesUpd_flat.sol
```

We must to get a new file in the contracts folder (VegetationCitiesUpd_flat.sol)

6.- Verify and publish the VegetationCitiesUpd.sol Smart Contract Code using in the terminal the
follow instruction:

```
llabori@Xubuntu64Bits-virtual-machine:~/BlockChains/AlchemyUniversity/
5-APIsSmartContractsChainlink$ npx hardhat verify --contract contracts/VegetationCitiesUpd_flat.
sol:VegetationCitiesUpd --constructor-args argumentsVeget.js --network goerli
0x42E7121856440E2886b5914Ae10e2391569F1f79 (NOTE = You contract address must be diferent to
this)
```

We must see:

```
llabori@Xubuntu64Bits-virtual-machine:~/BlockChains/AlchemyUniversity/
5-APIsSmartContractsChainlink$ npx hardhat verify --contract contracts/VegetationCitiesUpd_flat.
sol:VegetationCitiesUpd --constructor-args argumentsVeget.js --network goerli
0x42E7121856440E2886b5914Ae10e2391569F1f79 (NOTE = You contract address must be diferent to
this)
Warning: Unnamed return variable can remain unassigned. Add an explicit return with value to
all non-reverting code paths or name the variable.
    --> contracts/VegetationCitiesUpd_flat.sol:3620:109:
     |
3620 |     function checkUpkeep(bytes calldata /* checkData */) external view override returns
(bool upkeepNeeded, bytes memory /*performData*/) {
     |                                                                                                             ^^^^^^^^^^^^


Compiled 1 Solidity file successfully
Warning: Unnamed return variable can remain unassigned. Add an explicit return with value to
all non-reverting code paths or name the variable.
    --> contracts/VegetationCitiesUpd_flat.sol:3620:109:
     |
3620 |     function checkUpkeep(bytes calldata /* checkData */) external view override returns (bool upkeepNeeded, bytes memory /*performData*/) {
     |                                                                                                             ^^^^^^^^^^^^


Successfully submitted source code for contract
contracts/VegetationCitiesUpd_flat.sol:VegetationCitiesUpd at
0x42E7121856440E2886b5914Ae10e2391569F1f79 (NOTE = You contract address must be diferent to
this) for verification on the block explorer. Waiting for verification result...

Successfully verified contract VegetationCitiesUpd on Etherscan.
https://goerli.etherscan.io/address/0x42E7121856440E2886b5914Ae10e2391569F1f79#code
```

![Alt text](https://www.github.com/assets.digitalocean.com/articles/alligator/boo.svg "a title")

7.- Mint a token or two: Mint a token or two and check their tokenURIs by clicking on tokenURI after passing 0, 1, or whatever the minted token ID you have is.

The token URI should all default to the vegetation01.json

![Alt text](https://www.github.com/assets.digitalocean.com/articles/alligator/boo.svg "a title")

![Alt text](https://www.github.com/assets.digitalocean.com/articles/alligator/boo.svg "a title")

8- Check the NFT contract's constructor: Check that the NFT contract’s constructor is called
getLatestPrice() and that in turn updates the currentPrice state variable. Do this by clicking on
the currentPrice button - the result should match the price you set in your Mock Price Feed.

9.- Pass in an empty array

Click on checkUpkeep and pass in an empty array ([]) as the argument. It should return a boolean of
true because we passed in 10 seconds as the interval duration and 10 seconds would have passed from
when you deployed Bull&Bear. The reference repo includes a setter function so you can update the
interval field for convenience.

![Alt text](https://www.github.com/assets.digitalocean.com/articles/alligator/boo.svg "a title")

10.- Ensure the Mock Price Feed is updated: Make sure that your Mock Price Feed is updated to return a
price that is different from what you currently have stored in your NFT Smart Contract’s
currentPrice field.

If you update the Mock Contract with a lower number, for example, you would expect that your NFT Smart
Contract would switch the NFTs to show a “bear” token URI.

11.- Simulate your contract being called

Click on performUpkeep after passing it an empty array. This is how you simulate your contract being
called by the Chainlink Keepers Network on Goerli. Don’t forget, you get to deploy to Goerli and
register your upkeep and connect to Goerli Price feeds as part of your assignment.

Since right now we are on the Remix in-browser network we need to simulate the automation flow by
calling performUpkeep ourselves.

![Alt text](https://www.github.com/assets.digitalocean.com/articles/alligator/boo.svg "a title")

12.- Check the latest price and update all token URIs

performUpkeep should check the latest price and update all token URIs.

    📘

    This is instantaneous in the Remix browser. On Goerli this can take some time.

You don’t need to sign any transaction in MetaMask when doing it locally, but when you connect to
Goerli you will have MetaMask ask you to sign transactions for each step.

13.- Refresh the currentPrice and check the tokenURI: If you click currentPrice you should see the
price based on the updated Mock Price Feed.

Then click tokenURI again, and you should see that your token URI has changed. If the price dropped
below the previous level it would be switched to a Cities. If the last token URI was a Cities and the
price increased, it should switch to a Vegetation token URI.

## Challenger 🛠️

This Challenger uses a new tool: the Chainlink Verifiable Random Function.

This tool provides cryptographically provable randomness and is widely used in gaming and other
applications where provable and tamper-resistant randomness is essential to fair outcomes.

Right now, we have hard coded which token URI shows up - the first URI (index 0) in the array. We need
to make it a random index number so a random NFT image shows up as the token URI.
Here are the steps:

1. Review a Chainlink VRF example

Look at the super brief example usage of Chainlink VRF - you have to implement only two functions to
get cryptographically provable randomness inside the NFT Smart Contract.

2. Update your NFT smart contract to use two VRF functions

Update your NFT smart contract to use requestRandomWords and fulfillRandomWords

3. Use the VRF mock in the randomness branch

Use the VRF mock provided in the randomness branch of the reference repo, and make sure you carefully
read the commented out instructions in the VRF mock so you know exactly how to use it.

4. Deploy your Dynamic NFT on Goerli

Lastly, once you’ve played around with the NFT smart contract and got it to change the tokenURI
dynamically a few times in Remix, connect Metamask and Remix to Rinkeby and deploy the NFT.

    📘

    When you deploy the NFT to Rinkeby, you can still use the mocks, but you need to deploy them too and in the right order.

Complete the following in the right order:

1. Connect your Metamask to Goerli

2. Acquire test LINK and test ETH from the Chainlink Faucet \*\*

If you’re planning to deploy the mock price feed aggregator and update it to the Chainlink Goerli price
feed later, deploy the mock now. Likewise, if you intend to test on Rinkeby using the mock VRF
Coordinator, you must deploy it on Goerli.

3. Deploy the NFT smart contract to Goerli

Make sure you pass in the right constructor parameters.

If you’re using the mocks, make sure they’re deployed first so you can pass their Rinkeby addresses to the
NFT contract’s constructor.

If you’re using a Chainlink live price feed, then its address must be as per the reference repo or
whatever Rinkeby price feed address you choose from here.

Since you can connect your Remix “environment” to the deployed NFT contract on Rinkeby, and call the NFT contract’s performUpkeep from Remix, you can keep the interval short for the first test run.

    📘

    Remember to increase the interval by calling setInterval otherwise the Keepers network will run your performUpkeep far more often than the Price Feed will show new data.

You can also change your price feed address by calling setPriceFeed and passing in the address you want it to point to.

    📘

    If performUpkeep finds that there is no change in price, the token URIs will not update!.

We must see:

```
llabori@Xubuntu64Bits-virtual-machine:~/BlockChains/AlchemyUniversity/5-APIsSmartContractsChainlink$ npx hardhat run --network goerli scripts/deployUpdf.js
Warning: Unnamed return variable can remain unassigned. Add an explicit return with value to all non-reverting code paths or name the variable.
   --> contracts/VegetationCitiesUpdf.sol:139:109:
    |
139 |     function checkUpkeep(bytes calldata /* checkData */) external view override returns (bool upkeepNeeded, bytes memory /*performData*/) {
    |                                                                                                             ^^^^^^^^^^^^


Compiled 1 Solidity file successfully
VegetationCitiesUpdf deployed to: 0xADA0d5670004E808206595b9AA7Bf920c3679Ea8 (NOTE = You contract address
must be diferent to this)
```

Generate the Upkeep and VRF Suscription in the interface Web of ChainLink neetwork:

![Alt text](https://www.github.com/assets.digitalocean.com/articles/alligator/boo.svg "a title")
![Alt text](https://www.github.com/assets.digitalocean.com/articles/alligator/boo.svg "a title")


Generate the only one file with all source code's (The Smart Contract principal + library
imported) using the follow instruction:

```
llabori@Xubuntu64Bits-virtual-machine:~/BlockChains/AlchemyUniversity/
5-APIsSmartContractsChainlink$ npx hardhat flat contracts/VegetationCitiesUpdf.sol > contracts/
VegetationCitiesUpdf_flat.sol

```

We must see a new file on the folder contracts (VegetationCitiesUpdf_flat.sol)

Now verify and publish the VegetationCitiesUpfs.sol Smart Contract using:

```
llabori@Xubuntu64Bits-virtual-machine:~/BlockChains/AlchemyUniversity/
5-APIsSmartContractsChainlink$ npx hardhat verify --contract contracts/VegetationCitiesUpdf_flat.
sol:VegetationCitiesUpdf --constructor-args argumentsVeget01.js --network goerli
0xADA0d5670004E808206595b9AA7Bf920c3679Ea8 (NOTE = You contract address must be diferent to
this)
```

Then we should see something similar to:

```
llabori@Xubuntu64Bits-virtual-machine:~/BlockChains/AlchemyUniversity/5-APIsSmartContractsChainlink$ npx hardhat verify --contract contracts/VegetationCitiesUpdf_flat.sol:VegetationCitiesUpdf --constructor-args argumentsVeget01.js --network goerli 0xADA0d5670004E808206595b9AA7Bf920c3679Ea8
Warning: Unnamed return variable can remain unassigned. Add an explicit return with value to all non-reverting code paths or name the variable.
    --> contracts/VegetationCitiesUpdf_flat.sol:3917:109:
     |
3917 |     function checkUpkeep(bytes calldata /* checkData */) external view override returns (bool upkeepNeeded, bytes memory /*performData*/) {
     |                                                                                                             ^^^^^^^^^^^^


Compiled 1 Solidity file successfully
Warning: Unnamed return variable can remain unassigned. Add an explicit return with value to all non-reverting code paths or name the variable.
    --> contracts/VegetationCitiesUpdf_flat.sol:3917:109:
     |
3917 |     function checkUpkeep(bytes calldata /* checkData */) external view override returns (bool upkeepNeeded, bytes memory /*performData*/) {
     |                                                                                                             ^^^^^^^^^^^^


Successfully submitted source code for contract
contracts/VegetationCitiesUpdf_flat.sol:VegetationCitiesUpdf at 0xADA0d5670004E808206595b9AA7Bf920c3679Ea8
for verification on the block explorer. Waiting for verification result...

Successfully verified contract VegetationCitiesUpdf on Etherscan.
https://goerli.etherscan.io/address/0xADA0d5670004E808206595b9AA7Bf920c3679Ea8#code
```

![Alt text](https://www.github.com/assets.digitalocean.com/articles/alligator/boo.svg "a title")


4. Mint your first token, and check its URI via Web Interface in https://goerli.etherscan.io/

![Alt text](https://www.github.com/assets.digitalocean.com/articles/alligator/boo.svg "a title")

It should be the vegetation01.json. Check on OpenSea if you like!

5. Play around with the mock values

If you’re using the two mocks, play around with the values and see the changes to the NFTs by calling 
tokenURI.

6. Switch to the live Chainlink contracts on Goerli

When you’re ready to switch to the live Chainlink contracts on Rinkeby, update the price feed’s address 
and the vrfCoordinator in the NFT contract by calling their setter functions.

6. Register your NFT smart contract

Next, register your NFT smart contract that is deployed to Goerli as a new “upkeep” in the Chainlink 
Keepers Registry

7. Create and fund a VRF subscription\*\*.

If you’re using the live Goerli Chainlink VRF make sure you call setVrfCoordinator() so you’re no longer 
using your VRF Mock on Goerli.

If you’ve not implemented it, that’s part of your learning, and you can check the reference repo.

8. Check OpenSea in an hour or two

Depending on how often the prices change (and if you want to immediately, then keep using the mocks on 
Goerli).

    📘

    OpenSea caches metadata and it may not show for a while even though you can call tokenURI and see the updated metadata.

    You can try and force an update on OpenSea with the force_update param but it may not update the images in time. The name of the NFT should be updated at the least

Now, let's add some fun challenges for you to try on your own before you submit your project:

    Add an icon next to the NFT addresses to make it easy for people viewing your site to copy the contract
    address.
    Add a pagination system to view more than 100 NFTs, by using the pageKey parameter from the getNFTs
    endpoint.

And make sure to share your reflections on this project to earn your Proof of Knowledge (PoK) token:
https://university.alchemy.com/discord

## Built with 🛠️

_Tools we used to create the project and which we used to develop the Challenge_

- [Visual Studio Code](https://code.visualstudio.com/) - The IDE
- [Alchemy](https://dashboard.alchemy.com) - Interface/API to the Goerli Tesnet Network
- [Xubuntu](https://xubuntu.org/) - Operating system based on Ubuntu distribution.
- [Opensea](https://testnets.opensea.io) - Web system used to verify/visualizate our NFT
- [Solidity](https://soliditylang.org) Object-oriented programming language for implementing smart
  contracts on various blockchain platforms
- [Hardhat](https://hardhat.org) - Environment developers use to test, compile, deploy and debug dApps
  based on the Ethereum blockchain
- [GitHub](https://github.com/) - Internet hosting service for software development and version
  control using Git.
- [Goerli Faucet](https://goerlifaucet.com/) - Faucet that is used to obtain ETH and use them to deploy 
  the Smart Contracts as well as to interact with them.
- [ChainLink Faucet](https://faucets.chain.link/) - Faucet used to obtain LINK which are used in the 
  interaction with the Automation system as well as with the Random Number Verifier in the ChainLink 
  Network.
- [Ether Scan](https://etherscan.io/myaccount) - To generate the API's Keys for interact with Goerli
  Tesnet
- [Automation ChainLink](https://automation.chain.link/goerli/) - To generate the Automation Upkeep    
  association to Smart Contract deployed in Goerli Tesnet.
- [VRF ChainLink](https://vrf.chain.link/goerli) - To generate the VRF association pointing to the smart 
  contract for Random Number Verification in Goerli Tesnet.
- [GitHub ChainLink repo](https://github.com/zeuslawyer/chainlink-dynamic-nft-alchemy) - GitHub Repo with 
  the principal code used to development all the systems.
- [MetaMask](https://metamask.io) - MetaMask is a software cryptocurrency wallet used to interact with
  the Ethereum blockchain.
- [UpScaler](https://imageupscaler.com/ai-image-generator/) - Web system used for the generation of the 
  six (6) images used that were published in IPFS. This system uses Artificial Intelligence to generate 
  the images based on texts referred to as Inputs.

## Contributing 🖇️

Please read the [CONTRIBUTING.md](https://gist.github.com/llabori-venehsoftw/xxxxxx) for details of our 
code of conduct, and the process for submitting pull requests to us.

## Wiki 📖

N/A

## Versioning 📌

We use [GitHub] for versioning all the files used (https://github.com/tu/proyecto/tags).

## Autores ✒️

_People who collaborated with the development of the challenge_

- **VeneHsoftw** - _Initial Work_ - [venehsoftw](https://github.com/venehsoftw)
- **Luis Labori** - _Initial Work_, _Documentationn_ - [llabori-venehsoftw](https://github.com/
  llabori-venehsoftw)

## License 📄

This project is licensed under the License (MIT) - see the file [LICENSE.md](LICENSE.md) for
details.

## Gratitude 🎁

- If you found the information reflected in this Repo to be of great importance, please extend your
  collaboration by clicking on the star button on the upper right margin. 📢
- If it is within your means, you may extend your donation using the following address:
  `0xAeC4F555DbdE299ee034Ca6F42B83Baf8eFA6f0D`

---

⌨️ con ❤️ por [Venehsoftw](https://github.com/llabori-venehsoftw) 😊

```

```
