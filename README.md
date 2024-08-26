# CreatureCubeDN404

`CreatureCubeDN404` is an open edition NFT minting contract based on the DN404 system. It allows for a flexible and phase-controlled minting process, including specific functions for artist minting and liquidity pool management. Each NFT deed represents 1,000 ERC20 tokens within the DN404 system, with a fixed mint price and no supply limits. Minting can be permanently ended when the owner calls `endMint`.

## Contract Overview

- **Name**: Creature Cubes
- **Symbol**: CUBE
- **Mint Price**: 0.0019 ether per NFT
- **Token Representation**: 1 NFT deed = 1,000 ERC20 tokens (CUBES)
- **Phases**: Controlled by the owner to manage minting access.
- **ERC2981 Royalties**: Integrated with a 5% default royalty.
- **Mirror Contract**: The contract interacts with a DN404Mirror for liquidity management.

## Features

### 1. Minting Phases

The contract controls minting access through a phased approach:

- **Phase 0**: No minting allowed.
- **Phase 1**: Open minting for all users.
- **Phase 2**: Owner-only minting (intended for specific artists).
- **Phase 3**: Owner-only minting (intended for liquidity pool purposes).

The contract starts in Phase 0. The owner can change the phase using the `setPhase` function.

### 2. Minting Functions

- **Public Minting** (`mint`): Available during Phase 1. Anyone can mint NFTs by sending the correct Ether amount.
- **Artist Minting** (`artistMint`): Available to the owner during Phases 1 and 2. This function mints NFTs to a recipient while setting the `skipNFT` flag, meaning the recipient receives only the ERC20 tokens and not the NFT deed.
- **Liquidity Pool Minting** (`lpMint`): Available to the owner during Phases 2 and 3. This function mints NFTs to the liquidity pool address (`autoLPAddress`) and sets the `skipNFT` flag for the pool.

### 3. Liquidity Pool Management

- **Set Auto LP Address**: The owner can set the address for the liquidity pool using the `setAutoLP` function.
- **Transfer ETH to LP**: The `transferLPEth` function transfers 10% of the contract's ETH balance to the `autoLPAddress`.

### 4. Mint End Control

- **End Minting**: The `endMint` function permanently stops all minting. This function can only be called by the owner during Phase 3.

### 5. Pause Functionality

- **Pause Minting**: The owner can pause all minting activities using the `setPause` function. Pausing does not affect the ability to call `endMint`.

### 6. Royalties (ERC2981)

The contract implements the ERC2981 royalty standard, with a default royalty set to 5% during deployment. This royalty can be updated using appropriate ERC2981 functions.

### 7. Ownership and Access Control

The contract uses Solady's `Ownable` module for ownership management:

- **Ownership Functions**: Only the owner can call functions such as `setSkipNFTFor`, `setBaseURI`, `setAutoLP`, and minting-related functions.
- **Mirror Contract**: A DN404Mirror contract is deployed during initialization, and its address is stored in `mirrorAddress`. The mirror contract integrates with the DN404 system.

### 8. Token URI and Metadata

- **Token URI**: The `_tokenURI` function returns the metadata URI for a token by concatenating the base URI with the token ID. The owner can update the base URI using the `setBaseURI` function.

### 9. Token Unit Customization

- **Token Representation**: The `_unit` function ensures that each NFT deed represents 1,000 ERC20 tokens. This unit size is fixed and cannot be changed.

### 10. Withdraw Ether

- **Withdraw Function**: The `withdraw` function allows the owner to withdraw all Ether from the contract.

## Installation

To install the contract and its dependencies:

```bash
forge install
```

# DN404 🥜

[![NPM][npm-shield]][npm-url]
[![CI][ci-shield]][ci-url]

DN404 is an implementation of a co-joined ERC20 and ERC721 pair.

To learn more about these dual nature token pairs, you can read the full [ERC-7631 spec](https://eips.ethereum.org/EIPS/eip-7631).

- Full compliance with the ERC20 and ERC721 specifications.
- Transfers on one side will be reflected on the other side.
- Pretty optimized.

## Installation

To install with [**Foundry**](https://github.com/gakonst/foundry):

```sh
forge install vectorized/dn404
```

To install with [**Hardhat**](https://github.com/nomiclabs/hardhat):

```sh
npm install dn404
```

## Contracts

The Solidity smart contracts are located in the `src` directory.

```ml
src
├─ DN404 — "ERC20 contract for DN404"
├─ DN404Mirror — "ERC721 contract for DN404"
├─ DN420 — "Single-contract ERC20 ERC1155 chimera"
└─ example
   ├─ SimpleDN404 — "Simple DN404 example as ERC20"
   └─ NFTMintDN404 — "Simple DN404 example as ERC721"
```

## Contributing

Feel free to make a pull request.

Guidelines same as [Solady's](https://github.com/Vectorized/solady/issues/19).

## Safety

This is **experimental software** and is provided on an "as is" and "as available" basis.

We **do not give any warranties** and **will not be liable for any loss** incurred through any use of this codebase.

While DN404 has been heavily tested, there may be parts that exhibit unexpected emergent behavior when used with other code, or break in future Solidity versions.

Please always include your own thorough tests when using DN404 to make sure it works correctly with your code.

## Upgradability

Most contracts in DN404 are compatible with both upgradeable and non-upgradeable (i.e. regular) contracts.

Please call any required internal initialization methods accordingly.

## Acknowledgments

This repository is inspired by various sources:

- [ERC7647 (a.k.a. SJ741)](https://github.com/SJ741/sj741-token)
- [ERC7651 (a.k.a. "ERC"404)](https://github.com/Pandora-Labs-Org/erc404)
- ["ERC"425](https://github.com/paradox425/ERC425)
- [Solady](https://github.com/vectorized/solady)
- [ERC721A](https://github.com/chiru-labs/ERC721A)

[npm-shield]: https://img.shields.io/npm/v/dn404.svg
[npm-url]: https://www.npmjs.com/package/dn404

[ci-shield]: https://img.shields.io/github/actions/workflow/status/vectorized/dn404/ci.yml?branch=main&label=build
[ci-url]: https://github.com/vectorized/dn404/actions/workflows/ci.yml


