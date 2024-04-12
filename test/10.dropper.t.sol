// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.13;

import "forge-std/Test.sol";
import {dropper as Challenge} from "../src/10.dropper/dropper.sol";

contract DropperTest is Test {
    Challenge challenge_;

    function setUp() public {
        challenge_ = new Challenge();

        challenge_.deposit{value: 500 ether}();

        challenge = address(challenge_);
    }
}
