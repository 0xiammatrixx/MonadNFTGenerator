// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract OnChainNFT is ERC721URIStorage, Ownable {
    uint256 private _tokenIdCounter;
    mapping(uint256 => uint256) public levels;
    mapping(uint256 => bool) public forSale;
    mapping(uint256 => uint256) public prices;
    mapping(uint256 => address) public rentedTo;
    mapping(uint256 => uint256) public stakingStartTime;
    mapping(uint256 => bool) public isStaked;
    
    constructor() ERC721("OnChainNFT", "OCNFT") Ownable(msg.sender) {}
    
    function mintNFT() public onlyOwner {
        uint256 tokenId = _tokenIdCounter++;
        _safeMint(msg.sender, tokenId);
        _setTokenURI(tokenId, generateMetadata(tokenId));
        levels[tokenId] = 1;
    }
    
    function generateMetadata(uint256 tokenId) internal view returns (string memory) {
        string memory svg = encodeSVG(tokenId);
        return string(abi.encodePacked(
            '{"name": "OnChainNFT #', toString(tokenId), '", ',
            '"description": "A fully on-chain NFT with evolving traits.", ',
            '"attributes": [{"trait_type": "Level", "value": ', toString(levels[tokenId]), '}], ',
            '"image": "data:image/svg+xml;base64,', svg, '"}'));
    }
    
    function encodeSVG(uint256 tokenId) internal view returns (string memory) {
        return Base64.encode(bytes(string(abi.encodePacked(
            '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 200 200">',
            '<rect width="100%" height="100%" fill="hsl(', toString((tokenId * 45) % 360), ', 80%, 70%)"/>',
            '<circle cx="100" cy="100" r="', toString(30 + (levels[tokenId] * 5)), '" fill="white"/>',
            '<text x="50" y="150" font-size="14" fill="black">#', toString(tokenId), '</text>',
            '</svg>'
        ))));
    }
    
    function setForSale(uint256 tokenId, uint256 price) public {
        require(ownerOf(tokenId) == msg.sender, "Not the owner");
        forSale[tokenId] = true;
        prices[tokenId] = price;
    }
    
    function buyNFT(uint256 tokenId) public payable {
        require(forSale[tokenId], "Not for sale");
        require(msg.value >= prices[tokenId], "Insufficient funds");
        address seller = ownerOf(tokenId);
        _transfer(seller, msg.sender, tokenId);
        forSale[tokenId] = false;
        payable(seller).transfer(msg.value);
    }
    
    function rentNFT(uint256 tokenId, address renter) public {
        require(ownerOf(tokenId) == msg.sender, "Not the owner");
        rentedTo[tokenId] = renter;
    }
    
    function levelUp(uint256 tokenId) public {
        require(ownerOf(tokenId) == msg.sender, "Not the owner");
        levels[tokenId] += 1;
        _setTokenURI(tokenId, generateMetadata(tokenId));
    }

    function stakeNFT(uint256 tokenId) public {
        require(ownerOf(tokenId) == msg.sender, "You must own the NFT.");
        require(!isStaked[tokenId], "NFT is already staked.");

        stakingStartTime[tokenId] = block.timestamp;
        isStaked[tokenId] = true;

    // Transfer NFT to staking contract (can be adjusted for your use case)
        _transfer(msg.sender, address(this), tokenId);
    }


    function unstakeNFT(uint256 tokenId) public {
        require(isStaked[tokenId], "NFT is not staked.");
        require(ownerOf(tokenId) == msg.sender, "You must own the NFT.");

        uint256 stakingDuration = block.timestamp - stakingStartTime[tokenId];

    
        uint256 rewards = stakingDuration * 0.01 ether;  // Example: 0.01 ETH per second staked

    // Transfer rewards (you can replace this with actual token transfer logic)
        payable(msg.sender).transfer(rewards);

        _transfer(address(this), msg.sender, tokenId);

        isStaked[tokenId] = false;
    }
    
    function toString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0";
        }
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

library Base64 {
    function encode(bytes memory data) internal pure returns (string memory) {
        string memory TABLE = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
        uint256 encodedLen = 4 * ((data.length + 2) / 3);
        bytes memory result = new bytes(encodedLen + 32);
        assembly {
            let tablePtr := add(TABLE, 1)
            let resultPtr := add(result, 32)
            for {
                let i := 0
            } lt(i, mload(data)) {
            } {
                i := add(i, 3)
                let input := and(mload(add(data, i)), 0xffffff)
                let out := add(add(shl(18, and(shr(18, input), 0x3F)), shl(12, and(shr(12, input), 0x3F))), add(shl(6, and(shr(6, input), 0x3F)), and(input, 0x3F)))
                mstore(resultPtr, shl(232, mload(add(tablePtr, and(shr(18, out), 0x3F)))))
                mstore(add(resultPtr, 1), shl(232, mload(add(tablePtr, and(shr(12, out), 0x3F)))))
                mstore(add(resultPtr, 2), shl(232, mload(add(tablePtr, and(shr(6, out), 0x3F)))))
                mstore(add(resultPtr, 3), shl(232, mload(add(tablePtr, and(out, 0x3F)))))
                resultPtr := add(resultPtr, 4)
            }
            mstore(result, encodedLen)
        }
        return string(result);
    }
}
