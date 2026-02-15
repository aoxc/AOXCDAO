// SPDX-License-Identifier: MIT
// Academic Grade - AOXC Ultimate Pro Standard
pragma solidity 0.8.33;

import { IMonitoringHub } from "../interfaces/IMonitoringHub.sol";

/**
 * @title ForensicPulse
 * @author AOXC Core Engineering
 * @notice Ensures telemetry integrity across all forensic channels.
 * @dev Reverts transactions if forensic logging fails, preventing "silent" attacks.
 * Compliant with 2026 strict linting rules.
 */
contract ForensicPulse {
    // --- Immutable State Variables ---

    /**
     * @notice The central hub for forensic data collection.
     * @dev Marked as immutable for gas efficiency and naming convention compliance.
     */
    IMonitoringHub public immutable MONITORING_HUB;

    // --- Custom Errors ---
    error AOXC__Pulse_TelemetryOffline();

    // --- Constructor ---
    constructor(address _hub) {
        MONITORING_HUB = IMonitoringHub(_hub);
    }

    // --- External Functions ---

    /**
     * @notice Verification gate for high-stakes operations.
     * @dev This should be called inside critical functions like 'bridgeAsset' or 'updatePolicy'.
     * @param log The forensic log data to be transmitted to the hub.
     */
    function requirePulse(IMonitoringHub.ForensicLog calldata log) external {
        // Attempt to record the log. If the hub fails or runs out of gas, the entire transaction reverts.
        try MONITORING_HUB.logForensic(log) {
            // Heartbeat/Pulse successful
        } catch {
            revert AOXC__Pulse_TelemetryOffline();
        }
    }
}
