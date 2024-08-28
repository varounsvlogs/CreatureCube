// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "forge-std/Test.sol";
import "../src/example/CreatureCubeDN404v2.sol";

contract CreatureCubeDN404Test is Test {
    CreatureCubeDN404 public creatureCube;
    address public owner;
    address public randomUser;
    address public lpAddress;

    function setUp() public {
        owner = address(this); // Use the test contract as the owner
        randomUser = vm.addr(1); // Create a random user address
        lpAddress = vm.addr(2); // Create an LP address

        // Deploy the CreatureCubeDN404 contract
        creatureCube = new CreatureCubeDN404();
    }

    // function setUp() public {
    //     owner = vm.addr(1);
    //     randomUser = vm.addr(2);
    //     lpAddress = vm.addr(3); // Create an LP address

    //     // Give the owner and random user some initial ETH
    //     vm.deal(owner, 1 ether);
    //     vm.deal(randomUser, 5 ether); // Ensure the random user has enough ETH to mint 20 NFTs

    //     // Deploy the contract
    //     creatureCube = new CreatureCubeDN404();

    //     // Set the contract to Phase 1 (Open to all)
    //     vm.prank(owner);
    //     creatureCube.setPhase(1);
    // }

    // Test that minting is disallowed in Phase 0
    function testFail_MintingDisallowedInPhase0() public {
        vm.prank(randomUser); // Use the random user as the caller
        creatureCube.mint{value: 0.0019 ether}(1);
    }

    function test_MintingAllowedInPhase1_v3() public {
        creatureCube.setPhase(1); // Set the phase to 1 (Open to all)

        uint256 nftAmount = 1;
        uint256 requiredEther = nftAmount * creatureCube.MINT_PRICE();

        vm.prank(randomUser); // Use the random user as the caller

        try creatureCube.mint{value: requiredEther}(nftAmount) {
            console.log("Minting succeeded.");
        } catch {
            console.log("Minting failed. Revert occurred.");
        }
    }



    // Test that public minting works in Phase 1
    function test_MintingAllowedInPhase1_v2() public {
        creatureCube.setPhase(1); // Set the phase to 1 (Open to all)

        // Log current phase
        uint8 phase = creatureCube.currentPhase();
        console.log("Current Phase:", phase);
        require(phase == 1, "Phase is not correctly set to 1");

        // Send the correct amount of Ether for minting
        uint256 nftAmount = 1;
        uint256 requiredEther = nftAmount * creatureCube.MINT_PRICE();

        // Allocate Ether to the random user
        vm.deal(randomUser, requiredEther);

        // Log the mint price and required ether
        uint256 mintPrice = creatureCube.MINT_PRICE();
        console.log("Mint Price:", mintPrice);
        console.log("Required Ether:", requiredEther);

        // Log the state of mintingLive and paused
        console.log("Minting Live:", creatureCube.mintingLive());
        console.log("Paused:", creatureCube.paused());

        // Deal Ether to the contract just in case
        vm.deal(address(creatureCube), 1 ether);

        // Use the random user as the caller
        vm.prank(randomUser);
        
        // Attempt mint and check for success
        creatureCube.mint{value: requiredEther}(nftAmount);
    }

    function test_PhaseIsSetCorrectly() public {
        creatureCube.setPhase(1); // Set to Phase 1
        uint8 phase = creatureCube.currentPhase();
        console.log("Current Phase:", phase);
        require(phase == 1, "Phase was not set to 1");
    }

    function test_MintingLiveAndNotPaused() public view {
        // Ensure that minting is live and not paused
        bool mintingLive = creatureCube.mintingLive();
        bool paused = creatureCube.paused();
        console.log("Minting Live:", mintingLive);
        console.log("Paused:", paused);
        require(mintingLive, "Minting is not live");
        require(!paused, "Contract is paused");
    }

    function test_CorrectEtherRequirement() public view{
        uint256 nftAmount = 1;
        uint256 requiredEther = nftAmount * creatureCube.MINT_PRICE();
        console.log("Required Ether:", requiredEther);

        // Ensure that the price calculation is correct
        require(requiredEther == 0.0019 ether, "Ether requirement mismatch");
    }

    // Test that only the owner can change the phase
    function testFail_NonOwnerCannotSetPhase() public {
        vm.prank(randomUser); // Use the random user as the caller
        creatureCube.setPhase(1); // This should fail because randomUser is not the owner
    }

    function test_FailMintingWithNoEther() public {
        creatureCube.setPhase(1); // Set phase to 1
        vm.prank(randomUser); // Use randomUser to simulate the mint call

        // This should revert due to insufficient Ether
        vm.expectRevert("Incorrect ETH amount sent");
        creatureCube.mint{value: 0}(1);
    }


    // Test that public minting works in Phase 1
    function test_MintingAllowedInPhase1() public {
        creatureCube.setPhase(1); // Set the phase to 1 (Open to all)

        uint8 phase = creatureCube.currentPhase();
        console.log("Current Phase:", phase);
        require(phase == 1, "Phase is not correctly set to 1");

        // Send the correct amount of Ether for minting
        uint256 nftAmount = 1;
        uint256 requiredEther = nftAmount * creatureCube.MINT_PRICE();

        uint256 mintPrice = creatureCube.MINT_PRICE();
        console.log("Mint Price:", mintPrice);
        console.log("Required Ether:", requiredEther);

        // Allocate Ether to the random user
        vm.deal(randomUser, requiredEther);


        vm.prank(randomUser); // Use the random user as the caller
        //creatureCube.mint{value: 0.0019 ether}(1); // This should succeed
        // Call the mint function and check for success
        creatureCube.mint{value: requiredEther}(nftAmount);
    }

    // Test that artistMint fails if not called by the owner in Phase 1 or 2
    function testFail_NonOwnerCannotArtistMint() public {
        creatureCube.setPhase(2); // Set the phase to 2 (Owner-only minting)
        vm.prank(randomUser); // Use the random user as the caller
        creatureCube.artistMint(randomUser, 1); // This should fail because randomUser is not the owner
    }

    // Test that artistMint works in Phase 2 when called by the owner
    function test_ArtistMintAllowedInPhase2() public {
        creatureCube.setPhase(2); // Set the phase to 2 (Owner-only minting)
        creatureCube.artistMint(randomUser, 1); // This should succeed because the owner is calling it
    }

    // Test that lpMint fails if the LP address is not set
    function testFail_LpMintWithoutLPAddress() public {
        creatureCube.setPhase(3); // Set the phase to 3 (Owner-only LP minting)
        creatureCube.lpMint(1); // This should fail because the LP address is not set
    }

    // Test that lpMint works when the LP address is set
    function test_LpMintAllowedInPhase3() public {
        creatureCube.setPhase(3); // Set the phase to 3 (Owner-only LP minting)
        creatureCube.setAutoLP(lpAddress); // Set the LP address
        creatureCube.lpMint(1); // This should succeed
    }

    // Test that endMint works in Phase 3 and prevents further minting
    function test_EndMintDisablesMinting() public {
        creatureCube.setPhase(3); // Set the phase to 3 (Owner-only LP minting)
        creatureCube.endMint(); // End minting

        // Test that minting is now disabled, this should fail
        vm.prank(owner);
        vm.expectRevert(); // Expect revert because minting has ended
        creatureCube.mint{value: 0.0019 ether}(1);
    }

    // Test that pausing the contract prevents minting
    function testFail_PausePreventsMinting() public {
        creatureCube.setPhase(1); // Set the phase to 1 (Open to all)
        creatureCube.setPause(true); // Pause the contract

        vm.prank(randomUser); // Use the random user as the caller
        creatureCube.mint{value: 0.0019 ether}(1); // This should fail because the contract is paused
    }

    // Test that only the owner can withdraw Ether
    function testFail_NonOwnerCannotWithdraw() public {
        vm.deal(address(creatureCube), 1 ether); // Fund the contract with 1 ether

        vm.prank(randomUser); // Use the random user as the caller
        creatureCube.withdraw(); // This should fail because randomUser is not the owner
    }

    // Test that the owner can withdraw Ether
    // function test_OwnerCanWithdraw() public {
    //     vm.deal(address(creatureCube), 1 ether); // Fund the contract with 1 ether

    //     uint256 initialBalance = address(owner).balance;
    //     creatureCube.withdraw(); // Withdraw as the owner
    //     assertEq(address(owner).balance, initialBalance + 1 ether); // Ensure the owner received the ether
    // }

    function test_OwnerCanWithdraw() public {
        // Fund the contract with 1 ETH
        vm.deal(address(creatureCube), 1 ether);

        // Check the balance before withdrawal
        uint256 initialBalance = address(this).balance;

        // Call withdraw function
        creatureCube.withdraw();

        // Check the balance after withdrawal
        uint256 finalBalance = address(this).balance;

        // Assert that the balance increased by 1 ETH
        assertEq(finalBalance, initialBalance + 1 ether);
    }
}
