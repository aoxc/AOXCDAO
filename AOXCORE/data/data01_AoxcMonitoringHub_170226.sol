// SPDX-License-Identifier: MIT
pragma solidity 0.8.33;

import {Initializable} from "@openzeppelin-upgradeable/proxy/utils/Initializable.sol";
import {AccessControlUpgradeable} from "@openzeppelin-upgradeable/access/AccessControlUpgradeable.sol";
import {UUPSUpgradeable} from "@openzeppelin-upgradeable/proxy/utils/UUPSUpgradeable.sol";

/**
 * @dev V5 Compliance: Standard ReentrancyGuard is used as it is stateless in V5.
 */
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

import {IMonitoringHub} from "@api/api29_IMonitoringHub_170226.sol";
import {AOXCErrors} from "@libraries/core08_AoxcErrorDefinitions_170226.sol";

/**
 * @title AOXCMonitoringHub
 * @author AOXCMainEngine Core Engineering
 * @notice Centralized hyper-forensic hub for the AOXCMainEngine ecosystem.
 * @dev Implements the 26-channel data schema and integrated risk filtering.
 */
contract AOXCMonitoringHub is
    IMonitoringHub,
    Initializable,
    AccessControlUpgradeable,
    UUPSUpgradeable,
    ReentrancyGuard
{
    // --- Access Control Roles ---
    bytes32 public constant ADMIN_ROLE = keccak256("AOXC_ADMIN_ROLE");
    bytes32 public constant REPORTER_ROLE = keccak256("AOXC_REPORTER_ROLE");
    bytes32 public constant UPGRADER_ROLE = keccak256("AOXC_UPGRADER_ROLE");

    // --- State Variables ---
    mapping(uint256 => ForensicLog) private _forensicRecords;
    uint256 private _globalSequenceId;
    bool private _active;

    // Rate limiting
    mapping(address => uint256) private _lastLogTimestamp;
    uint256 public constant LOG_COOLDOWN = 1 seconds;

    // --- Events ---
    event MonitoringStatusChanged(bool active);

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    /**
     * @notice Initializes the 26-channel Monitoring Hub.
     */
    function initialize(address admin) external initializer {
        if (admin == address(0)) revert AOXCErrors.ZeroAddressDetected();

        __AccessControl_init();
        // NOT: OpenZeppelin 5.x'te __UUPSUpgradeable_init() kaldırılmıştır.

        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(ADMIN_ROLE, admin);
        _grantRole(UPGRADER_ROLE, admin);

        _active = true;
    }

    // --- Core Forensic Logic ---

    /**
     * @notice Seals a 26-channel forensic log onto the blockchain.
     * @param log The full forensic data package.
     */
    function logForensic(ForensicLog calldata log) external override onlyRole(REPORTER_ROLE) nonReentrant {
        if (!_active) revert AOXCErrors.ProtocolPaused();

        // Anti-spam protection for non-emergency logs
        if (log.severity < Severity.CRITICAL) {
            if (block.timestamp < _lastLogTimestamp[msg.sender] + LOG_COOLDOWN) {
                revert AOXCErrors.SequenceOutOfOrder();
            }
        }

        uint256 currentId;
        unchecked {
            currentId = ++_globalSequenceId;
        }

        // Store and Link
        _forensicRecords[currentId] = log;
        _forensicRecords[currentId].sequenceId = currentId;

        _lastLogTimestamp[msg.sender] = block.timestamp;

        // 26-channel Signal
        emit RecordLogged(currentId, log.source, log.severity, log.category, log.correlationId);
    }

    // --- Operational Controls ---

    function setStatus(bool active) external onlyRole(ADMIN_ROLE) {
        _active = active;
        emit MonitoringStatusChanged(active);
    }

    // --- View Functions ---

    function getRecord(uint256 index) external view override returns (ForensicLog memory) {
        if (index == 0 || index > _globalSequenceId) revert AOXCErrors.InvalidConfiguration();
        return _forensicRecords[index];
    }

    function getRecordCount() external view override returns (uint256) {
        return _globalSequenceId;
    }

    function isMonitoringActive() external view override returns (bool) {
        return _active;
    }

    // --- Infrastructure ---

    /**
     * @dev Required by UUPSUpgradeable
     */
    function _authorizeUpgrade(address) internal override onlyRole(UPGRADER_ROLE) {
        // Admin yetkisi kontrolü zaten modifier ile yapılıyor
    }

    // Storage gap for future proxy upgrades (v5 standard)
    uint256[48] private _gap;
}
