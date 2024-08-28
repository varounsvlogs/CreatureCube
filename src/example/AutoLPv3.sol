// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@uniswap/v3-periphery/contracts/interfaces/INonfungiblePositionManager.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";


contract UniswapV3LiquidityManager {
    using SafeERC20 for IERC20;

    INonfungiblePositionManager public positionManager;
    address public token0;
    address public token1;
    uint24 public poolFee;

    constructor(
        address _positionManager,
        address _token0,
        address _token1,
        uint24 _poolFee
    ) {
        positionManager = INonfungiblePositionManager(_positionManager);
        token0 = _token0;
        token1 = _token1;
        poolFee = _poolFee;
    }

    function addLiquidity(
        uint256 amount0Desired,
        uint256 amount1Desired,
        int24 tickLower,
        int24 tickUpper
    ) external returns (uint256 tokenId, uint128 liquidity, uint256 amount0, uint256 amount1) {
        // Transfer the tokens from the sender to the contract
        IERC20(token0).safeTransferFrom(msg.sender, address(this), amount0Desired);
        IERC20(token1).safeTransferFrom(msg.sender, address(this), amount1Desired);

        // Approve the NonfungiblePositionManager to spend the tokens
        IERC20(token0).safeApprove(address(positionManager), amount0Desired);
        IERC20(token1).safeApprove(address(positionManager), amount1Desired);

        // Define the mint parameters
        INonfungiblePositionManager.MintParams memory params = INonfungiblePositionManager.MintParams({
            token0: token0,
            token1: token1,
            fee: poolFee,
            tickLower: tickLower,
            tickUpper: tickUpper,
            amount0Desired: amount0Desired,
            amount1Desired: amount1Desired,
            amount0Min: 0,
            amount1Min: 0,
            recipient: msg.sender,
            deadline: block.timestamp + 300
        });

        // Mint the position (add liquidity)
        (tokenId, liquidity, amount0, amount1) = positionManager.mint(params);

        // Refund any leftover tokens
        if (amount0 < amount0Desired) {
            IERC20(token0).safeTransfer(msg.sender, amount0Desired - amount0);
        }
        if (amount1 < amount1Desired) {
            IERC20(token1).safeTransfer(msg.sender, amount1Desired - amount1);
        }
    }
}
