// SPDX-License-Identifier: MIT
pragma solidity 0.8.33;

import { Initializable } from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {
    AccessControlUpgradeable
} from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import {
    UUPSUpgradeable
} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

import { ITransferPolicy } from "@interfaces/ITransferPolicy.sol";
import { IMonitoringHub } from "@interfaces/IMonitoringHub.sol";
import { AOXCBaseReporter } from "../monitoring/AOXCBaseReporter.sol";
import { AOXCErrors } from "@libraries/AOXCErrors.sol";

/**
 * @title AOXCEmergencyTransferPolicy
 * @author AOXC Core Engineering
 * @notice High-security transfer policy engine for emergency freezes and global limits.
 * @dev Re-engineered for Akdeniz V2 with wrapped modifiers for lint compliance and gas optimization.
 */
contract AOXCEmergencyTransferPolicy is
    ITransferPolicy,
    Initializable,
    AccessControlUpgradeable,
    UUPSUpgradeable,
    AOXCBaseReporter
{
    // --- Access Control Roles ---
    bytes32 public constant ADMIN_ROLE = keccak256("AOXC_ADMIN_ROLE");
    bytes32 public constant GUARDIAN_ROLE = keccak256("AOXC_GUARDIAN_ROLE");
    bytes32 public constant UPGRADER_ROLE = keccak256("AOXC_UPGRADER_ROLE");

    // --- State Variables ---
    bool public frozen;
    uint256 public globalTransferLimit;
    mapping(address => bool) public isExempt;

    // --- Independent Reentrancy Guard State ---
    uint256 private _status;
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    // --- Wrapped Modifiers (Forge Lint Fix: unwrapped-modifier-logic) ---

    /**
     * @dev Optimized Reentrancy Guard logic with internal wrapping to satisfy enterprise lint rules.
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
     * @notice Initializes the Emergency Transfer Policy.
     * @param admin Initial administrator address.
     * @param _monitoringHub Forensic logging hub address.
     * @param _initialLimit Initial global transfer amount threshold.
     */
    function initialize(address admin, address _monitoringHub, uint256 _initialLimit)
        external
        initializer
    {
        if (admin == address(0) || _monitoringHub == address(0)) {
            revert AOXCErrors.ZeroAddressDetected();
        }
        __AccessControl_init();

        _status = _NOT_ENTERED;
        _setMonitoringHub(_monitoringHub);
        globalTransferLimit = _initialLimit;

        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(ADMIN_ROLE, admin);
        _grantRole(UPGRADER_ROLE, admin);

        _performForensicLog(
            IMonitoringHub.Severity.INFO,
            "INITIALIZE",
            "Emergency Transfer Policy deployed",
            address(0),
            0,
            ""
        );
    }

    // --- Core Logic ---

    /**
     * @notice Validates a transfer against current security policies.
     * @param from Sender address.
     * @param to Recipient address.
     * @param amount Transaction value.
     */
    function validateTransfer(address from, address to, uint256 amount) external override {
        if (isExempt[from] || isExempt[to]) {
            emit TransferValidated(from, to, amount, block.timestamp);
            return;
        }

        if (frozen) {
            _performForensicLog(
                IMonitoringHub.Severity.WARNING, "AUTH_REJECT", "Freeze active", from, 40, ""
            );
            revert AOXCErrors.ProtocolPaused();
        }

        if (globalTransferLimit > 0 && amount > globalTransferLimit) {
            revert AOXCErrors.ThresholdExceeded();
        }

        emit TransferValidated(from, to, amount, block.timestamp);
    }

    /**
     * @notice Updates the emergency freeze status and global limits.
     * @param _frozen New freeze status.
     * @param _newLimit New global limit.
     */
    function setEmergencyStatus(bool _frozen, uint256 _newLimit) external onlyRole(GUARDIAN_ROLE) {
        frozen = _frozen;
        globalTransferLimit = _newLimit;

        _performForensicLog(
            _frozen ? IMonitoringHub.Severity.CRITICAL : IMonitoringHub.Severity.INFO,
            "EMERGENCY_STATE",
            "Status update",
            address(0),
            _frozen ? 90 : 10,
            abi.encode(_newLimit)
        );
    }

    // --- Policy Metadata & Configuration ---

    function isPolicyActive() external view override returns (bool) {
        return !frozen;
    }

    function policyName() external pure override returns (string memory) {
        return "AOXC_Emergency_V2";
    }

    function policyVersion() external pure override returns (uint256) {
        return 2;
    }

    function updatePolicyParameter(string calldata, uint256 newValue)
        external
        override
        onlyRole(ADMIN_ROLE)
    {
        globalTransferLimit = newValue;
    }

    function setPolicyActive(bool active) external override onlyRole(ADMIN_ROLE) {
        frozen = !active;
    }

    /**
     * @dev Implementation for UUPS upgrade authorization.
     */
    function _authorizeUpgrade(address newImplementation)
        internal
        override
        onlyRole(UPGRADER_ROLE)
    {
        if (newImplementation == address(0)) {
            revert AOXCErrors.ZeroAddressDetected();
        }
        _performForensicLog(
            IMonitoringHub.Severity.CRITICAL,
            "UPGRADE",
            "Policy Migration authorized",
            newImplementation,
            100,
            ""
        );
    }

    /**
     * @dev Reserved storage gap for upgradeability protection (50 slots total).
     */
    uint256[46] private _gap;
}
