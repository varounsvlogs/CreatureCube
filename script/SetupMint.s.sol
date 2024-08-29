// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {StrangerSquareDN404} from "../src/example/StrangerSquareDN404.sol";
import "forge-std/Script.sol";

contract StrangerSquareDN404Script is Script {

    address constant DN404 = 0x9C0a64a222269296a4369966761cA17bc16E9245;

    function run() external {
        
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY_3");
        vm.startBroadcast(deployerPrivateKey);

        new StrangerSquareDN404();

        vm.stopBroadcast();
    }
}
