// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract DappSheriff is ERC721, ERC721URIStorage, Ownable {
    uint256 private _nextTokenId;
    uint256 public price = 0.001 ether;

    event PriceChanged(uint256 newPrice);

    constructor(address initialOwner) ERC721("DappSheriff", "DPS") Ownable(initialOwner) {}

    function mint(address to, string memory uri) external payable {
        require(msg.value == price, "Wrong ETH value");

        uint256 tokenId = _nextTokenId++;
        _mint(to, tokenId);
        _setTokenURI(tokenId, uri);
    }

    function tokenURI(uint256 tokenId) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId) public view override(ERC721, ERC721URIStorage) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    function setPrice(uint256 _price) external onlyOwner {
        price = _price;

        emit PriceChanged(_price);
    }

    function withdraw() external onlyOwner {
        (bool success,) = msg.sender.call{value: address(this).balance}("");
        require(success, "Withdrawal failed");
    }
}
