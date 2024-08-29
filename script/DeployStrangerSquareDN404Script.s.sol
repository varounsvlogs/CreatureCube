// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {StrangerSquareDN404} from "../src/example/StrangerSquareDN404.sol";
import "forge-std/Script.sol";

contract StrangerSquareDN404Script is Script {

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY_3");
        vm.startBroadcast(deployerPrivateKey);

        // CreatureCubeDN404 constructor args -- initialTokenSupply, initialSupplyOwner
        // CHANGE THESE VALUES TO SUIT YOUR NEEDS
        //uint96 initialSupply = 0; // Initial supply is set to 0 at launch
        //address owner = msg.sender; // Replace with your desired owner address

        new StrangerSquareDN404();

        vm.stopBroadcast();
    }
}

//https://creature.mypinata.cloud/ipfs/QmREg7xFSsXP5J7G8PN9Fsv6yttHrdHJ5PtVsjUop2yi3Z/
