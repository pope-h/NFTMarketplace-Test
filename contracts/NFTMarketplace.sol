// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract NFTMarketplace is ERC721 {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;

    address payable public owner;
    mapping(uint256 => uint256) public tokenPrices;

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    constructor(string memory name, string memory symbol) ERC721(name, symbol) {
        owner = payable(msg.sender);
    }

    function mintNFT(address recipient, string memory tokenURI) external onlyOwner returns (uint256) {
        _tokenIdCounter.increment();
        uint256 newTokenId = _tokenIdCounter.current();
        _mint(recipient, newTokenId);
        _setTokenURI(newTokenId, tokenURI);
        return newTokenId;
    }

    function setTokenPrice(uint256 tokenId, uint256 price) external {
        require(ownerOf(tokenId) == msg.sender, "You are not the owner of this token");
        tokenPrices[tokenId] = price;
    }

    function buyNFT(uint256 tokenId) external payable {
        require(_exists(tokenId), "Token does not exist");
        require(tokenPrices[tokenId] > 0, "Token is not for sale");
        require(msg.value >= tokenPrices[tokenId], "Insufficient payment");

        address payable seller = payable(ownerOf(tokenId));
        _transfer(seller, msg.sender, tokenId);
        seller.transfer(msg.value);
        tokenPrices[tokenId] = 0; // remove the token from sale
    }

    function listNFTForSale(uint256 tokenId, uint256 price) external {
        require(ownerOf(tokenId) == msg.sender, "You are not the owner of this token");
        tokenPrices[tokenId] = price;
    }

    function removeNFTFromSale(uint256 tokenId) external {
        require(ownerOf(tokenId) == msg.sender, "You are not the owner of this token");
        tokenPrices[tokenId] = 0;
    }

    function withdraw() external onlyOwner {
        owner.transfer(address(this).balance);
    }
}