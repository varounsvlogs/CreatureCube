// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Script.sol";

contract IncrementNonceScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY_3"); // Load sender's private key from environment variable
        address payable sender = payable(vm.addr(deployerPrivateKey)); // Get the sender's address

        vm.startBroadcast(deployerPrivateKey);

        // Send an empty transaction with 0 ETH to yourself to increment the nonce
        (bool success, ) = sender.call{value: 0}("");
        require(success, "Transaction failed");

        vm.stopBroadcast();
    }
}
