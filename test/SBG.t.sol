// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import {SBG as Challenge} from "../src/6.Skill Based Game/SBG.sol";

contract SBGTest is Test {
    address private immutable BLACKJACK = 0xA65D59708838581520511d98fB8b5d1F76A96cad;
    Challenge public challenge;
    address public Attacker;

    function setUp() public {
        uint256 AttackerPK = 0x5443;
        Attacker = vm.addr(AttackerPK);

        /////////////////////////////
        ///      Select Fork      //
        /////////////////////////////

        string memory key = "MAINNET_RPC_URL";
        string memory MAINNET_RPC_URL = vm.envString(key);
        uint256 forkId = vm.createFork(MAINNET_RPC_URL, 16_543_210);
        vm.selectFork(forkId);

        payable(BLACKJACK).transfer(50 ether);
        challenge = new Challenge(BLACKJACK);
    }

    function testIsSolved() public {
        console.log("BLACKJACK balance: %s", BLACKJACK.balance);
        console.log("Attacker balance: %s", Attacker.balance);
    }
}
