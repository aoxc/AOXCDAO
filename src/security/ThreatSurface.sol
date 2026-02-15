// SPDX-License-Identifier: MIT
pragma solidity 0.8.33;

import { Initializable } from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import { AccessControlUpgradeable } from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import { PausableUpgradeable } from "@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol";
import { UUPSUpgradeable } from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

import { IMonitoringHub } from "../interfaces/IMonitoringHub.sol";
import { IThreatSurface } from "../interfaces/IThreatSurface.sol";
import { IReputationManager } from "../interfaces/IReputationManager.sol";
import { AOXCBaseReporter } from "../monitoring/AOXCBaseReporter.sol";
import { AOXCErrors } from "../libraries/AOXCErrors.sol";

/**
 * @title AOXCThreatSurface
 * @author AOXC Core Engineering
 * @notice Enterprise-grade threat detection and pattern analysis module.
 * @dev Re-engineered for Akdeniz V2 with wrapped modifiers and high-fidelity forensic logging.
 * Compliance: OpenZeppelin 5.5.x, Solidity 0.8.33.
 */
contract AOXCThreatSurface is
    IThreatSurface,
    Initializable,
    AccessControlUpgradeable,
    PausableUpgradeable,
    UUPSUpgradeable,
    AOXCBaseReporter
{
    // --- State Structures ---

    struct Threat {
        string description;
        IThreatSurface.RiskLevel risk;
        uint256 timestamp;
        address reporter;
    }

    // --- Access Control Roles ---
    bytes32 public constant SECURITY_ROLE = keccak256("AOXC_SECURITY_ROLE");
    bytes32 public constant UPGRADER_ROLE = keccak256("AOXC_UPGRADER_ROLE");

    // --- State Variables ---
    IReputationManager public reputationManager;

    Threat[] private _threats;
    bytes32[] private _allRegisteredPatterns;

    mapping(bytes32 => bool) private _flaggedPatterns;
    mapping(bytes32 => uint256) private _patternArrayIndex;
    mapping(address => uint256) public addressRiskScore;

    // --- Local Reentrancy Guard State ---
    uint256 private _status;
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    // --- Events ---
    event ThreatLogged(
        uint256 indexed index,
        IThreatSurface.RiskLevel risk,
        bytes32 indexed patternId
    );
    event PatternStatusUpdated(bytes32 indexed patternId, bool flagged);

    // --- Wrapped Modifiers (Forge Lint Fix: unwrapped-modifier-logic) ---

    /**
     * @dev Optimized Reentrancy Guard wrapping to satisfy enterprise lint rules.
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
     * @notice Bootstrap the security layer with core dependencies.
     * @param admin Initial administrator and security manager.
     * @param _monitoringHub Centralized forensic logging hub.
     * @param _reputationManager Reputation management system address.
     */
    function initialize(
        address admin,
        address _monitoringHub,
        address _reputationManager
    ) external initializer {
        if (
            admin == address(0) || _monitoringHub == address(0) || _reputationManager == address(0)
        ) {
            revert AOXCErrors.ZeroAddressDetected();
        }

        __AccessControl_init();
        __Pausable_init();

        _status = _NOT_ENTERED;

        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(SECURITY_ROLE, admin);
        _grantRole(UPGRADER_ROLE, admin);

        _setMonitoringHub(_monitoringHub);
        reputationManager = IReputationManager(_reputationManager);

        _performForensicLog(
            IMonitoringHub.Severity.INFO,
            "INITIALIZE",
            "Threat Consensus Layer Online",
            address(0),
            0,
            ""
        );
    }

    // --- Core Logic ---

    /**
     * @notice Logs a detected threat and updates suspect risk scoring.
     * @param description Narrative of the threat incident.
     * @param risk Severity level defined by IThreatSurface.
     * @param patternId Unique identifier for the threat signature.
     * @param suspect Address associated with the potential malicious activity.
     */
    function logThreat(
        string calldata description,
        IThreatSurface.RiskLevel risk,
        bytes32 patternId,
        address suspect
    ) external onlyRole(SECURITY_ROLE) whenNotPaused nonReentrant {
        if (bytes(description).length == 0) {
            revert AOXCErrors.InvalidConfiguration();
        }

        _threats.push(
            Threat({
                description: description,
                risk: risk,
                timestamp: block.timestamp,
                reporter: msg.sender
            })
        );

        uint8 riskScore = 0;

        // Auto-flag patterns and score suspects for High/Critical risks
        if (risk == IThreatSurface.RiskLevel.CRITICAL || risk == IThreatSurface.RiskLevel.HIGH) {
            if (!_flaggedPatterns[patternId]) {
                _patternArrayIndex[patternId] = _allRegisteredPatterns.length;
                _allRegisteredPatterns.push(patternId);
                _flaggedPatterns[patternId] = true;
            }
            if (suspect != address(0)) {
                addressRiskScore[suspect] = 100;
                riskScore = 100;
            }
        }

        // Reputation update (Non-blocking)
        try reputationManager.processAction(msg.sender, keccak256("SECURITY_CHECK")) {} catch {}

        IMonitoringHub.Severity severity = (risk == IThreatSurface.RiskLevel.CRITICAL)
            ? IMonitoringHub.Severity.CRITICAL
            : IMonitoringHub.Severity.WARNING;

        _performForensicLog(
            severity,
            "THREAT_REPORTED",
            description,
            suspect,
            riskScore,
            abi.encode(patternId, risk)
        );

        emit ThreatLogged(_threats.length - 1, risk, patternId);
    }

    /**
     * @notice Registers a new known threat signature.
     */
    function registerThreatPattern(bytes32 patternId) external override onlyRole(SECURITY_ROLE) {
        if (_flaggedPatterns[patternId]) revert AOXCErrors.SecurityAssumptionViolated();

        _patternArrayIndex[patternId] = _allRegisteredPatterns.length;
        _allRegisteredPatterns.push(patternId);
        _flaggedPatterns[patternId] = true;

        _performForensicLog(
            IMonitoringHub.Severity.WARNING,
            "PATTERN_REG",
            "Signature catalog updated",
            address(0),
            40,
            abi.encode(patternId)
        );

        emit PatternStatusUpdated(patternId, true);
    }

    /**
     * @notice Removes a signature from the active threat catalog.
     */
    function removeThreatPattern(bytes32 patternId) external override onlyRole(SECURITY_ROLE) {
        if (!_flaggedPatterns[patternId]) revert AOXCErrors.InvalidConfiguration();

        uint256 indexToRemove = _patternArrayIndex[patternId];
        uint256 lastIndex = _allRegisteredPatterns.length - 1;

        if (indexToRemove != lastIndex) {
            bytes32 lastPattern = _allRegisteredPatterns[lastIndex];
            _allRegisteredPatterns[indexToRemove] = lastPattern;
            _patternArrayIndex[lastPattern] = indexToRemove;
        }

        _allRegisteredPatterns.pop();
        delete _flaggedPatterns[patternId];
        delete _patternArrayIndex[patternId];

        _performForensicLog(
            IMonitoringHub.Severity.INFO,
            "PATTERN_REM",
            "Signature removed from catalog",
            address(0),
            10,
            abi.encode(patternId)
        );

        emit PatternStatusUpdated(patternId, false);
    }

    // --- View Functions ---

    function getPatternCount() external view override returns (uint256) {
        return _allRegisteredPatterns.length;
    }

    function getRegisteredPatterns() external view override returns (bytes32[] memory) {
        return _allRegisteredPatterns;
    }

    function isThreatDetected(bytes32 patternId) external view override returns (bool) {
        return _flaggedPatterns[patternId];
    }

    // --- Internal Infrastructure ---

    function _authorizeUpgrade(
        address newImplementation
    ) internal override onlyRole(UPGRADER_ROLE) {
        if (newImplementation == address(0)) {
            revert AOXCErrors.ZeroAddressDetected();
        }

        _performForensicLog(
            IMonitoringHub.Severity.CRITICAL,
            "SURFACE_UPGRADE",
            "Threat Surface logic migration authorized",
            newImplementation,
            100,
            ""
        );
    }

    /**
     * @dev Reserved storage gap for upgradeability protection (50 slots).
     */
    uint256[43] private _gap;
}
