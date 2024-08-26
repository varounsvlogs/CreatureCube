// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {CreatureCubeDN404} from "../src/example/CreatureCubeDN404v2.sol";
import "forge-std/Script.sol";

contract CreatureCubeDN404Script is Script {

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        // CreatureCubeDN404 constructor args -- initialTokenSupply, initialSupplyOwner
        // CHANGE THESE VALUES TO SUIT YOUR NEEDS
        //uint96 initialSupply = 0; // Initial supply is set to 0 at launch
        //address owner = msg.sender; // Replace with your desired owner address

        new CreatureCubeDN404();

        vm.stopBroadcast();
    }
}
