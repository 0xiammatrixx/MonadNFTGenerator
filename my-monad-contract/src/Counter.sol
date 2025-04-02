// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract OnChainNFT is ERC721URIStorage, Ownable {
    uint256 private _nextTokenId;
    
    constructor() ERC721("OnChainNFT", "OCNFT") {}

    function mintNFT(string memory metadata) public onlyOwner {
        uint256 tokenId = _nextTokenId++;
        _safeMint(msg.sender, tokenId);
        _setTokenURI(tokenId, metadata);
    }

    function generateMetadata(uint256 tokenId) public pure returns (string memory) {
        return string(abi.encodePacked(
            '{"name": "On-Chain NFT #', toString(tokenId),
            '", "description": "Fully on-chain NFT", "image": "data:image/svg+xml;base64,',
            encodeSVG(tokenId), '"}'
        ));
    }

    function encodeSVG(uint256 tokenId) internal pure returns (string memory) {
        return "PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciPjx0ZXh0IHg9IjUwJSIgeT0iNTAlIiBmb250LXNpemU9IjIwIj5Pbi1DaGFpbiBORlQ8L3RleHQ+PC9zdmc+";
    }

    function toString(uint256 value) internal pure returns (string memory) {
        if (value == 0) return "0";
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }
}
