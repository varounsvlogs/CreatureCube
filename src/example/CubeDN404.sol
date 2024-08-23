// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "../DN404.sol";
import "../DN404Mirror.sol";
import {Ownable} from "solady/auth/Ownable.sol";
import {LibString} from "solady/utils/LibString.sol";
import {SafeTransferLib} from "solady/utils/SafeTransferLib.sol";
import {ERC2981} from "@openzeppelin/contracts/token/common/ERC2981.sol";

/**
 * @title CubeDN404
 * @notice CubeDN404 is an open edition NFT minting contract based on DN404, with a fixed mint price and no supply limits.
 * Minting ends when the owner calls `endMint`. Each NFT deed represents 1000 ERC20 tokens in the DN404 system.
 */
contract CubeDN404 is DN404, Ownable, ERC2981 {
    string private _name = "CreatureCubes";
    string private _symbol = "cubes";
    string private _baseURI;
    uint256 public constant MINT_PRICE = 0.0019 ether;
    bool public mintingLive = true;

    // Override to set 1 NFT = 1000 Tokens
    uint256 public constant TOKENS_PER_NFT = 1000 * 10 ** 18;

    constructor(
        uint96 initialTokenSupply,
        address initialSupplyOwner
    ) {
        _initializeOwner(msg.sender);
        _setDefaultRoyalty(msg.sender, 500); // 5% royalty fee

        address mirror = address(new DN404Mirror(msg.sender));
        _initializeDN404(initialTokenSupply, initialSupplyOwner, mirror);
    }

    modifier onlyLive() {
        require(mintingLive, "Minting has ended");
        _;
    }

    modifier checkPrice(uint256 nftAmount) {
        require(msg.value == nftAmount * MINT_PRICE, "Incorrect ETH amount sent");
        _;
    }

    function mint(uint256 nftAmount)
        public
        payable
        onlyLive
        checkPrice(nftAmount)
    {
        _mint(msg.sender, nftAmount * _unit());
    }

    function endMint() public onlyOwner {
        mintingLive = false;
    }

    function setBaseURI(string calldata baseURI_) public onlyOwner {
        _baseURI = baseURI_;
    }

    function withdraw() public onlyOwner {
        SafeTransferLib.safeTransferAllETH(msg.sender);
    }

    // ERC721 Metadata
    function name() public view override returns (string memory) {
        return _name;
    }

    function symbol() public view override returns (string memory) {
        return _symbol;
    }

    function _tokenURI(uint256 tokenId) internal view override returns (string memory) {
        if (bytes(_baseURI).length != 0) {
            return string(abi.encodePacked(_baseURI, LibString.toString(tokenId)));
        }
        return "";
    }

    // Override _unit to ensure 1 NFT = 1000 Tokens
    function _unit() internal pure override returns (uint256) {
        return TOKENS_PER_NFT;
    }

    // ERC2981 Royalty Standard
    function supportsInterface(bytes4 interfaceId) public view override(ERC2981) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
