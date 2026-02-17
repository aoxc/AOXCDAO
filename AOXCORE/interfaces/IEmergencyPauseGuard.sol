// SPDX-License-Identifier: MIT
pragma solidity 0.8.33;

/**
 * @title  IEmergencyPauseGuard
 * @notice Institutional interface for Guardian-initiated circuit breaker mechanisms and global state suspension.
 * @dev    AOXC Ultimate Protocol: Vertical Alignment, High Technical Eloquence, and Audit-Ready NatSpec.
 */
interface IEmergencyPauseGuard {
    // --- SECTION: EVENTS ---
    event EmergencyPaused(address indexed guardian, uint256 timestamp);
    event EmergencyResumed(address indexed guardian, uint256 timestamp);

    // --- SECTION: CIRCUIT BREAKER OPERATIONS ---
    function pause() external;
    function resume() external;

    // --- SECTION: VIEW OPERATIONS ---
    function isPaused() external view returns (bool status);
}
