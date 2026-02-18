// SPDX-License-Identifier: MIT
// Academic Grade - AOXCMainEngine Ultimate Pro Standard v2.0
pragma solidity 0.8.33;

import {IERC165} from "@openzeppelin/contracts/utils/introspection/IERC165.sol";

/**
 * @title IAssetBackingLedger
 * @author AOXCMainEngine Core Engineering
 * @notice Interface for the protocol's collateral tracking and valuation system.
 * @dev High-precision accounting for multi-asset backing.
 */
interface IAssetBackingLedger is IERC165 {
    // --- Custom Errors ---
    error Ledger__StalePriceDetected(uint256 lastUpdate);
    error Ledger__AssetNotSupported(address asset);
    error Ledger__NegativeValueProtection();

    // --- Events ---
    event CollateralUpdated(address indexed asset, uint256 amount, uint256 usdValue);

    /**
     * @notice Calculates the total USD value of all assets held in the backing.
     * @dev PRO ULTIMATE: This must return a 1:1 oracle-normalized value with 18 decimals.
     * Required by AOXCInvariantChecker for solvency verification.
     * @return The total valuation in USD (18 decimals).
     */
    function getTotalValue() external view returns (uint256);

    /**
     * @notice Returns the valuation of a specific asset.
     * @param asset The contract address of the collateral asset.
     * @return The asset's current value contribution to the backing.
     */
    function getAssetValue(address asset) external view returns (uint256);

    /**
     * @notice Checks if the ledger's data is fresh and reliable.
     * @return True if the internal heartbeat is within acceptable parameters.
     */
    function isDataFresh() external view returns (bool);
}
