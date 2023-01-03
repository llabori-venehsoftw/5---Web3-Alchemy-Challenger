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
// For working with Chainlink Verifiable Random Function
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
//import "@chainlink/contracts/src/v0.8/ConfirmedOwner.sol";

// Dev imports. This only works on a local dev network
// and will not work on any test or main livenets.
import "hardhat/console.sol";

contract VegetationCitiesUpdf is ERC721, ERC721Enumerable, ERC721URIStorage, AutomationCompatibleInterface, Ownable, VRFConsumerBaseV2 {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;
    AggregatorV3Interface public pricefeed;

    /**
    * For use with VRF
    */
    VRFCoordinatorV2Interface public COORDINATOR;
    uint256[] public s_randomWords;
    uint256 public s_requestId;
    uint32 public callbackGasLimit = 500000; // set higher as fulfillRandomWords is doing a LOT of heavy lifting.
    uint64 public s_subscriptionId;
    bytes32 keyhash =  0x79d3d8832d904592c0bf9818b621522c988bb8b0c05cdc3b15aea1b6e8db0c15; // keyhash, see https://docs.chain.link/vrf/v2/subscription/supported-networks Goerli Testnet
    // The default is 3, but you can set this higher.
    uint16 requestConfirmations = 3;
    // For this example, retrieve 1 random values in one request.
    // Cannot exceed VRFCoordinatorV2.MAX_NUM_WORDS.
    uint32 numWords = 1;

    /**
    * Use an interval in seconds and a timestamp to slow execution of Upkeep
    */
    uint public /* immutable */ interval; 
    uint public lastTimeStamp;
    int256 public currentPrice;

    /**
    * For working with the two sequences of NFT'S
    */
    enum MarketTrend{VEGETATION, CITIES} // Create Enum
    MarketTrend public currentMarketTrend = MarketTrend.VEGETATION;

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

    // For testing with the mock on Goerli, pass in 10(seconds) for `updateInterval` and the address of our 
    // deployed MockPriceFeed01.sol contract (0x19bE1625bA1a2f1e3e191C52a6283F4AB2F9f9Dc) or
    // BTC/USD Price Feed Contract Address on Goerli: https://goerli.etherscan.io/address/0xA39434A63A52E749F02807ae27335515BA4b07F7
    // Setup VRF. Our Goerli Coordinator address: 0xXXXXXXXXXXXXXXXXXXXXXX or
    // Setup VRF. Goerli ChainLink VRF Coordinator address: 0x2Ca8E0C643bDe4C2E08ab1fA0da3401AdAD7734D
    /* Initializes contract with initial parameter */
    constructor(uint updateInterval, address _pricefeed, address _vrfCoordinator) ERC721("Veget&Cities", "VCTK") VRFConsumerBaseV2(_vrfCoordinator) {

        // Set the keeper update interval
        interval = updateInterval; 
        lastTimeStamp = block.timestamp;  //  seconds since unix epoch

        // set the price feed address to:
        // BTC/USD Price Feed Contract Address on Goerli: https://goerli.etherscan.io/address/0xA39434A63A52E749F02807ae27335515BA4b07F7
        // or the MockPriceFeed01 Contract
        pricefeed = AggregatorV3Interface(_pricefeed); // To pass in the mock

        // set the price for the chosen currency pair.
        currentPrice = getLatestPrice();

        // set the COORDINATOR.
        COORDINATOR = VRFCoordinatorV2Interface(_vrfCoordinator);
    }

    /**
     * safeMint
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
     * Modified to handle VRF.
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
                console.log("ITS CITIES TIME");
                currentMarketTrend = MarketTrend.CITIES;
                //updateAllTokenUris("cities");

            } else {
                // Vegetations
                console.log("ITS VEGETATIONS TIME");
                currentMarketTrend = MarketTrend.VEGETATION;
                //updateAllTokenUris("vegetations");
            }

            // Initiate the VRF calls to get a random number (word)
            // that will then be used to to choose one of the URIs 
            // that gets applied to all minted tokens.
            requestRandomnessForNFTUris();

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
     * requestRandomnessForNFTUris
     *
     * When checkUpkeep returns true, To be execute performUpkeep
     * Then to be execute this function for update the NFTUris
     * 
     */
    function requestRandomnessForNFTUris() internal {
        require(s_subscriptionId != 0, "Subscription ID not set"); 

        // Will revert if subscription is not set and funded.
        s_requestId = COORDINATOR.requestRandomWords(
            keyhash,
            s_subscriptionId,     // See https://vrf.chain.link/
            requestConfirmations, // Minimum confirmations before response
            callbackGasLimit,
            numWords // `numWords` : number of random values we want. Max number for rinkeby is 500 (https://docs.chain.link/docs/vrf-contracts/#rinkeby-testnet)
        );

        console.log("Request ID: ", s_requestId);

        // requestId looks like uint256: 80023009725525451140349768621743705773526822376835636211719588211198618496446
    }

    /**
     * fulfillRandomWords
     *
     * This is the callback that the VRF coordinator sends the
     * random values to.
     * 
     * 
     * @param randomWords The address for owner the NFT
     */
    function fulfillRandomWords(
        uint256, /* requestId */
        uint256[] memory randomWords
        ) internal override {
            s_randomWords = randomWords;
            // randomWords looks like this uint256: 68187645017388103597074813724954069904348581739269924188458647203960383435815
            console.log("...Fulfilling random Words");
            string[] memory urisForTrend = currentMarketTrend == MarketTrend.VEGETATION ? vegetationUrisIpfs : citiesUrisIpfs;
            uint256 idx = randomWords[0] % urisForTrend.length; // use modulo to choose a random index.
            for (uint i = 0; i < _tokenIdCounter.current() ; i++) {
                _setTokenURI(i, urisForTrend[idx]);
                }
            string memory trend = currentMarketTrend == MarketTrend.VEGETATION ? "bullish" : "bearish";
            emit TokensUpdated(trend);
            }

    /**
     * updateAllTokenUris
     *
     * To update the Uris for the Metadata
     *
     * @param trend The memory section with informacion about link to Uris IPFS Metadata
     */
    //function updateAllTokenUris(string memory trend) internal {
    //    if (compareStrings("vegetation", trend)) {
    //        console.log(" UPDATING TOKEN URIS WITH ", "vegetation", trend);
    //        for (uint i = 0; i < _tokenIdCounter.current() ; i++) {
    //            _setTokenURI(i, vegetationUrisIpfs[0]);
    //        } 
    //        
    //    } else {     
    //        console.log(" UPDATING TOKEN URIS WITH ", "cities", trend);
    //
    //        for (uint i = 0; i < _tokenIdCounter.current() ; i++) {
    //            _setTokenURI(i, citiesUrisIpfs[0]);
    //        }  
    //    }   
    //    emit TokensUpdated(trend);
    //}

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

    // For VRF Subscription Manager
    function setSubscriptionId(uint64 _id) public onlyOwner {
        s_subscriptionId = _id;
    }
        
    function setCallbackGasLimit(uint32 maxGas) public onlyOwner {
        callbackGasLimit = maxGas;
    }
    
    function setVrfCoodinator(address _address) public onlyOwner {
        COORDINATOR = VRFCoordinatorV2Interface(_address);
    }
    
    // Helpers

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
