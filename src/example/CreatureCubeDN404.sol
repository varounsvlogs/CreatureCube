// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "../DN404.sol";
import "../DN404Mirror.sol";
import {Ownable} from "solady/auth/Ownable.sol";
import {LibString} from "solady/utils/LibString.sol";
import {SafeTransferLib} from "solady/utils/SafeTransferLib.sol";
import {ERC2981} from "@openzeppelin/contracts/token/common/ERC2981.sol";

/**
 * @title CreatureCubeDN404
 * @notice CreatureCubeDN404 is an open edition NFT minting contract based on DN404, with a fixed mint price and no supply limits.
 * Minting ends when the owner calls `endMint`. Each NFT deed represents 1000 ERC20 tokens in the DN404 system.
 */
contract CreatureCubeDN404 is DN404, Ownable, ERC2981 {
    string private _name = "CreatureCubes";
    string private _symbol = "cubes";
    string private _baseURI;
    uint256 public constant MINT_PRICE = 0.0019 ether;
    bool public mintingLive = true;
    bool public mintEnded = false;
    address public autoLPAddress;
    uint8 public currentPhase = 0;
    address public mirrorAddress; // Store the address of the mirror contract

    // Override to set 1 NFT = 1000 Tokens
    uint256 public constant TOKENS_PER_NFT = 1000 * 10 ** 18;

    // Global pause flag
    bool public paused = false;

    constructor() {
        _initializeOwner(msg.sender);
        _setDefaultRoyalty(msg.sender, 500); // 5% royalty fee

        // Start the project in Phase 0 (no minting allowed)
        currentPhase = 0;

        // Set the initial token supply to 0
        mirrorAddress = address(new DN404Mirror(msg.sender)); // Store mirror address
        _initializeDN404(0, msg.sender, mirrorAddress); // Initial token supply set to 0 at deployment
    }

    modifier onlyLive() {
        require(mintingLive && !paused, "Minting has ended or paused");
        require(!mintEnded, "Minting has permanently ended");
        _;
    }

    modifier checkPrice(uint256 nftAmount) {
        require(msg.value == nftAmount * MINT_PRICE, "Incorrect ETH amount sent");
        _;
    }

    modifier onlyOwnerInPhase(uint8 phase) {
        require(currentPhase == phase || msg.sender == owner(), "Not allowed in this phase");
        _;
    }

    modifier inPhase(uint8 phase) {
        require(currentPhase == phase, "Not allowed in this phase");
        _;
    }

    // Phase controls
    function setPhase(uint8 phase) public onlyOwner {
        require(phase <= 3, "Invalid phase");
        currentPhase = phase;
    }

    // Mint functions
    function mint(uint256 nftAmount)
        public
        payable
        onlyLive
        checkPrice(nftAmount)
        inPhase(1) // Phase 1: Open to all
    {
        _mint(msg.sender, nftAmount * _unit());
    }

    function artistMint(address recipient, uint256 nftAmount)
        public
        onlyOwnerInPhase(2) // Phase 2: Owner-only minting
    {
        _mint(recipient, nftAmount * _unit());
        setSkipNFTFor(recipient, true); // Set skipNFT for the recipient
    }

    function lpMint(uint256 nftAmount)
        public
        onlyOwnerInPhase(3) // Phase 3: Owner-only minting (for LP purposes)
    {
        require(autoLPAddress != address(0), "AutoLP address not set");
        _mint(autoLPAddress, nftAmount * _unit());
        setSkipNFTFor(autoLPAddress, true); // Set skipNFT for the LP address
    }

    // LP management functions
    function setAutoLP(address _autoLPAddress) public onlyOwner {
        autoLPAddress = _autoLPAddress;
    }

    function transferLPEth() public onlyOwner {
        require(autoLPAddress != address(0), "AutoLP address not set");
        uint256 transferAmount = address(this).balance / 10; // 10% of contract balance
        SafeTransferLib.safeTransferETH(autoLPAddress, transferAmount);
    }

    // Mint end control
    function endMint() public onlyOwner inPhase(3) { // Phase 3: End minting
        mintEnded = true;
    }

    // Pause all functionality except endMint
    function setPause(bool _paused) public onlyOwner {
        paused = _paused;
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

    // Withdraw Ether
    function withdraw() public onlyOwner {
        SafeTransferLib.safeTransferAllETH(msg.sender);
    }

    // Set the base URI
    function setBaseURI(string calldata baseURI_) public onlyOwner {
        _baseURI = baseURI_;
    }

    // Set skipNFT for an account
    function setSkipNFTFor(address account, bool state) public onlyOwner {
        _setSkipNFT(account, state);
    }

    // Modifier to allow only the owner or the mirror contract to call specific functions
    modifier onlyOwnerOrMirror() {
        require(msg.sender == owner() || msg.sender == mirror(), "Not allowed");
        _;
    }

    // Get the mirror address
    function mirror() public view returns (address) {
        return mirrorAddress;
    }
}