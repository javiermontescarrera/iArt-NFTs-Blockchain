// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import { iArtNFT } from "../src/iArtNFT.sol";

contract iArtNFTTest is Test {
    iArtNFT public token;
    address owner = address(0x0);

    struct nftData {
        uint256 tokenId;
        uint256 creationDate;
        string paintingName;
        string paintingDescription;
        string nftImageIpfsHash;
    }

    function setUp() public {
        token = new iArtNFT();
        token.setExternalUrl("https://iArt-NFTs-Blockchain.test/");
    }

    function testSuccess_GetFirstTimePrice() public view {
        assertEq(token.firstTimePrice(), 1_500_000 gwei);
    }

    function testSuccess_SetFirstTimePrice() public {
        token.setFirstTimePrice(7_000_000 gwei);
        assertEq(token.firstTimePrice(), 7_000_000 gwei);
    }

    function testSuccess_getOwnedNFTs() public view {
        address user1 = address(0x1234567);

        uint256 ownedNFTs = token.getOwnedNFTs(user1).length;
        console.log("ownedNFTs: ", ownedNFTs);
        assertEq(ownedNFTs, 0);
    }

    function testSuccess_mintToPayer() public {
        // vm.expectEmit();

        address user1 = address(0x1234567);
        vm.deal(user1, 1_500_000 gwei);

        uint256 amount = 1_500_000 gwei;
        // console.log(amount);

        // Start simulating user1 sending the transaction
        vm.startPrank(user1);

        // Call the mintToPayer function from user1
        token.mintToPayer{value: amount}('Test name', 'Test description', 'ipfs://test_nftImageIpfsHash');

        vm.stopPrank();
    }

}
