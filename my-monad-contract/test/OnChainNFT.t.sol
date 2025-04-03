// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../src/OnChainNFT.sol";

contract OnChainNFTTest is Test {
    OnChainNFT nft;

    function setUp() public {
        nft = new OnChainNFT();
    }

    function testMintNFT() public {
        nft.mintNFT("Test Metadata");
        assertEq(nft.ownerOf(0), address(this));
    }
}
