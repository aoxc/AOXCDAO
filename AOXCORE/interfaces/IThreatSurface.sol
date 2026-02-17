// SPDX-License-Identifier: MIT
pragma solidity 0.8.33;

/**
 * @title  IThreatSurface
 * @notice Interface for formalizing attack vectors and proactive defense telemetry.
 * @dev    AOXC Ultimate Protocol Standard.
 */
interface IThreatSurface {
    // --- SECTION: ENUMS ---

    /**
     * @notice Severity levels for detected anomalies.
     * @dev Moved inside interface to resolve Identifier Not Found error in implementation.
     */
    enum RiskLevel {
        LOW,
        MEDIUM,
        HIGH,
        CRITICAL
    }

    // --- SECTION: EVENTS ---

    event ThreatPatternRegistered(bytes32 indexed patternId, uint256 timestamp);
    event ThreatPatternRemoved(bytes32 indexed patternId, uint256 timestamp);
    event ThreatDetected(bytes32 indexed patternId, address indexed evaluator, uint256 timestamp);

    // --- SECTION: CORE VIEW FUNCTIONS ---

    function isThreatDetected(bytes32 patternId) external view returns (bool detected);
    function getRegisteredPatterns() external view returns (bytes32[] memory patterns);
    function getPatternCount() external view returns (uint256 count);

    // --- SECTION: ADMIN OPERATIONS ---

    function registerThreatPattern(bytes32 patternId) external;
    function removeThreatPattern(bytes32 patternId) external;
}
