// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

// Chainlink Imports
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
// This import includes functions from both ./KeeperBase.sol and
// ./interfaces/KeeperCompatibleInterface.sol
// import "@chainlink/contracts/src/v0.8/KeeperCompatible.sol"; This import is deprecated
import "@chainlink/contracts/src/v0.8/AutomationBase.sol";       // These two lines replace 
import "@chainlink/contracts/src/v0.8/AutomationCompatible.sol"; // the deprecated import

// Dev imports. This only works on a local dev network
// and will not work on any test or main livenets.
import "hardhat/console.sol";

contract VegetationCitiesUpd is ERC721, ERC721Enumerable, ERC721URIStorage, AutomationCompatibleInterface, Ownable {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;
    AggregatorV3Interface public pricefeed;

    /**
    * Use an interval in seconds and a timestamp to slow execution of Upkeep
    */
    uint public /* immutable */ interval; 
    uint public lastTimeStamp;

    int256 public currentPrice;

    // IPFS URIs for the dynamic nft graphics/metadata.
    // NOTE: These connect to my IPFS Companion node.
    // You should upload the contents of the /ipfs folder to your own node for development.
    string[] vegetationUrisIpfs = [
        "https://ipfs.io/ipfs/QmbqiQuNFYuTX55UdSyCSzaPnPWGvduQnq2WbLwwhA9o49?filename=vegetation01.json",
        "https://ipfs.io/ipfs/QmQESBNenESMZ6i3BpYLnHigiRHHNh2mCg9hrHGE66EyZS?filename=vegetation02.json",
        "https://ipfs.io/ipfs/QmQh3tXJ1NF6gauVGxeW9pumtiBS4NfepBN8C1xVzWjRWx?filename=vegetation03.json"
    ];
    string[] citiesUrisIpfs = [
        "https://ipfs.io/ipfs/QmZM76tG6opdKPTXnUsmniATac2ti237WDLrJgdZfSRuw1?filename=cities01.json",
        "https://ipfs.io/ipfs/QmVnifCC387zLCafq5X4dKSWpPzGhmRTNU6AaUYUfp2GEQ?filename=cities02.json",
        "https://ipfs.io/ipfs/QmQeU4uypSGgop7V8x6Xt5vZsRSKGMft4Lu6kLWao89d6m?filename=cities03.json"
    ];

    event TokensUpdated(string marketTrend);

    // For testing with the mock on Goerli, pass in 10(seconds) for `updateInterval` and the address of my 
    // deployed  MockPriceFeed.sol contract (0xD753A1c190091368EaC67bbF3Ee5bAEd265aC420).
    /* Initializes contract with initial parameter */
    constructor(uint updateInterval, address _pricefeed) ERC721("Veget&Cities", "VCTK") {

        // Set the keeper update interval
        interval = updateInterval; 
        lastTimeStamp = block.timestamp;  //  seconds since unix epoch

        // set the price feed address to:
        // BTC/USD Price Feed Contract Address on Goerli: https://goerli.etherscan.io/address/0xA39434A63A52E749F02807ae27335515BA4b07F7
        // or the MockPriceFeed Contract
        pricefeed = AggregatorV3Interface(_pricefeed); // To pass in the mock

        // set the price for the chosen currency pair.
        currentPrice = getLatestPrice();

    }

    /**
     * mint
     *
     * To mint - of course
     *
     * @param to The address for owner the NFT
     */
    function safeMint(address to) public {
        // Current counter value will be the minted token's token ID.bytes memory
        uint256 tokenId = _tokenIdCounter.current();

        // Increment it so next time it's correct when we call .current()
        _tokenIdCounter.increment();

        // Mint the token
        _safeMint(to, tokenId);

        // Default to a bull NFT
        string memory defaultUri = vegetationUrisIpfs[0];
        _setTokenURI(tokenId, defaultUri);

        console.log(
            "DONE!!! minted token ",
            tokenId,
            " and assigned token url: ",
            defaultUri
        );
    }

    /**
     * checkUpkeep
     *
     * Runs off-chain at every block to determine if the performUpkeep function should be called on-chain.
     * To be execute from Chainlink Keepers Network
     *
     * 
     */
    function checkUpkeep(bytes calldata /* checkData */) external view override returns (bool upkeepNeeded, bytes memory /*performData*/) {
         upkeepNeeded = (block.timestamp - lastTimeStamp) > interval;

    }

    /**
     * performUpkeep
     *
     * Contains the logic that should be executed on-chain when checkUpkeep returns true.
     * To be execute from Chainlink Keepers Network
     *
     * 
     */
    function performUpkeep(bytes calldata /* performData */ ) external override {
        // We highly recommend revalidating the upkeep in the performUpkeep function
        if ((block.timestamp - lastTimeStamp) > interval ) {
            lastTimeStamp = block.timestamp;         
            int latestPrice =  getLatestPrice();
        
            if (latestPrice == currentPrice) {
                console.log("NO CHANGE -> returning!");
                return;
            }

            if (latestPrice < currentPrice) {
                // Cities
                console.log("ITS BEAR TIME");
                updateAllTokenUris("cities");

            } else {
                // Vegetations
                console.log("ITS BULL TIME");
                updateAllTokenUris("vegetations");
            }

            // update currentPrice
            currentPrice = latestPrice;
        } else {
            console.log(
                " INTERVAL NOT UP!"
            );
            return;
        }

       
    }

    // Helpers

    /**
     * getLatestPrice
     *
     * To be execute from Chainlink Keepers Network
     *
     * 
     */
    function getLatestPrice() public view returns (int256) {
         (
            /*uint80 roundID*/,
            int price,
            /*uint startedAt*/,
            /*uint timeStamp*/,
            /*uint80 answeredInRound*/
        ) = pricefeed.latestRoundData();

        return price; //  example price returned 3034715771688
    }

    /**
     * updateAllTokenUris
     *
     * To update the Uris for the Metadata
     *
     * @param trend The memory section with informacion about link to Uris IPFS Metadata
     */
    function updateAllTokenUris(string memory trend) internal {
        if (compareStrings("vegetation", trend)) {
            console.log(" UPDATING TOKEN URIS WITH ", "vegetation", trend);
            for (uint i = 0; i < _tokenIdCounter.current() ; i++) {
                _setTokenURI(i, vegetationUrisIpfs[0]);
            } 
            
        } else {     
            console.log(" UPDATING TOKEN URIS WITH ", "cities", trend);

            for (uint i = 0; i < _tokenIdCounter.current() ; i++) {
                _setTokenURI(i, citiesUrisIpfs[0]);
            }  
        }   
        emit TokensUpdated(trend);
    }

    /**
     * setPriceFeed
     *
     * To update the addres for the Smart Contract for pricefeed
     *
     * @param newFeed The address for the Smart Contract Pricefeed
     */
    function setPriceFeed(address newFeed) public onlyOwner {
        pricefeed = AggregatorV3Interface(newFeed);
    }

    /**
     * setInterval
     *
     * To update the interval for to get de value pricefeed
     *
     * @param newInterval The value of new interval
     */
    function setInterval(uint256 newInterval) public onlyOwner {
        interval = newInterval;
    }
    
    /**
     * compareStrings
     *
     * To compare two memory strings
     *
     * @param a The first string to compare
     * @param b The second string to compare
     */
    function compareStrings(string memory a, string memory b) internal pure returns (bool) {
        return (keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b))));
    }

    // The following functions are overrides required by Solidity.

    /**
     * _beforeTokenTransfer
     *
     * To action before transfer tokenId
     *
     * @param from The address from
     * @param to The address To
     * @param tokenId The NFT Id
     * @param batchSize The batchSize amount
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId,
        uint256 batchSize
    ) internal override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

    /**
     * _burn
     *
     * To Burn the TokenURI of an NFT
     *
     * @param tokenId The NFT Id
     */
    function _burn(uint256 tokenId)
        internal
        override(ERC721, ERC721URIStorage)
    {
        super._burn(tokenId);
    }

    /**
     * TokenURI
     *
     * To get the TokenURI of an NFT
     *
     * @param tokenId The NFT Id
     */
    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    /**
     * supportsInterface
     *
     * To get the TokenURI of an NFT
     *
     * @param interfaceId The Interface Id
     */
    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
