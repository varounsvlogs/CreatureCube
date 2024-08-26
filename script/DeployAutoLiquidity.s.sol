// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Script.sol";
import "../src/example/AutoLiquidity.sol";  // Adjust the path if necessary

contract DeployAutoLiquidity is Script {
    // Replace with actual UniswapV2 Router and token addresses when deploying
    address constant UNISWAP_V2_ROUTER = 0xDEd15184b382797338d29674f906b9bcD194B2CE;
    address constant TOKEN_ADDRESS = 0x6fF7bFceb1cbAaF6b41EBE5f0f27048e42efE660;

    function run() external {
        // Start broadcasting to deploy the contract to the blockchain
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        // Deploy the AutoLiquidity contract with the provided addresses
        AutoLiquidity autoLiquidity = new AutoLiquidity(UNISWAP_V2_ROUTER, TOKEN_ADDRESS);

        // Log the contract address to the console
        console.log("AutoLiquidity deployed to:", address(autoLiquidity));

        // Stop broadcasting
        vm.stopBroadcast();
    }
}

