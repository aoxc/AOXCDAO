// SPDX-License-Identifier: MIT
// Academic Grade - AOXCMainEngine Ultimate Pro Standard
pragma solidity 0.8.33;

/**
 * @title AOXCConstants
 * @author AOXCMainEngine Core Engineering
 * @notice Centralized library for system-wide constants, roles, and financial parameters.
 * @dev Optimized for Solidity 0.8.33. All constants are evaluated at compile-time to save gas.
 */
library AOXCConstants {
    // --- Access Control Roles (Immutable Hashes) ---

    /**
     * @dev Root access for governance, DAO, and Multi-sig controllers.
     */
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

    /**
     * @dev Role for emergency response, circuit breakers, and automated sentinels.
     */
    bytes32 public constant SENTINEL_ROLE = keccak256("SENTINEL_ROLE");

    /**
     * @dev Role for protocol upgrades and technical maintenance authorized by governance.
     */
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");

    /**
     * @dev Role for Oracle management, price feed updates, and data validation.
     */
    bytes32 public constant ORACLE_OPERATOR_ROLE = keccak256("ORACLE_OPERATOR_ROLE");

    /**
     * @dev Role for management oversight and compensation approval (Auditors).
     * @notice This role provides the secondary approval for victim compensations.
     */
    bytes32 public constant AUDITOR_ROLE = keccak256("AUDITOR_ROLE");

    // --- Financial & Mathematical Parameters ---

    /**
     * @notice Basis points denominator representing 100.00% precision.
     * @dev Used in Proof of Reserves and Invariant Checkers. 100 BPS = 1.00%.
     */
    uint256 public constant MAX_BPS = 10_000;

    /**
     * @dev Alias for MAX_BPS to maintain semantic clarity in denominator contexts.
     */
    uint256 public constant BPS_DENOMINATOR = 10_000;

    // --- System & Monitoring Thresholds ---

    /**
     * @notice Standard heartbeat interval for oracles and pulse monitoring (24 hours).
     */
    uint256 public constant HEARTBEAT_INTERVAL = 1 days;

    /**
     * @notice Minimum safety margin for reserve ratios.
     * @dev 11000 BPS = 110.00% collateralization ratio.
     */
    uint256 public constant MIN_RESERVE_RATIO = 11_000;
}
