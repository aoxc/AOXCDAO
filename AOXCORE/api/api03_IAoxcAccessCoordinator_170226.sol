// SPDX-License-Identifier: MIT
// Academic Grade - AOXCMainEngine Access Control Interface Standard
pragma solidity 0.8.33;

import {IMonitoringHub} from "./api29_IMonitoringHub_170226.sol";

/**
 * @title IAoxcAccessCoordinator
 * @author AOXCDAO Institutional Engineering
 * @notice Interface defining the core authority and emergency signaling of the AOXCMainEngine Fleet.
 * @dev This bridge allows modular components (CircuitBreaker, ScorchedEarth, etc.) to
 * communicate with the central nervous system.
 */
interface IAoxcAccessCoordinator {
    // --- Events (Institutional Audit Trail) ---

    /**
     * @notice Emitted when a global lockdown is triggered.
     * @param initiator The address that initiated the lockdown.
     */
    event GlobalLockdownTriggered(address indexed initiator);

    /**
     * @notice Emitted when a global lockdown is released.
     * @param initiator The address that released the lockdown.
     */
    event GlobalLockdownReleased(address indexed initiator);

    /**
     * @notice Emitted when a sector status is updated.
     * @param sectorId The unique identifier of the sector.
     * @param status The new operational status of the sector.
     */
    event SectorStatusUpdated(bytes32 indexed sectorId, bool indexed status);

    // --- Access Verification ---

    /**
     * @notice Verifies if an account has ultimate sovereign power.
     * @param account The address to verify.
     * @return bool True if the account has sovereign permissions.
     */
    function hasSovereignPower(address account) external view returns (bool);

    /**
     * @notice Checks if a specific operation is allowed for a given role and account.
     * @param role The RBAC role identifier.
     * @param account The address to check.
     * @return bool True if the operation is authorized.
     */
    function isOperationAllowed(bytes32 role, address account) external view returns (bool);

    // --- Emergency Signaling ---

    /**
     * @notice Global signal for Scorched Earth protocols.
     * @dev High-privilege call to lock all assets and operations.
     */
    function triggerGlobalLockdown() external;

    /**
     * @notice Releases system-wide pause.
     * @dev Restores normal protocol functionality.
     */
    function releaseGlobalLockdown() external;

    /**
     * @notice Standard emergency pause for automated sentinel response.
     * @param reason String description of the emergency event.
     */
    function triggerEmergencyPause(string calldata reason) external;

    // --- Monitoring & Infrastructure ---

    /**
     * @notice Returns the active Monitoring Hub for forensic logging.
     * @return IMonitoringHub The interface of the current monitoring system.
     */
    function monitoringHub() external view returns (IMonitoringHub);

    /**
     * @notice Manages individual module/sector access states.
     * @param sectorId The unique identifier for the sector or module.
     * @param status The new operational status (true for active).
     */
    function setSectorStatus(bytes32 sectorId, bool status) external;
}
