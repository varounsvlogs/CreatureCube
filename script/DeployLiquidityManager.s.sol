// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import "../src/liquidity/AutoLPv3.sol";  // Adjust the import path based on your project structure

contract DeployLiquidityManager is Script {
    function run() external {
        // Start broadcasting transactions using the default sender (msg.sender)
        vm.startBroadcast();

        // Address of the Uniswap V3 Position Manager (replace with the correct address for your network)
        address positionManager = 0x27F971cb582BF9E50F397e4d29a5C7A34f11faA2; // Mainnet
        // Address of the WETH contract (replace with the correct address for your network)
        address weth = 0x4200000000000000000000000000000000000006; // Mainnet

        // Deploy the LiquidityManager contract
        LiquidityManager liquidityManager = new LiquidityManager(positionManager, weth);

        // Log the deployed contract address
        console.log("LiquidityManager deployed at:", address(liquidityManager));

        // Stop broadcasting transactions
        vm.stopBroadcast();
    }
}
