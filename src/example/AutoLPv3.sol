// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@uniswap/v3-periphery/contracts/interfaces/INonfungiblePositionManager.sol";
import "@uniswap/v3-core/contracts/interfaces/IERC20.sol";

contract LiquidityManager is Ownable {
    address public immutable POSITION_MANAGER;
    INonfungiblePositionManager public immutable nonfungiblePositionManager;
    address public immutable weth;

    uint160 public sqrtPriceX96 = 79228162514264337593543950336; // Default value

    constructor(address _positionManager, address _weth) {
        POSITION_MANAGER = _positionManager;
        nonfungiblePositionManager = INonfungiblePositionManager(_positionManager);
        weth = _weth;
    }

    /// @dev Place liquidity in the pool
    function placeLiquidity(address _baseERC20, uint256 amount0Desired, uint256 amount1Desired) external onlyOwner {
        uint24 poolFee = 3000; // 0.3% fee tier
        bool isToken0 = _baseERC20 < weth;
        address token0 = isToken0 ? _baseERC20 : weth;
        address token1 = isToken0 ? weth : _baseERC20;

        // Get parameters like tick ranges, etc. from some internal logic
        (int24 flTickLower, int24 flTickUpper) = _getLPParams();

        // 1. Create pool if necessary and initialize it with the default or updated price sqrtPriceX96
        address pool = nonfungiblePositionManager.createAndInitializePoolIfNecessary(
            token0,
            token1,
            poolFee,
            sqrtPriceX96
        );

        // 2. Transfer tokens from user to contract and approve position manager
        require(IERC20(token0).transferFrom(msg.sender, address(this), amount0Desired), "Token0 transfer failed");
        require(IERC20(token1).transferFrom(msg.sender, address(this), amount1Desired), "Token1 transfer failed");

        _safeApprove(token0, POSITION_MANAGER, amount0Desired);
        _safeApprove(token1, POSITION_MANAGER, amount1Desired);

        // 3. Mint the liquidity in the specified range
        INonfungiblePositionManager.MintParams memory params = INonfungiblePositionManager.MintParams({
            token0: token0,
            token1: token1,
            fee: poolFee,
            tickLower: flTickLower,
            tickUpper: flTickUpper,
            amount0Desired: amount0Desired,
            amount1Desired: amount1Desired,
            amount0Min: 0,
            amount1Min: 0,
            recipient: msg.sender,
            deadline: block.timestamp + 1200
        });

        (uint256 tokenId, uint128 liquidity, uint256 amount0, uint256 amount1) = nonfungiblePositionManager.mint(params);

        // Refund any leftover tokens to the user
        if (amount0Desired > amount0) {
            IERC20(token0).transfer(msg.sender, amount0Desired - amount0);
        }
        if (amount1Desired > amount1) {
            IERC20(token1).transfer(msg.sender, amount1Desired - amount1);
        }
    }

    /// @notice Allows the owner to update the default sqrtPriceX96
    /// @param _newSqrtPriceX96 The new sqrtPriceX96 value
    function updateSqrtPriceX96(uint160 _newSqrtPriceX96) external onlyOwner {
        sqrtPriceX96 = _newSqrtPriceX96;
    }

    /// @notice This is a placeholder for your logic to get LP tick parameters
    function _getLPParams()
        internal
        pure
        returns (int24 flTickLower, int24 flTickUpper)
    {
        flTickLower = -887272;  // Full range lower tick
        flTickUpper = 887272;   // Full range upper tick
    }

    /// @dev Safely approve tokens, using the exact amount to avoid security issues
    function _safeApprove(address token, address to, uint256 amount) internal onlyOwner {
        IERC20(token).approve(to, 0); // First reset to zero
        IERC20(token).approve(to, amount); // Then approve the actual amount
    }

    // Allow the contract to receive ETH
    receive() external payable onlyOwner {}
}
