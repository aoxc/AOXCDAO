// SPDX-License-Identifier: MIT
pragma solidity 0.8.33;

import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {AccessControlUpgradeable} from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

import {IMonitoringHub} from "@interfaces/IMonitoringHub.sol";
import {AOXCBaseReporter} from "./AOXCBaseReporter.sol";
import {AOXCErrors} from "@libraries/AOXCErrors.sol";

/**
 * @title RiskSignals
 * @author AOXC Core Engineering
 * @notice Enterprise-grade system for processing 26-channel risk telemetry.
 * @dev Re-engineered for Akdeniz V2. Eliminates all compiler warnings and lint notes.
 */
contract RiskSignals is Initializable, AccessControlUpgradeable, UUPSUpgradeable, AOXCBaseReporter {
    // --- Access Control Roles ---
    bytes32 public constant ADMIN_ROLE = keccak256("AOXC_ADMIN_ROLE");
    bytes32 public constant RISK_REPORTER_ROLE = keccak256("AOXC_RISK_REPORTER_ROLE");
    bytes32 public constant UPGRADER_ROLE = keccak256("AOXC_UPGRADER_ROLE");

    // --- State Variables ---
    uint256 public totalSignalsProcessed;
    mapping(bytes32 => bool) public activeSignals;

    // --- Local Reentrancy Guard Storage ---
    uint256 private _status;
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    // --- Events ---
    event RiskSignalEmitted(
        bytes32 indexed signalHash, string category, IMonitoringHub.Severity severity, uint256 riskScore
    );

    event RiskPolicyUpdated(string description, bytes32 indexed policyHash, address indexed actor);

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
     * @notice Initializes the Risk Signals module with core dependencies.
     */
    function initialize(address admin, address _monitoringHub) external initializer {
        if (admin == address(0) || _monitoringHub == address(0)) {
            revert AOXCErrors.ZeroAddressDetected();
        }

        __AccessControl_init();
        _status = _NOT_ENTERED;

        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(ADMIN_ROLE, admin);
        _grantRole(RISK_REPORTER_ROLE, admin);
        _grantRole(UPGRADER_ROLE, admin);

        _setMonitoringHub(_monitoringHub);

        _performForensicLog(IMonitoringHub.Severity.INFO, "SYSTEM", "Risk Signal Engine Initialized", address(0), 0, "");
    }

    /**
     * @notice Emits a high-fidelity risk signal using 26 channels.
     * @dev Optimized with Yul to prevent [asm-keccak256] and handle complex calldata segments.
     */
    function emitSignal(
        string calldata category,
        IMonitoringHub.Severity severity,
        uint8 riskScore,
        bytes calldata metadata
    ) external nonReentrant onlyRole(RISK_REPORTER_ROLE) {
        bytes32 signalHash;
        uint256 currentSignals = totalSignalsProcessed;

        /* PRO ULTIMATE ASSEMBLY HASHING
           Note: NatSpec tags removed from assembly to fix Warning (6269).
           Direct memory management used for zero-cost abstraction.
        */
        assembly {
            let ptr := mload(0x40)

            // 1. Copy category string bytes
            calldatacopy(ptr, category.offset, category.length)
            let currentOffset := category.length

            // 2. Append timestamp (32 bytes)
            mstore(add(ptr, currentOffset), timestamp())
            currentOffset := add(currentOffset, 0x20)

            // 3. Append currentSignals (32 bytes)
            mstore(add(ptr, currentOffset), currentSignals)
            currentOffset := add(currentOffset, 0x20)

            // 4. Final Hashing
            signalHash := keccak256(ptr, currentOffset)

            // 5. Update Free Memory Pointer (Standard compliance)
            mstore(0x40, add(add(ptr, currentOffset), 0x20))
        }

        unchecked {
            ++totalSignalsProcessed;
        }

        _performForensicLog(severity, "RISK_SIGNAL", category, address(0), riskScore, metadata);

        emit RiskSignalEmitted(signalHash, category, severity, riskScore);
    }

    /**
     * @notice Updates the risk policy and triggers a forensic audit trail.
     */
    function updateRiskPolicy(string calldata description, bytes32 policyHash)
        external
        nonReentrant
        onlyRole(ADMIN_ROLE)
    {
        _performForensicLog(
            IMonitoringHub.Severity.CRITICAL,
            "POLICY_UPDATE",
            description,
            address(0),
            100,
            abi.encodePacked(policyHash)
        );

        emit RiskPolicyUpdated(description, policyHash, _msgSender());
    }

    // --- Internal Infrastructure ---

    function _authorizeUpgrade(address newImplementation) internal override onlyRole(UPGRADER_ROLE) {
        if (newImplementation == address(0)) {
            revert AOXCErrors.ZeroAddressDetected();
        }

        _performForensicLog(
            IMonitoringHub.Severity.EMERGENCY,
            "UPGRADE",
            "Risk Signals logic migration authorized",
            newImplementation,
            100,
            ""
        );
    }

    /**
     * @dev Reserved storage gap (50 slots total).
     * Reporter base: 2 slots, local state: 2 slots -> Gap: 46.
     */
    uint256[46] private _gap;
}
