// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Royalty.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

/**
 * @title OGApeNFT
 * @author @ericgr222
 * @dev This is an ERC721 Non-Fungible Token (NFT) contract for the OG Apes collection from
 * ApeDAO. It includes functionality for minting new NFTs, transferring ownership, and setting and
 * retrieving a URI for each NFT. It also includes the ERC721Royalty extension, which allows the
 * contract owner to set a royalty percentage that will be paid out to them each time an NFT is
 * transferred. Inherits the OpenZeppelin ERC721, ERC721Enumerable, ERC721URIStorage, and ERC721Royalty
 * implementation.
 */
contract BaseNFT is
    ERC721,
    ERC721Enumerable,
    ERC721URIStorage,
    ERC721Royalty,
    Ownable
{
    using Counters for Counters.Counter;

    /**
     * @dev A counter for generating unique token IDs.
     */
    Counters.Counter private _tokenIdCounter;

    /**
     * @dev The maximum number of NFTs that can be minted for this collection.
     */
    uint256 internal constant maxSupply = 1074;

    /**
     * @dev Constructor function that initializes the contract as an ERC721 token with the name "OG
     * Ape" and the symbol "OGAPE". It also increments the token ID counter and sets the default
     * royalty percentage to 1000 (10%).
     */
    constructor(string memory _name, string memory _symbol) ERC721(_name, _symbol) {
        _tokenIdCounter.increment();
        _setDefaultRoyalty(msg.sender, 1000);
    }

    /**
     * @dev Internal function that returns the base URI for NFTs in this collection.
     */
    function _baseURI() internal pure override returns (string memory) {
        return "ipfs://Qmcc9ykHbPTJBh3rQLK9Lm3d8Vx7obnoedAG3TmV9rMXTx/";
    }

    /**
     * @dev Function for safely minting a new NFT. This function can only be called by the contract
     * owner and it checks that the maximum supply of NFTs has not been reached before minting a new
     * one.
     * @param to The address of the recipient of the new NFT.
     * @param uri The URI for the new NFT.
     */
    function safeMint(address to, string memory uri) public onlyOwner {
        require(totalSupply() < maxSupply);
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
    }

    // The following functions are overrides required by Solidity.

    /**
     * @dev This function is called before an NFT is transferred. It is an override of the
     * ERC721Enumerable and ERC721 contracts.
     * @param from The address of the current owner of the NFT.
     * @param to The address of the new owner of the NFT.
     * @param tokenId The ID of the NFT being transferred.
     * @param batchSize The number of tokens being transferred in this transaction
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
     * @dev This function burns (deletes) an NFT. It is an override of the ERC721, ERC721URIStorage,
     * and ERC721Royalty contracts.
     * @param tokenId The ID of the NFT to be burned.
     */
    function _burn(uint256 tokenId)
        internal
        override(ERC721, ERC721URIStorage, ERC721Royalty)
    {
        super._burn(tokenId);
    }

    /**
     * @dev This function returns the URI for an NFT. It is an override of the ERC721 and
     * ERC721URIStorage contracts.
     * @param tokenId The ID of the NFT.
     * @return The URI for the NFT.
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
     * @dev This function returns whether the contract supports a given interface. It is an override
     * of the ERC721, ERC721Enumerable, and ERC721Royalty contracts.
     * @param interfaceId The ID of the interface.
     * @return A boolean indicating whether the contract supports the interface.
     */
    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable, ERC721Royalty, ERC721URIStorage)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}