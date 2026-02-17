// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts v5.5.0
// Academic Grade - AOXC Ultimate Pro Standard
pragma solidity 0.8.33;

import {
    AccessControlEnumerable
} from "@openzeppelin/contracts/access/extensions/AccessControlEnumerable.sol";
import { Pausable } from "@openzeppelin/contracts/utils/Pausable.sol";
import { AOXCConstants } from "@libraries/AOXCConstants.sol";
import { IAOXCAccessCoordinator } from "@interfaces/IAOXCAccessCoordinator.sol";
import { IMonitoringHub } from "@interfaces/IMonitoringHub.sol";

/**
 * @title AOXCAccessCoordinator
 * @author AOXC Core Engineering
 * @notice The central nervous system of AOXC V2. Coordinates roles, forensic monitoring, and emergency states.
 * @dev Acts as the definitive source of truth for permissions and protocol-wide circuit breaking.
 */
contract AOXCAccessCoordinator is IAOXCAccessCoordinator, AccessControlEnumerable, Pausable {
    // --- Custom Errors ---
    error AOXCUnauthorizedAccount(address account, bytes32 neededRole);
    error AlreadyInState(SystemStatus status);

    // --- System States ---
    enum SystemStatus {
        ACTIVE,
        DEGRADED,
        EMERGENCY_PAUSE,
        TERMINATED
    }
    SystemStatus public currentStatus;

    // --- State Variables ---
    IMonitoringHub private _monitoringHub;
    mapping(bytes32 => bool) public sectorStatus;

    // --- Sovereign Authority ---
    address public immutable SOVEREIGN_MULTISIG = 0x20c0DD8B6559912acfAC2ce061B8d5b19Db8CA84;

    // --- Events ---
    event SystemStatusChanged(
        SystemStatus indexed previous, SystemStatus indexed current, address indexed actor
    );
    event EmergencyActionTriggered(string reason, address indexed sentinel);
    event SectorStatusUpdated(bytes32 indexed sectorId, bool status);
    event MonitoringHubUpdated(address indexed newHub);

    /**
     * @param rootAdmin The initial super-admin address.
     * @param initialHub The initial Monitoring Hub address.
     */
    constructor(address rootAdmin, address initialHub) {
        _grantRole(AOXCConstants.ADMIN_ROLE, rootAdmin);
        _grantRole(AOXCConstants.ADMIN_ROLE, SOVEREIGN_MULTISIG);

        _setRoleAdmin(AOXCConstants.UPGRADER_ROLE, AOXCConstants.ADMIN_ROLE);
        _setRoleAdmin(AOXCConstants.SENTINEL_ROLE, AOXCConstants.ADMIN_ROLE);
        _setRoleAdmin(AOXCConstants.AUDITOR_ROLE, AOXCConstants.ADMIN_ROLE);

        _monitoringHub = IMonitoringHub(initialHub);
        currentStatus = SystemStatus.ACTIVE;
    }

    /* ————————————————————————————————————————————————————————————————————————
       IAOXCAccessCoordinator IMPLEMENTATION
       ———————————————————————————————————————————————————————————————————————— */

    /**
     * @notice Returns the active Monitoring Hub for forensic logging.
     */
    function monitoringHub() external view override returns (IMonitoringHub) {
        return _monitoringHub;
    }

    /**
     * @notice Enables or disables a specific operational sector (e.g., Andromeda, Aquila).
     * @param sectorId keccak256 hash of the sector identifier.
     * @param status True for active, false for frozen.
     */
    function setSectorStatus(bytes32 sectorId, bool status) external override {
        if (!hasRole(AOXCConstants.ADMIN_ROLE, msg.sender) && msg.sender != SOVEREIGN_MULTISIG) {
            revert AOXCUnauthorizedAccount(msg.sender, AOXCConstants.ADMIN_ROLE);
        }
        sectorStatus[sectorId] = status;
        emit SectorStatusUpdated(sectorId, status);
    }

    /**
     * @notice Check if an account has Sovereign level powers.
     * @dev Core verification for AOXCScorchedEarth.
     */
    function hasSovereignPower(address account) external view override returns (bool) {
        return account == SOVEREIGN_MULTISIG || hasRole(AOXCConstants.ADMIN_ROLE, account);
    }

    /**
     * @notice Global trigger for Scorched Earth and Emergency Pause.
     * @dev Satisfies requirements for Plan C activation.
     */
    function triggerGlobalLockdown() external override {
        if (!hasRole(AOXCConstants.SENTINEL_ROLE, msg.sender) && msg.sender != SOVEREIGN_MULTISIG) {
            revert AOXCUnauthorizedAccount(msg.sender, AOXCConstants.SENTINEL_ROLE);
        }

        if (currentStatus != SystemStatus.EMERGENCY_PAUSE) {
            _pause();
            currentStatus = SystemStatus.EMERGENCY_PAUSE;
            emit EmergencyActionTriggered("GLOBAL_LOCKDOWN_INITIATED", msg.sender);
        }
    }

    /**
     * @notice Standard emergency pause for automated sentinel response.
     * @dev Corrects the 'abstract' error by implementing the interface requirement.
     */
    function triggerEmergencyPause(string calldata reason) external override {
        if (
            !hasRole(AOXCConstants.SENTINEL_ROLE, msg.sender)
                && !hasRole(AOXCConstants.ADMIN_ROLE, msg.sender)
                && msg.sender != SOVEREIGN_MULTISIG
        ) {
            revert AOXCUnauthorizedAccount(msg.sender, AOXCConstants.SENTINEL_ROLE);
        }

        _pause();
        SystemStatus prev = currentStatus;
        currentStatus = SystemStatus.EMERGENCY_PAUSE;

        emit EmergencyActionTriggered(reason, msg.sender);
        emit SystemStatusChanged(prev, SystemStatus.EMERGENCY_PAUSE, msg.sender);
    }

    /**
     * @notice Releases the global lockdown and restores flow.
     */
    function releaseGlobalLockdown() external override {
        if (msg.sender != SOVEREIGN_MULTISIG && !hasRole(AOXCConstants.ADMIN_ROLE, msg.sender)) {
            revert AOXCUnauthorizedAccount(msg.sender, AOXCConstants.ADMIN_ROLE);
        }
        _unpause();
        currentStatus = SystemStatus.ACTIVE;
    }

    /**
     * @notice Checks if an operation is permitted under current system state.
     */
    function isOperationAllowed(bytes32 role, address account)
        external
        view
        override
        returns (bool)
    {
        if (currentStatus == SystemStatus.TERMINATED) return false;
        if (paused() && role != AOXCConstants.ADMIN_ROLE) return false;
        return hasRole(role, account);
    }

    /* ————————————————————————————————————————————————————————————————————————
       MANAGEMENT FUNCTIONS
       ———————————————————————————————————————————————————————————————————————— */

    /**
     * @notice Updates the forensic monitoring hub.
     */
    function updateMonitoringHub(address newHub) external onlyRole(AOXCConstants.ADMIN_ROLE) {
        if (newHub == address(0)) revert("Zero Address");
        _monitoringHub = IMonitoringHub(newHub);
        emit MonitoringHubUpdated(newHub);
    }

    /**
     * @notice Irreversible termination of the protocol logic.
     */
    function terminateProtocol() external onlyRole(AOXCConstants.ADMIN_ROLE) {
        currentStatus = SystemStatus.TERMINATED;
        _pause();
        emit SystemStatusChanged(SystemStatus.ACTIVE, SystemStatus.TERMINATED, msg.sender);
    }
}
