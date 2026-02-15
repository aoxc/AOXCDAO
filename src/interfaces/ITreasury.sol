// SPDX-License-Identifier: MIT
pragma solidity 0.8.33;

/**
 * @title  ITreasury
 * @notice Interface defining the full institutional liquidity operations for the AOXC ecosystem.
 * @dev    AOXC Ultimate Protocol: Multi-Asset Vertical Alignment and Secure Liquidity Management.
 */
interface ITreasury {
    // --- SECTION: EVENTS ---

    /// @notice Emitted when assets are deposited into the treasury.
    event Deposit(address indexed from, address indexed token, uint256 amount, uint256 timestamp);

    /// @notice Emitted when assets are withdrawn from the treasury.
    event Withdraw(address indexed to, address indexed token, uint256 amount, uint256 timestamp);

    /// @notice Emitted when an emergency withdrawal occurs (admin-only).
    event EmergencyWithdraw(
        address indexed to, address indexed token, uint256 amount, uint256 timestamp
    );

    /// @notice Emitted when a new token is added to the supported list.
    event TokenSupported(address indexed token, uint256 timestamp);

    /// @notice Emitted when a token is removed from the supported list.
    event TokenUnsupported(address indexed token, uint256 timestamp);

    // --- SECTION: LIQUIDITY OPERATIONS ---

    /**
     * @notice Facilitates the ingestion of capital into the institutional reserve.
     * @param  token  The ERC20 token address or zero address for native ETH.
     * @param  amount Total volume of assets to be deposited.
     */
    function deposit(address token, uint256 amount) external payable;

    /**
     * @notice Dispatches capital from the institutional reserve to a specified recipient.
     * @dev    Access control and internal accounting must be handled by the implementation.
     * @param  token   The ERC20 token address or zero address for native ETH.
     * @param  to      The destination address for the asset transfer.
     * @param  amount  Total volume of assets to be withdrawn.
     */
    function withdraw(address token, address to, uint256 amount) external;

    /**
     * @notice Executes an emergency withdrawal (admin-only).
     * @param  token   The ERC20 token address or zero address for native ETH.
     * @param  to      The destination address for the asset transfer.
     * @param  amount  Total volume of assets to be withdrawn.
     */
    function emergencyWithdraw(address token, address to, uint256 amount) external;

    // --- SECTION: TOKEN MANAGEMENT ---

    /**
     * @notice Adds a new token to the supported list.
     * @param  token The ERC20 token address or zero address for native ETH.
     */
    function addSupportedToken(address token) external;

    /**
     * @notice Removes a token from the supported list.
     * @param  token The ERC20 token address or zero address for native ETH.
     */
    function removeSupportedToken(address token) external;

    // --- SECTION: VIEW OPERATIONS ---

    /**
     * @notice Returns the current liquidity balance held within the treasury for a given token.
     * @param  token The ERC20 token address or zero address for native ETH.
     * @return currentBalance Total asset volume documented in the state.
     */
    function getBalance(address token) external view returns (uint256 currentBalance);

    /**
     * @notice Returns the total reserves across all supported tokens.
     * @dev    Implementation may aggregate balances of multiple tokens.
     * @return totalReserves Aggregated asset volume.
     */
    function getTotalReserves() external view returns (uint256 totalReserves);

    /**
     * @notice Returns the list of all supported tokens in the treasury.
     * @return tokens Array of token addresses (zero address for native ETH).
     */
    function getSupportedTokens() external view returns (address[] memory tokens);
}
