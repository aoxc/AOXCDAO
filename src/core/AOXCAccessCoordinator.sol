// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts v5.5.0
// Academic Grade - AOXC Ultimate Pro Standard
pragma solidity 0.8.33;

import { AccessControlEnumerable } from "@openzeppelin/contracts/access/extensions/AccessControlEnumerable.sol";
import { Pausable } from "@openzeppelin/contracts/utils/Pausable.sol";
import { AOXCConstants } from "@libraries/AOXCConstants.sol";

/**
 * @title AOXCAccessCoordinator
 * @author AOXC Core Engineering
 * @notice The central nervous system of AOXC V2. Coordinates roles and emergency states.
 * @dev Acts as the definitive source of truth for permissions and protocol-wide circuit breaking.
 */
contract AOXCAccessCoordinator is AccessControlEnumerable, Pausable {
    // --- Custom Errors ---

    /**
     * @dev Error thrown when an account lacks the required role.
     * @param account The address that attempted the unauthorized action.
     * @param neededRole The specific role required for the action.
     */
    error AOXCUnauthorizedAccount(address account, bytes32 neededRole);

    // --- System States ---

    enum SystemStatus {
        ACTIVE,
        DEGRADED,
        EMERGENCY_PAUSE,
        TERMINATED
    }
    SystemStatus public currentStatus;

    // --- Events ---

    event SystemStatusChanged(
        SystemStatus indexed previous,
        SystemStatus indexed current,
        address indexed actor
    );
    event EmergencyActionTriggered(string reason, address indexed sentinel);

    /**
     * @param rootAdmin The initial super-admin address (usually a DAO or Multisig).
     */
    constructor(address rootAdmin) {
        _grantRole(AOXCConstants.ADMIN_ROLE, rootAdmin);
        _setRoleAdmin(AOXCConstants.UPGRADER_ROLE, AOXCConstants.ADMIN_ROLE);
        _setRoleAdmin(AOXCConstants.SENTINEL_ROLE, AOXCConstants.ADMIN_ROLE);

        currentStatus = SystemStatus.ACTIVE;
    }

    // --- Emergency Logic ---

    /**
     * @notice Triggers a protocol-wide emergency pause.
     * @dev Accessible by SENTINEL_ROLE for rapid response or ADMIN_ROLE.
     * @param reason The descriptive reason for the emergency action.
     */
    function triggerEmergencyPause(string calldata reason) external {
        // Corrected revert logic using Custom Error for gas efficiency and lint compliance
        if (
            !hasRole(AOXCConstants.SENTINEL_ROLE, msg.sender) &&
            !hasRole(AOXCConstants.ADMIN_ROLE, msg.sender)
        ) {
            revert AOXCUnauthorizedAccount(msg.sender, AOXCConstants.SENTINEL_ROLE);
        }

        _pause();
        currentStatus = SystemStatus.EMERGENCY_PAUSE;

        emit EmergencyActionTriggered(reason, msg.sender);
        emit SystemStatusChanged(SystemStatus.ACTIVE, SystemStatus.EMERGENCY_PAUSE, msg.sender);
    }

    /**
     * @notice Resumes the protocol after safety verification.
     * @dev Strictly restricted to ADMIN_ROLE.
     */
    function resumeProtocol() external onlyRole(AOXCConstants.ADMIN_ROLE) {
        _unpause();
        currentStatus = SystemStatus.ACTIVE;
        emit SystemStatusChanged(SystemStatus.EMERGENCY_PAUSE, SystemStatus.ACTIVE, msg.sender);
    }

    // --- Authorization View Functions ---

    /**
     * @notice Global check to see if an operation is allowed under current system status.
     * @param role The role identifier being checked.
     * @param account The address of the user or contract.
     * @return bool True if the operation is permitted.
     */
    function isOperationAllowed(bytes32 role, address account) external view returns (bool) {
        if (currentStatus == SystemStatus.TERMINATED) return false;

        // If paused, only ADMIN_ROLE can bypass the pause state
        if (paused() && role != AOXCConstants.ADMIN_ROLE) return false;

        return hasRole(role, account);
    }

    /**
     * @notice Permanently shuts down the protocol (Nuclear Option).
     * @dev Irreversible action. Use with extreme caution.
     */
    function terminateProtocol() external onlyRole(AOXCConstants.ADMIN_ROLE) {
        currentStatus = SystemStatus.TERMINATED;
        _pause();
        // Additional forensic logging or final state locking can be implemented here
    }
}
