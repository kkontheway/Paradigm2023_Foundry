// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.13;

import "../../lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import "./SystemConfiguration.sol";

contract Stablecoin is ERC20("US Dollar Stablecoin", "USDS") {
    SystemConfiguration private immutable SYSTEM_CONFIGURATION;

    constructor(SystemConfiguration configuration) {
        SYSTEM_CONFIGURATION = configuration;
    }

    function mint(address to, uint256 amount) external {
        require(SYSTEM_CONFIGURATION.isAuthorized(msg.sender), "NOT_AUTHORIZED");

        _mint(to, amount);
    }

    function burn(address from, uint256 amount) external {
        require(SYSTEM_CONFIGURATION.isAuthorized(msg.sender), "NOT_AUTHORIZED");

        _burn(from, amount);
    }
}
