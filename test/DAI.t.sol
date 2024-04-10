// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

contract DAITest is Test {
    string public MAINNET_RPC_URL = "https://eth-mainnet.g.alchemy.com/v2/TfzGdaUaUjh1Yu1mPXyV0HxmlYzq2Nst";

    function setUp() public {}

    function testFork() public {
        uint256 forkId = vm.createFork(MAINNET_RPC_URL, 16_543_210);
        vm.selectFork(forkId);

        assertEq(block.number, 16_543_210);
    }
}
