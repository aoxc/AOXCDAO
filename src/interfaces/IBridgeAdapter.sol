// SPDX-License-Identifier: MIT
pragma solidity 0.8.33;

/**
 * @title  IBridgeAdapter
 * @notice Institutional-grade interface for cross-chain liquidity synchronization and bridge orchestration.
 * @dev    AOXC Ultimate Protocol: Vertical Alignment, High Technical Eloquence, and Audit-Ready NatSpec.
 */
interface IBridgeAdapter {
    // --- SECTION: EVENTS ---

    event AssetBridged(
        uint256 indexed targetChainId,
        address indexed token,
        address indexed recipient,
        uint256 amount,
        bytes32 txHash,
        uint256 timestamp
    );

    event BridgeFinalized(bytes32 indexed txHash, uint256 timestamp);

    // --- SECTION: CROSS-CHAIN OPERATIONS ---

    /**
     * @notice Initiates a cross-chain asset transfer.
     * @param targetChainId The destination chain identifier.
     * @param token The address of the token to bridge (use address(0) for native gas tokens).
     * @param amount The quantity of assets to transfer.
     * @param recipient The destination address on the target chain.
     * @return txHash The unique transaction identifier for tracking.
     * @dev V5 FIX: Added 'payable' to support native gas token bridging and protocol fees.
     */
    function bridgeAsset(uint256 targetChainId, address token, uint256 amount, address recipient)
        external
        payable
        returns (bytes32 txHash); // <-- PAYABLE EKLENDİ

    /**
     * @notice Verifies if a specific bridge transaction has reached finality.
     * @param txHash The transaction identifier to check.
     * @return finalized Boolean indicating completion status.
     */
    function isTransactionFinalized(bytes32 txHash) external view returns (bool finalized);

    // --- SECTION: METADATA & DISCOVERY ---

    /**
     * @notice Returns the human-readable identifier of the bridge adapter.
     */
    function getAdapterName() external pure returns (string memory name);

    /**
     * @notice Retrieves the list of destination chains currently supported by this adapter.
     */
    function getSupportedChains() external view returns (uint256[] memory chains);
}
