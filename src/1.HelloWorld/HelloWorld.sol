// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract HelloWorld {
    //I do a little change here, but same result

    //address public immutable TARGET = 0x00000000219ab540356cBB839Cbe05303d7705Fa;

    uint256 public immutable STARTING_BALANCE;
    uint256 public ENDING_BALANCE;

    constructor() {
        STARTING_BALANCE = address(this).balance;
    }

    function isSolved() external returns (bool) {
        ENDING_BALANCE = address(this).balance;
        return ENDING_BALANCE > STARTING_BALANCE + 13.37 ether;
    }
}
