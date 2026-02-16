// SPDX-License-Identifier: MIT
// Academic Grade - AOXC Access Control Interface Standard
pragma solidity 0.8.33;

import { IMonitoringHub } from "./IMonitoringHub.sol";

/**
 * @title IAOXCAccessCoordinator
 * @notice Interface defining the core authority and emergency signaling of the AOXC Fleet.
 * @dev This bridge allows modular components (CircuitBreaker, ScorchedEarth, etc.) to
 * communicate with the central nervous system.
 */
interface IAOXCAccessCoordinator {
    // --- Access Verification ---
    function hasSovereignPower(address account) external view returns (bool);
    function isOperationAllowed(bytes32 role, address account) external view returns (bool);

    // --- Emergency Signaling (The Missing Links) ---
    /**
     * @notice Global signal for Scorched Earth protocols.
     */
    function triggerGlobalLockdown() external;

    /**
     * @notice Releases system-wide pause.
     */
    function releaseGlobalLockdown() external;

    /**
     * @notice Standard emergency pause for automated sentinel response.
     * @dev Resolves "Member not found" error in AOXCCircuitBreaker.
     */
    function triggerEmergencyPause(string calldata reason) external;

    // --- Monitoring & Infrastructure ---
    /**
     * @notice Returns the active Monitoring Hub for forensic logging.
     */
    function monitoringHub() external view returns (IMonitoringHub);

    /**
     * @notice Manages individual module/sector access states.
     */
    function setSectorStatus(bytes32 sectorId, bool status) external;
}
