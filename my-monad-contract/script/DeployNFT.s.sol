// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import "../src/OnChainNFT.sol";

contract DeployNFT is Script {
    function run() external {
        vm.startBroadcast();
        new OnChainNFT();
        vm.stopBroadcast();
    }
}

