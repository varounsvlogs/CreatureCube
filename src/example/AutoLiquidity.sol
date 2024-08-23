// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract AutoLiquidity is Ownable, ReentrancyGuard {
    IUniswapV2Router02 public immutable uniswapRouter;
    IERC20 public immutable token;
    address public immutable WETH;

    /**
     * @notice Constructor to initialize the Uniswap Router and Token addresses.
     * @param _uniswapRouter The address of the Uniswap V2 Router contract.
     * @param _token The address of the ERC20 token for which liquidity will be provided.
     */
    constructor(address _uniswapRouter, address _token) {
        require(_uniswapRouter != address(0), "Invalid Uniswap Router address");
        require(_token != address(0), "Invalid token address");

        uniswapRouter = IUniswapV2Router02(_uniswapRouter);
        token = IERC20(_token);
        WETH = uniswapRouter.WETH();
    }

    /**
     * @notice Adds all available liquidity to the Uniswap pool with ETH and the specified ERC20 token.
     * @param slippagePercent The slippage percentage (e.g., 1 for 1%, 2 for 2%).
     * @param deadline The deadline for the transaction to be mined (in seconds).
     * @dev This function will use all of the ETH and ERC20 tokens in the contract's balance to provide liquidity.
     */
    function addLiquidity(uint256 slippagePercent, uint256 deadline) external onlyOwner nonReentrant {
        require(slippagePercent > 0 && slippagePercent <= 100, "Invalid slippage percent");
        uint256 tokenAmount = token.balanceOf(address(this));
        uint256 ethAmount = address(this).balance;

        require(tokenAmount > 0, "No tokens available in the contract");
        require(ethAmount > 0, "No ETH available in the contract");

        // Calculate the minimum amounts with the user-defined slippage
        uint256 minTokenAmount = tokenAmount * (100 - slippagePercent) / 100;
        uint256 minEthAmount = ethAmount * (100 - slippagePercent) / 100;

        // Approve the Uniswap router to spend the contract's tokens
        token.approve(address(uniswapRouter), tokenAmount);

        // Add liquidity using the full balances of ETH and tokens, with slippage protection
        uniswapRouter.addLiquidityETH{value: ethAmount}(
            address(token),            // Token address
            tokenAmount,               // Full token amount in the contract
            minTokenAmount,            // Minimum token amount based on slippage
            minEthAmount,              // Minimum ETH amount based on slippage
            msg.sender,                // The address receiving the LP tokens
            block.timestamp + deadline // Custom deadline for the transaction
        );
    }

    /**
     * @notice Allows the user to manually add liquidity with custom parameters.
     * @param minTokenAmount Minimum amount of tokens to add (custom slippage protection).
     * @param minEthAmount Minimum amount of ETH to add (custom slippage protection).
     * @param deadline The deadline for the transaction to be mined (in seconds).
     */
    function addLiquidityManually(uint256 minTokenAmount, uint256 minEthAmount, uint256 deadline) external onlyOwner nonReentrant {
        uint256 tokenAmount = token.balanceOf(address(this));
        uint256 ethAmount = address(this).balance;

        require(tokenAmount > 0, "No tokens available in the contract");
        require(ethAmount > 0, "No ETH available in the contract");
        require(minTokenAmount > 0, "Minimum token amount must be greater than 0");
        require(minEthAmount > 0, "Minimum ETH amount must be greater than 0");

        // Approve the Uniswap router to spend the contract's tokens
        token.approve(address(uniswapRouter), tokenAmount);

        // Add liquidity using the custom minimum amounts provided by the user
        uniswapRouter.addLiquidityETH{value: ethAmount}(
            address(token),            // Token address
            tokenAmount,               // Full token amount in the contract
            minTokenAmount,            // Custom minimum token amount (slippage protection)
            minEthAmount,              // Custom minimum ETH amount (slippage protection)
            msg.sender,                // The address receiving the LP tokens
            block.timestamp + deadline // Custom deadline for the transaction
        );
    }

    /**
     * @notice Allows the owner to recover any tokens or ETH locked in the contract.
     * @param tokenAddress The address of the token to withdraw (use address(0) for ETH).
     * @param amount The amount of tokens or ETH to withdraw.
     */
    function withdraw(address tokenAddress, uint256 amount) external onlyOwner nonReentrant {
        if (tokenAddress == address(0)) {
            // Withdraw ETH
            require(address(this).balance >= amount, "Insufficient ETH balance");
            payable(owner()).transfer(amount);
        } else {
            // Withdraw ERC20 tokens
            IERC20 tokenToWithdraw = IERC20(tokenAddress);
            require(tokenToWithdraw.balanceOf(address(this)) >= amount, "Insufficient token balance");
            tokenToWithdraw.transfer(owner(), amount);
        }
    }

    /**
     * @notice Returns the current balance of ETH held by the contract.
     * @return The ETH balance of the contract.
     */
    function getContractEthBalance() external view returns (uint256) {
        return address(this).balance;
    }

    /**
     * @notice Returns the current balance of ERC20 tokens held by the contract.
     * @return The token balance of the contract.
     */
    function getContractTokenBalance() external view returns (uint256) {
        return token.balanceOf(address(this));
    }

    /**
     * @notice Fallback function to accept ETH directly into the contract.
     */
    receive() external payable {}
}
