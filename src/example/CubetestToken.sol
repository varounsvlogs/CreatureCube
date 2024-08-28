// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/**
 * @title CubetestToken
 * @dev ERC20 Token with an initial supply of 1 million tokens, called "CUBETEST".
 */
contract CubetestToken is ERC20 {
    constructor() ERC20("CUBETEST", "CUBE") {
        _mint(msg.sender, 1_000_000 * 10**18); // Mint 1 million tokens to the deployer
    }
}
