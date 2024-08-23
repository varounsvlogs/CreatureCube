// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {CubeDN404} from "../src/example/CubeDN404.sol";
import "forge-std/Script.sol";

contract CubeDN404Script is Script {

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        // CubeDN404 constructor args -- initialTokenSupply, initialSupplyOwner
        // CHANGE THESE VALUES TO SUIT YOUR NEEDS
        uint96 initialSupply = 0; // Example initial supply
        address owner = msg.sender; // Replace with your desired owner address

        new CubeDN404(initialSupply, owner);

        vm.stopBroadcast();
    }
}
