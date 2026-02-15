// SPDX-License-Identifier: MIT
pragma solidity 0.8.33;

/**
 * @title IAOXCSwap
 * @author AOXC Core Engineering
 * @notice Interface for the protocol-wide liquidity exchange engine.
 */
interface IAOXCSwap {
    struct SwapRoute {
        address tokenIn;
        address tokenOut;
        uint24 poolFee;
        uint256 minAmountOut;
    }

    event SwapExecuted(
        address indexed user,
        address indexed tokenIn,
        address indexed tokenOut,
        uint256 amountIn,
        uint256 amountOut,
        uint8 riskScore
    );

    /**
     * @notice Performs a swap between two supported assets.
     */
    function executeSwap(
        SwapRoute calldata route,
        uint256 amountIn
    ) external payable returns (uint256 amountOut);

    /**
     * @notice Returns price quote for a given amount.
     */
    function getAmountOut(
        address tokenIn,
        address tokenOut,
        uint256 amountIn
    ) external view returns (uint256);
}
