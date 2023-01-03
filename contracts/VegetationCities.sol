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
import "@chainlink/contracts/src/v0.8/KeeperCompatible.sol";

// Dev imports. This only works on a local dev network
// and will not work on any test or main livenets.
import "hardhat/console.sol";

contract VegetationCities is ERC721, ERC721Enumerable, ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;

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

    /* Initializes contract with initial parameter */
    constructor() ERC721("Veget&Cities", "VCTK") {}

    /**
     * mint
     *
     * To mint - of course
     *
     * @param to The address for owner the NFT
     */
    function safeMint(address to) public {
        // Current counter value will be the minted token's token ID.
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

    // The following functions are overrides required by Solidity.

    /**
     * _burn
     *
     * To Burn the TokenURI of an NFT
     *
     * @param from The address from
     * @param to The address To
     * @param tokenId The NFT Id
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
