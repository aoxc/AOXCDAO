// SPDX-License-Identifier: MIT
pragma solidity 0.8.33;

import { AOXCBaseReporter } from "../monitoring/AOXCBaseReporter.sol";
import { IMonitoringHub } from "../interfaces/IMonitoringHub.sol";
import { AOXCErrors } from "../libraries/AOXCErrors.sol";
import { AOXCConstants } from "../libraries/AOXCConstants.sol";
import { AOXCAccessCoordinator } from "../core/AOXCAccessCoordinator.sol";
import {
    AccessControlUpgradeable
} from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import { Initializable } from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

/**
 * @title AOXCCircuitBreaker
 * @author AOXC Core Engineering
 * @notice Enterprise-grade circuit breaker to prevent bank runs and flash-loan exploits.
 * @dev Re-engineered for Akdeniz V2. Integrated with Global Coordinator for atomic system-wide protection.
 */
contract AOXCCircuitBreaker is Initializable, AccessControlUpgradeable, AOXCBaseReporter {
    // --- State Variables ---
    AOXCAccessCoordinator public coordinator;

    uint256 public volumeThreshold;
    uint256 public lastResetTime;
    uint256 public currentWindowVolume;
    uint256 public windowDuration;

    // --- Independent Reentrancy Guard State ---
    uint256 private _status;
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    // --- Events ---
    event ThresholdUpdated(uint256 oldThreshold, uint256 newThreshold);
    event CircuitBreakerReset(uint256 timestamp);
    event EmergencyBreakerTriggered(uint256 totalVolume, string reason);

    // --- Wrapped Modifiers (Forge Lint Fix: unwrapped-modifier-logic) ---

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
     * @notice Initializes the Circuit Breaker logic and monitoring link.
     */
    function initialize(
        address admin,
        address _monitoringHub,
        address _coordinator,
        uint256 _initialThreshold
    ) external initializer {
        if (admin == address(0) || _monitoringHub == address(0) || _coordinator == address(0)) {
            revert AOXCErrors.ZeroAddressDetected();
        }

        __AccessControl_init();

        _status = _NOT_ENTERED;
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(AOXCConstants.ADMIN_ROLE, admin); // Use Global Constant Role

        _setMonitoringHub(_monitoringHub);
        coordinator = AOXCAccessCoordinator(_coordinator);

        volumeThreshold = _initialThreshold;
        windowDuration = 1 hours;
        lastResetTime = block.timestamp;

        _performForensicLog(
            IMonitoringHub.Severity.INFO,
            "LIFECYCLE",
            "Circuit Breaker Guard online",
            address(0),
            0,
            ""
        );
    }

    /**
     * @notice Validates transaction volume against the hourly threshold.
     * @dev If threshold is breached, it triggers a global system pause via Coordinator.
     */
    function checkVolume(uint256 amount) external nonReentrant {
        // Optimized Window Reset Logic
        uint256 _lastReset = lastResetTime;
        if (block.timestamp > _lastReset + windowDuration) {
            currentWindowVolume = 0;
            lastResetTime = block.timestamp;
            emit CircuitBreakerReset(block.timestamp);
        }

        uint256 newVolume = currentWindowVolume + amount;
        currentWindowVolume = newVolume;

        // Threshold Breach Logic
        if (newVolume > volumeThreshold) {
            _performForensicLog(
                IMonitoringHub.Severity.CRITICAL,
                "CIRCUIT_BREAKER",
                "Volume threshold breach detected",
                msg.sender,
                100,
                abi.encode(newVolume, volumeThreshold)
            );

            // ULTIMATE ACTION: Trigger global pause
            try coordinator.triggerEmergencyPause("CB_VOLUME_BREACH") {
                emit EmergencyBreakerTriggered(newVolume, "GLOBAL_PAUSE_EXECUTED");
            } catch {
                // Fallback if coordinator call fails, we still must revert the tx
            }

            revert AOXCErrors.ThresholdExceeded();
        }
    }

    /**
     * @notice Updates the maximum volume threshold.
     */
    function updateThreshold(uint256 newThreshold) external onlyRole(AOXCConstants.ADMIN_ROLE) {
        uint256 oldThreshold = volumeThreshold;
        volumeThreshold = newThreshold;

        _performForensicLog(
            IMonitoringHub.Severity.WARNING,
            "CONFIG",
            "Threshold adjusted",
            address(0),
            20,
            abi.encode(oldThreshold, newThreshold)
        );

        emit ThresholdUpdated(oldThreshold, newThreshold);
    }

    /**
     * @notice Manually resets the volume window.
     */
    function manualReset() external onlyRole(AOXCConstants.ADMIN_ROLE) {
        currentWindowVolume = 0;
        lastResetTime = block.timestamp;

        _performForensicLog(
            IMonitoringHub.Severity.WARNING,
            "MAINTENANCE",
            "Volume window reset",
            msg.sender,
            10,
            ""
        );

        emit CircuitBreakerReset(block.timestamp);
    }

    /**
     * @dev Reserved storage gap. (Coordinator: 1 slot, state: 4 slots -> 5 slots used)
     */
    uint256[45] private _gap;
}
