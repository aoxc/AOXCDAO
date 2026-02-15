// SPDX-License-Identifier: MIT
pragma solidity 0.8.33;

import { Initializable } from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {
    AccessControlUpgradeable
} from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import {
    PausableUpgradeable
} from "@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol";
import {
    UUPSUpgradeable
} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

import { IMonitoringHub } from "@interfaces/IMonitoringHub.sol";
import { AOXCBaseReporter } from "../monitoring/AOXCBaseReporter.sol";
import { AOXCErrors } from "@libraries/AOXCErrors.sol";

/**
 * @title AOXCGuardianRegistry
 * @author AOXC Core Engineering
 * @notice Dynamic management of Guardians (Sentinels) within the AOXC ecosystem.
 * @dev Re-engineered for Akdeniz V2 Forensic Logging with wrapped modifiers for lint compliance.
 */
contract AOXCGuardianRegistry is
    Initializable,
    AccessControlUpgradeable,
    PausableUpgradeable,
    UUPSUpgradeable,
    AOXCBaseReporter
{
    // --- Access Control Roles ---
    bytes32 public constant ADMIN_ROLE = keccak256("AOXC_ADMIN_ROLE");
    bytes32 public constant UPGRADER_ROLE = keccak256("AOXC_UPGRADER_ROLE");

    // --- State Variables ---
    address[] private _activeGuardians;
    mapping(address => bool) private _isGuardian;
    mapping(address => uint256) private _guardianIndex;

    // --- Local Reentrancy Guard State ---
    uint256 private _status;
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    // --- Events ---
    event GuardianAdded(address indexed guardian, uint256 timestamp);
    event GuardianRemoved(address indexed guardian, uint256 timestamp);

    // --- Wrapped Modifiers (Forge Lint Fix: unwrapped-modifier-logic) ---

    /**
     * @dev Optimized Reentrancy Guard with internal wrapping to reduce code size.
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
     * @notice Initializes the Guardian Registry.
     * @param admin Initial administrator address.
     * @param _monitoringHub Address of the centralized monitoring system.
     */
    function initialize(address admin, address _monitoringHub) external initializer {
        if (admin == address(0) || _monitoringHub == address(0)) {
            revert AOXCErrors.ZeroAddressDetected();
        }

        __AccessControl_init();
        __Pausable_init();

        _status = _NOT_ENTERED;

        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(ADMIN_ROLE, admin);
        _grantRole(UPGRADER_ROLE, admin);

        _setMonitoringHub(_monitoringHub);

        _performForensicLog(
            IMonitoringHub.Severity.INFO,
            "INITIALIZE",
            "Guardian Registry online",
            address(0),
            0,
            ""
        );
    }

    // --- Core Logic ---

    /**
     * @notice Appoints a new guardian to the registry.
     * @param guardian Address to be granted sentinel powers.
     */
    function addGuardian(address guardian)
        external
        onlyRole(ADMIN_ROLE)
        whenNotPaused
        nonReentrant
    {
        if (guardian == address(0)) revert AOXCErrors.ZeroAddressDetected();
        if (_isGuardian[guardian]) revert AOXCErrors.SecurityAssumptionViolated();

        _isGuardian[guardian] = true;
        _guardianIndex[guardian] = _activeGuardians.length;
        _activeGuardians.push(guardian);

        _performForensicLog(
            IMonitoringHub.Severity.INFO,
            "GUARDIAN_ADDED",
            "New sentinel authorized",
            guardian,
            10,
            ""
        );

        emit GuardianAdded(guardian, block.timestamp);
    }

    /**
     * @notice Dismisses a guardian from the registry using a gas-efficient Swap & Pop.
     * @param guardian Address to be removed from the registry.
     */
    function removeGuardian(address guardian) external onlyRole(ADMIN_ROLE) nonReentrant {
        if (!_isGuardian[guardian]) revert AOXCErrors.InvalidConfiguration();

        uint256 indexToRemove = _guardianIndex[guardian];
        uint256 lastIndex = _activeGuardians.length - 1;

        if (indexToRemove != lastIndex) {
            address lastGuardian = _activeGuardians[lastIndex];
            _activeGuardians[indexToRemove] = lastGuardian;
            _guardianIndex[lastGuardian] = indexToRemove;
        }

        _activeGuardians.pop();
        delete _isGuardian[guardian];
        delete _guardianIndex[guardian];

        _performForensicLog(
            IMonitoringHub.Severity.WARNING,
            "GUARDIAN_REMOVED",
            "Sentinel dismissed from registry",
            guardian,
            30,
            ""
        );

        emit GuardianRemoved(guardian, block.timestamp);
    }

    // --- View Functions ---

    function isGuardian(address account) external view returns (bool) {
        return _isGuardian[account];
    }

    function getGuardianCount() external view returns (uint256) {
        return _activeGuardians.length;
    }

    function listActiveGuardians() external view returns (address[] memory) {
        return _activeGuardians;
    }

    // --- Internal Infrastructure ---

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
            "REGISTRY_UPGRADE",
            "Infrastructure logic migration",
            newImplementation,
            100,
            ""
        );
    }

    /**
     * @dev Reserved storage gap for upgradeability.
     */
    uint256[46] private _gap;
}
