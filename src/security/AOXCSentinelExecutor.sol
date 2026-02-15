// SPDX-License-Identifier: MIT
pragma solidity 0.8.33;

import { IMonitoringHub } from "../interfaces/IMonitoringHub.sol";
import { IEmergencyPauseGuard } from "../interfaces/IEmergencyPauseGuard.sol";
import { AccessControlUpgradeable } from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import { AOXCErrors } from "../libraries/AOXCErrors.sol";
import { Initializable } from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

/**
 * @title AOXCSentinelExecutor
 * @author AOXC Core Engineering
 * @notice Automated sentinel that monitors forensic data and triggers circuit breakers.
 * @dev Updated to match interface (0-arg pause) and fixed lint warnings.
 */
contract AOXCSentinelExecutor is Initializable, AccessControlUpgradeable {
    // --- Roles ---
    bytes32 public constant SENTINEL_ROLE = keccak256("SENTINEL_ROLE");

    // --- State Variables ---
    IEmergencyPauseGuard public pauseGuard;
    uint8 public autoPauseThreshold;

    // --- Independent Reentrancy Guard State ---
    uint256 private _status;
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    // --- Events ---
    event SentinelActionExecuted(uint8 riskScore, IMonitoringHub.Severity severity);
    event ThresholdUpdated(uint8 oldThreshold, uint8 newThreshold);

    // --- Wrapped Modifiers (Forge Lint Fix: unwrapped-modifier-logic) ---

    /**
     * @dev Optimized Reentrancy Guard logic to satisfy enterprise linting rules.
     */
    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() internal {
        if (_status == _ENTERED) revert("ReentrancyGuard: reentrant call");
        _status = _ENTERED;
    }

    function _nonReentrantAfter() internal {
        _status = _NOT_ENTERED;
    }

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    /**
     * @notice Initializes the Sentinel Executor with administrative and pause controls.
     */
    function initialize(address admin, address _pauseGuard) external initializer {
        if (admin == address(0) || _pauseGuard == address(0)) {
            revert AOXCErrors.ZeroAddressDetected();
        }

        __AccessControl_init();

        _status = _NOT_ENTERED;
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(SENTINEL_ROLE, admin);

        pauseGuard = IEmergencyPauseGuard(_pauseGuard);
        autoPauseThreshold = 95;
    }

    /**
     * @notice Validates forensic logs and triggers protocol pause if risk exceeds threshold.
     * @dev Synchronized with IEmergencyPauseGuard to use 0-argument pause().
     */
    function validateAndExecute(
        IMonitoringHub.ForensicLog calldata log
    ) external onlyRole(SENTINEL_ROLE) nonReentrant {
        // Automation Logic: Triggers if risk score is high and severity is CRITICAL
        if (
            log.riskScore >= autoPauseThreshold && log.severity == IMonitoringHub.Severity.CRITICAL
        ) {
            emit SentinelActionExecuted(log.riskScore, log.severity);

            // Interface matching: Removing string argument to solve Error (6160)
            pauseGuard.pause();
        }
    }

    /**
     * @notice Updates the automatic pause trigger threshold.
     */
    function updateThreshold(uint8 newThreshold) external onlyRole(DEFAULT_ADMIN_ROLE) {
        if (newThreshold > 100) revert AOXCErrors.InvalidConfiguration();

        uint8 oldThreshold = autoPauseThreshold;
        autoPauseThreshold = newThreshold;

        emit ThresholdUpdated(oldThreshold, newThreshold);
    }

    /**
     * @dev Reserved storage gap for future upgradeability protection.
     */
    uint256[48] private _gap;
}
