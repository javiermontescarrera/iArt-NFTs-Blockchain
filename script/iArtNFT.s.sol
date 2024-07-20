// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {iArtNFT} from "../src/iArtNFT.sol";

contract iArtNFTTokenDeploy is Script {
    function run() public {
        vm.startBroadcast();

        iArtNFT token = new iArtNFT();
        console.log("token contract deployed at: ", address(token));

        vm.stopBroadcast();
        
    }
}
