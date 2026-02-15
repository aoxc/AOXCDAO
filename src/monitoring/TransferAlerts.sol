// SPDX-License-Identifier: MIT
pragma solidity 0.8.33;

import { Initializable } from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import { AccessControlUpgradeable } from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import { UUPSUpgradeable } from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

import { IMonitoringHub } from "../interfaces/IMonitoringHub.sol";
import { AOXCBaseReporter } from "./AOXCBaseReporter.sol";
import { AOXCErrors } from "../libraries/AOXCErrors.sol";

/**
 * @title AOXCTransferAlerts
 * @author AOXC Core Engineering
 * @notice Suspicious transfer activity monitor with 26-channel forensic telemetry.
 * @dev Optimized for UUPS Proxy pattern with internal reentrancy control and lint-compliant naming.
 */
contract AOXCTransferAlerts is
    Initializable,
    AccessControlUpgradeable,
    UUPSUpgradeable,
    AOXCBaseReporter
{
    // --- Access Control Roles ---
    bytes32 public constant ADMIN_ROLE = keccak256("AOXC_ADMIN_ROLE");
    bytes32 public constant MONITOR_ROLE = keccak256("AOXC_MONITOR_ROLE");
    bytes32 public constant UPGRADER_ROLE = keccak256("AOXC_UPGRADER_ROLE");

    // --- State Variables ---
    uint256 public totalAlertsLogged;

    // --- Reentrancy Control ---
    uint256 private _status;
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    // --- Events ---
    event TransferAlert(
        address indexed from,
        address indexed to,
        uint256 amount,
        string reason,
        uint256 timestamp,
        address reporter
    );

    // --- Modifiers ---

    /**
     * @dev Modifier logic is wrapped in internal functions to reduce code size (lint: unwrapped-modifier-logic).
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
     * @notice Initializes the Transfer Alerts module.
     * @param admin Initial administrator and monitor.
     * @param _monitoringHub Address of the AOXC Monitoring Hub.
     */
    function initialize(address admin, address _monitoringHub) external initializer {
        if (admin == address(0) || _monitoringHub == address(0)) {
            revert AOXCErrors.ZeroAddressDetected();
        }

        __AccessControl_init();

        _status = _NOT_ENTERED;

        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(ADMIN_ROLE, admin);
        _grantRole(MONITOR_ROLE, admin);
        _grantRole(UPGRADER_ROLE, admin);

        _setMonitoringHub(_monitoringHub);

        _performForensicLog(
            IMonitoringHub.Severity.INFO,
            "INITIALIZE",
            "Transfer Alerts Engine online",
            address(0),
            0,
            ""
        );
    }

    /**
     * @notice Reports suspicious transfers to the Monitoring Hub.
     */
    function alertTransfer(
        address from,
        address to,
        uint256 amount,
        string calldata reason
    ) external nonReentrant onlyRole(MONITOR_ROLE) {
        unchecked {
            ++totalAlertsLogged;
        }

        _performForensicLog(
            IMonitoringHub.Severity.CRITICAL,
            "TRANSFER_ALERT",
            reason,
            from,
            80,
            abi.encode(to, amount)
        );

        emit TransferAlert(from, to, amount, reason, block.timestamp, msg.sender);
    }

    // --- Upgrade Mechanism ---

    /**
     * @dev Authorizes the upgrade and logs the event for forensic auditing.
     * @param newImplementation The address of the new contract logic.
     */
    function _authorizeUpgrade(
        address newImplementation
    ) internal override onlyRole(UPGRADER_ROLE) {
        if (newImplementation == address(0)) {
            revert AOXCErrors.ZeroAddressDetected();
        }

        _performForensicLog(
            IMonitoringHub.Severity.EMERGENCY,
            "LOGIC_UPGRADE",
            "Transfer Alerts migration initiated",
            newImplementation,
            100,
            ""
        );
    }

    /**
     * @dev Storage gap for future upgrades (lint: mixed-case-variable).
     * Name changed from _gap to _gap to comply with linting rules.
     */
    uint256[47] private _gap;
}
