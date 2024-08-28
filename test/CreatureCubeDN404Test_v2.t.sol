// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./utils/SoladyTest.sol";
import {CreatureCubeDN404} from "../src/example/CreatureCubeDN404.sol";


contract CreatureCubeDN404Test_v2 is SoladyTest {
    uint256 internal constant _WAD = 10 ** 18;

    CreatureCubeDN404 creatureCube;
    address owner;
    address randomUser;
    address lpAddress;

    function setUp() public {
        owner = address(this); // Use the test contract as the owner
        randomUser = vm.addr(1); // Create a random user address
        lpAddress = vm.addr(2); // Create an LP address

        // Deploy the CreatureCubeDN404 contract
        creatureCube = new CreatureCubeDN404();

        // Give the owner and random user some initial ETH
        vm.deal(owner, 1 ether);
        vm.deal(randomUser, 5 ether); // Ensure the random user has enough ETH to mint NFTs

        // Set the contract to Phase 1 (Open to all)
        creatureCube.setPhase(1);
    }

    function testMint() public {
        vm.startPrank(randomUser);

        uint256 nftAmount = 3;
        uint256 requiredEther = nftAmount * creatureCube.MINT_PRICE();

        // Expect revert if incorrect Ether amount is sent
        vm.expectRevert("Incorrect ETH amount sent");
        creatureCube.mint{value: 1 ether}(nftAmount);

        // Mint successfully with the correct Ether amount
        creatureCube.mint{value: requiredEther}(nftAmount);
        assertEq(creatureCube.totalSupply(), nftAmount * creatureCube.TOKENS_PER_NFT());
        assertEq(creatureCube.balanceOf(randomUser), nftAmount * creatureCube.TOKENS_PER_NFT());

        vm.stopPrank();
    }

    function testFail_MintingDisallowedInPhase0() public {
        creatureCube.setPhase(0); // Set to Phase 0 (No minting allowed)

        vm.prank(randomUser);
        creatureCube.mint{value: creatureCube.MINT_PRICE()}(1); // This should fail
    }

    function testFail_MintWithNoEther() public {
        vm.prank(randomUser);
        vm.expectRevert("Incorrect ETH amount sent");
        creatureCube.mint{value: 0}(1); // This should fail because no Ether is sent
    }

    function testArtistMintAllowedInPhase2() public {
        creatureCube.setPhase(2); // Set phase to 2 (Owner-only minting)

        uint256 nftAmount = 1;

        // Owner mints for a recipient (randomUser)
        creatureCube.artistMint(randomUser, nftAmount);
        assertEq(creatureCube.balanceOf(randomUser), nftAmount * creatureCube.TOKENS_PER_NFT());
    }

    function testFail_NonOwnerCannotArtistMint() public {
        creatureCube.setPhase(2); // Set phase to 2 (Owner-only minting)

        vm.prank(randomUser);
        vm.expectRevert("Not allowed in this phase");
        creatureCube.artistMint(randomUser, 1); // This should fail because only the owner can mint in Phase 2
    }

    function testLPMintAllowedInPhase3() public {
        creatureCube.setPhase(3); // Set phase to 3 (Owner-only LP minting)
        creatureCube.setAutoLP(lpAddress); // Set the LP address

        uint256 nftAmount = 1;

        // Owner mints for the LP address
        creatureCube.lpMint(nftAmount);
        assertEq(creatureCube.balanceOf(lpAddress), nftAmount * creatureCube.TOKENS_PER_NFT());
    }

    function testFail_LPMintWithoutLPAddress() public {
        creatureCube.setPhase(3); // Set phase to 3 (Owner-only LP minting)

        vm.expectRevert("AutoLP address not set");
        creatureCube.lpMint(1); // This should fail because the LP address is not set
    }

    // function testEndMintDisablesMinting() public {
    //     creatureCube.setPhase(3); // Set phase to 3 (Owner-only LP minting)
    //     creatureCube.endMint(); // End minting

    //     vm.prank(owner);
    //     vm.expectRevert(); // Expect revert because minting has ended
    //     creatureCube.mint{value: creatureCube.MINT_PRICE()}(1);
    // }
    
    // function testEndMintDisablesMinting() public {
    //     creatureCube.setPhase(3); // Set phase to 3 (Owner-only LP minting)
    //     creatureCube.endMint(); // End minting

    //     vm.prank(owner); // Use the owner for the mint call

    //     // Expect revert because minting has ended
    //     vm.expectRevert(); 
    //     creatureCube.mint{value: creatureCube.MINT_PRICE()}(1);
    // }

    function testEndMintDisablesMinting() public {
        // Start recording logs
        vm.recordLogs();
        
        // Set the phase to 3 (Owner-only LP minting)
        creatureCube.setPhase(3); 
        
        // End minting
        creatureCube.endMint(); 
        
        // Minting should now be disabled
        vm.prank(owner); 

        // Expect revert because minting has ended
        vm.expectRevert("Minting has permanently ended"); 
        creatureCube.mint{value: creatureCube.MINT_PRICE()}(1);
    }



    function testPausePreventsMinting() public {
        creatureCube.setPhase(1); // Set phase to 1 (Open to all)
        creatureCube.setPause(true); // Pause the contract

        vm.prank(randomUser);
        vm.expectRevert("Minting has ended or paused");
        creatureCube.mint{value: creatureCube.MINT_PRICE()}(1); // This should fail because the contract is paused
    }

    function testNonOwnerCannotWithdraw() public {
        vm.deal(address(creatureCube), 1 ether); // Fund the contract with 1 ether

        vm.prank(randomUser);
        vm.expectRevert("Unauthorized");
        creatureCube.withdraw(); // This should fail because randomUser is not the owner
    }

    function testOwnerCanWithdraw() public {
        vm.deal(address(creatureCube), 1 ether); // Fund the contract with 1 ether

        uint256 initialBalance = address(owner).balance;
        creatureCube.withdraw(); // Withdraw as the owner
        assertEq(address(owner).balance, initialBalance + 1 ether); // Ensure the owner received the ether
    }

    function testMintAndWithdraw() public {
        creatureCube.setPhase(1); // Set phase to 1 (Open to all)

        // Mint 20 NFTs from the random user
        uint256 nftAmount = 20;
        uint256 totalCost = nftAmount * creatureCube.MINT_PRICE();

        vm.prank(randomUser);
        creatureCube.mint{value: totalCost}(nftAmount);

        // Check that the contract has the correct amount of Ether
        assertEq(address(creatureCube).balance, totalCost);

        // Withdraw the Ether from the contract by the owner
        creatureCube.withdraw();

        // Ensure the owner's balance increased by the withdrawn amount
        assertEq(address(owner).balance, totalCost);
        assertEq(address(creatureCube).balance, 0); // Ensure the contract balance is now zero
    }
}
