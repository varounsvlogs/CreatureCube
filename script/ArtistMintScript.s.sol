// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "forge-std/Script.sol";

interface ICreatureCubeDN404 {
    function currentPhase() external view returns (uint8);
    function owner() external view returns (address);
    function artistMint(address recipient, uint256 nftAmount) external;
}

contract ArtistMintScript is Script {
    function run() external {
        uint256 randomPrivateKey = vm.envUint("PRIVATE_KEY_2"); // Fetch private key from environment variables
        address eoaAddress = vm.addr(randomPrivateKey); // Convert the private key to the corresponding address

        address contractAddress = 0x5e079Ac8C77B42246B709dD6F2032A25c564943a; // The deployed contract address
        address recipient = 0x67D64ACfB8511056af8F0C8a5993D64486f73712; // Set the recipient as msg.sender
        uint256 nftAmount = 1; // Define the number of NFTs you want to mint

        // Log the EOA of the private key to the console
        console.log("EOA Address for Private Key:", eoaAddress);

        // Start the broadcast to execute transactions
        vm.startBroadcast(randomPrivateKey);

        // Pull the current phase from the contract using the getter function
        uint8 currentPhase = ICreatureCubeDN404(contractAddress).currentPhase();

        // Pull the owner from the contract using the getter function
        address contractOwner = ICreatureCubeDN404(contractAddress).owner();

        // Log the current phase and owner to the console
        console.log("Current Phase:", currentPhase);
        console.log("Contract Owner:", contractOwner);

        // Call artistMint function
        ICreatureCubeDN404(contractAddress).artistMint(recipient, nftAmount);

        // Stop the broadcast
        vm.stopBroadcast();
    }
}
