// SPDX-License-Identifier: MIT
pragma solidity 0.8.33;

/**
 * @title ISentinelExecutor
 * @notice Interface for automated security interventions based on forensic risk analysis.
 */
interface ISentinelExecutor {
    /**
     * @notice Triggers an emergency action on a target contract.
     * @param target The contract address to intervene (e.g., Treasury, Swap).
     * @param actionCode Internal code representing the type of intervention (0: Pause, 1: Blacklist, 2: Fund Rescue).
     */
    function triggerIntervention(address target, uint8 actionCode) external;

    /**
     * @notice Validates if a transaction origin is under investigation.
     */
    function isUnderSanction(address account) external view returns (bool);
}
