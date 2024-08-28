// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {CubetestToken} from "../src/example/CubetestToken.sol";
import "forge-std/Script.sol";

contract CubetestToken404Script is Script {
    uint256 private constant _WAD = 1000000000000000000;

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        // SimpleDN404 constructor args -- name, symbol, initialSupply, owner
        // CHANGE THESE VALUES TO SUIT YOUR NEEDS
        // string memory name = "DN404";
        // string memory symbol = "DN";
        // uint96 initialSupply = 1000;
        // address owner = address(this);

        new CubetestToken();
        vm.stopBroadcast();
    }
}
