// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Script.sol";
import "../src/example/AutoLiquidity.sol";  // Adjust the path if necessary

contract DeployAutoLiquidity is Script {
    // Replace with actual UniswapV2 Router and token addresses when deploying
    address constant UNISWAP_V2_ROUTER = 0x4752ba5DBc23f44D87826276BF6Fd6b1C372aD24;
    address constant TOKEN_ADDRESS = 0x556aDb207D4b6bacf991f80cE2E00D863fb1e807;

    function run() external {
        // Start broadcasting to deploy the contract to the blockchain
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY_3");
        vm.startBroadcast(deployerPrivateKey);

        // Deploy the AutoLiquidity contract with the provided addresses
        AutoLiquidity autoLiquidity = new AutoLiquidity(UNISWAP_V2_ROUTER, TOKEN_ADDRESS);

        // Log the contract address to the console
        console.log("AutoLiquidity deployed to:", address(autoLiquidity));

        // Stop broadcasting
        vm.stopBroadcast();
    }
}

