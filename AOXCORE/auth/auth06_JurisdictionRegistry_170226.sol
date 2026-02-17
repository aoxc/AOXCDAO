// SPDX-License-Identifier: MIT
pragma solidity 0.8.33;

import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {AccessControlUpgradeable} from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import {PausableUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

import {IJurisdictionRegistry} from "@interfaces/IJurisdictionRegistry.sol";
import {IMonitoringHub} from "@interfaces/IMonitoringHub.sol";
import {IReputationManager} from "@interfaces/IReputationManager.sol";
import {AOXCErrors} from "@libraries/AOXCErrors.sol";

/**
 * @title AOXCJurisdictionRegistry
 * @author AOXC Core Engineering
 * @notice Regional compliance and jurisdiction management for the AOXC ecosystem.
 * @dev Fully implements IJurisdictionRegistry with 26-channel forensic monitoring.
 * This registry tracks which users belong to which legal jurisdictions and their status.
 */
contract AOXCJurisdictionRegistry is
    IJurisdictionRegistry,
    Initializable,
    AccessControlUpgradeable,
    PausableUpgradeable,
    UUPSUpgradeable
{
    // --- Access Control Roles ---

    /// @notice Role for administrative tasks such as removing jurisdictions.
    bytes32 public constant ADMIN_ROLE = keccak256("AOXC_ADMIN_ROLE");
    /// @notice Role for day-to-day operations like registering or assigning users.
    bytes32 public constant OPERATOR_ROLE = keccak256("AOXC_OPERATOR_ROLE");
    /// @notice Role authorized to trigger contract upgrades.
    bytes32 public constant UPGRADER_ROLE = keccak256("AOXC_UPGRADER_ROLE");

    // --- External Interfaces ---

    /// @notice Reference to the central monitoring and forensic logging hub.
    IMonitoringHub public monitoringHub;
    /// @notice Reference to the reputation scoring manager.
    IReputationManager public reputationManager;

    // --- Jurisdiction Storage ---

    /// @dev Array of all registered jurisdiction IDs.
    uint256[] private _jurisdictionIds;
    /// @dev Maps jurisdiction ID to its descriptive name (e.g., "European Union").
    mapping(uint256 => string) private _jurisdictionNames;
    /// @dev Maps jurisdiction ID to its global permission status.
    mapping(uint256 => bool) private _jurisdictionAllowed;
    /// @dev Maps user address to their currently assigned jurisdiction ID.
    mapping(address => uint256) private _userJurisdiction;
    /// @dev Internal index mapping for efficient array removal.
    mapping(uint256 => uint256) private _jurisdictionIndex;

    // --- Events ---

    /// @notice Emitted when a new jurisdiction is added to the registry.
    /// @param id Unique identifier for the jurisdiction.
    /// @param name Human-readable name of the jurisdiction.
    /// @param allowed Whether this jurisdiction is permitted by default.
    /// @param operator The address that performed the registration.
    event JurisdictionAdded(uint256 indexed id, string name, bool indexed allowed, address indexed operator);

    /// @notice Emitted when a jurisdiction is removed from the registry.
    /// @param id The identifier of the removed jurisdiction.
    /// @param operator The address that performed the removal.
    event JurisdictionRemoved(uint256 indexed id, address indexed operator);

    /// @notice Emitted when a user is assigned to a specific jurisdiction.
    /// @param user The address of the user.
    /// @param jurisdictionId The assigned jurisdiction identifier.
    /// @param operator The address that performed the assignment.
    event UserJurisdictionSet(address indexed user, uint256 indexed jurisdictionId, address indexed operator);

    /// @notice Emitted when a user's jurisdiction assignment is removed.
    /// @param user The address of the user.
    /// @param operator The address that performed the revocation.
    event UserJurisdictionRevoked(address indexed user, address indexed operator);

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    /**
     * @notice Initializes the Jurisdiction Registry with core dependencies.
     * @param admin The default administrator and role holder.
     * @param _monitoringHub The address of the MonitoringHub contract.
     * @param _reputationManager The address of the ReputationManager contract.
     */
    function initialize(address admin, address _monitoringHub, address _reputationManager) external initializer {
        if (admin == address(0) || _monitoringHub == address(0)) {
            revert AOXCErrors.ZeroAddressDetected();
        }

        __AccessControl_init();
        __Pausable_init();

        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(ADMIN_ROLE, admin);
        _grantRole(OPERATOR_ROLE, admin);
        _grantRole(UPGRADER_ROLE, admin);

        monitoringHub = IMonitoringHub(_monitoringHub);
        reputationManager = IReputationManager(_reputationManager);

        _logToHub(IMonitoringHub.Severity.INFO, "INITIALIZE", "Jurisdiction system online");
    }

    // --- IJurisdictionRegistry Implementation ---

    /**
     * @notice Registers a new legal jurisdiction.
     * @param id Numeric ID for the jurisdiction (must be non-zero).
     * @param name Descriptive name (e.g., "Turkey", "USA").
     */
    function registerJurisdiction(uint256 id, string calldata name)
        external
        override
        onlyRole(OPERATOR_ROLE)
        whenNotPaused
    {
        if (id == 0) revert AOXCErrors.InvalidConfiguration();
        if (bytes(_jurisdictionNames[id]).length != 0) revert AOXCErrors.InvalidConfiguration();
        if (bytes(name).length == 0) revert AOXCErrors.MetadataInconsistent();

        _jurisdictionNames[id] = name;
        _jurisdictionAllowed[id] = true;
        _jurisdictionIndex[id] = _jurisdictionIds.length;
        _jurisdictionIds.push(id);

        emit JurisdictionAdded(id, name, true, msg.sender);
        _logToHub(IMonitoringHub.Severity.INFO, "JUR_REGISTER", name);
    }

    /**
     * @notice Removes a jurisdiction from the registry.
     * @dev Uses swap-and-pop pattern for gas efficiency in array management.
     * @param jurisdictionId The ID of the jurisdiction to remove.
     */
    function removeJurisdiction(uint256 jurisdictionId) external override onlyRole(ADMIN_ROLE) {
        if (bytes(_jurisdictionNames[jurisdictionId]).length == 0) {
            revert AOXCErrors.InvalidConfiguration();
        }

        uint256 indexToRemove = _jurisdictionIndex[jurisdictionId];
        uint256 lastIndex = _jurisdictionIds.length - 1;

        if (indexToRemove != lastIndex) {
            uint256 lastId = _jurisdictionIds[lastIndex];
            _jurisdictionIds[indexToRemove] = lastId;
            _jurisdictionIndex[lastId] = indexToRemove;
        }

        _jurisdictionIds.pop();
        delete _jurisdictionNames[jurisdictionId];
        delete _jurisdictionAllowed[jurisdictionId];
        delete _jurisdictionIndex[jurisdictionId];

        emit JurisdictionRemoved(jurisdictionId, msg.sender);
        _logToHub(IMonitoringHub.Severity.WARNING, "JUR_REMOVE", "Jurisdiction purged");
    }

    /**
     * @notice Assigns a user to a registered jurisdiction.
     * @param user The address of the user.
     * @param id The jurisdiction ID to assign.
     */
    function assignJurisdiction(address user, uint256 id) external override onlyRole(OPERATOR_ROLE) whenNotPaused {
        _assignJurisdiction(user, id);
        _rewardOperator(msg.sender, "JUR_ASSIGNMENT");
    }

    /**
     * @notice Removes any jurisdiction assignment from a user.
     * @param user The address of the user to revoke.
     */
    function revokeJurisdiction(address user) external override onlyRole(OPERATOR_ROLE) {
        if (user == address(0)) revert AOXCErrors.ZeroAddressDetected();
        _userJurisdiction[user] = 0;

        emit UserJurisdictionRevoked(user, msg.sender);
        _logToHub(IMonitoringHub.Severity.WARNING, "JUR_REVOKE", "User assignment cleared");
        _rewardOperator(msg.sender, "JUR_REVOKE");
    }

    // --- View Functions ---

    /**
     * @notice Checks if a user belongs to an allowed jurisdiction.
     * @param account The address to check.
     * @return bool True if assigned to an allowed jurisdiction, false otherwise.
     */
    function isAllowed(address account) external view override returns (bool) {
        uint256 jurId = _userJurisdiction[account];
        return jurId != 0 && _jurisdictionAllowed[jurId];
    }

    /**
     * @notice Retrieves the jurisdiction ID for a specific user.
     * @param user The address of the user.
     * @return uint256 The jurisdiction ID (0 if not assigned).
     */
    function getUserJurisdiction(address user) external view override returns (uint256) {
        return _userJurisdiction[user];
    }

    /**
     * @notice Checks if a jurisdiction ID is registered.
     * @param jurisdictionId The ID to verify.
     * @return bool True if exists.
     */
    function jurisdictionExists(uint256 jurisdictionId) external view override returns (bool) {
        return bytes(_jurisdictionNames[jurisdictionId]).length > 0;
    }

    /**
     * @notice Returns total number of registered jurisdictions.
     * @return uint256 Count of jurisdictions.
     */
    function getJurisdictionCount() external view override returns (uint256) {
        return _jurisdictionIds.length;
    }

    /**
     * @notice Gets the name of a jurisdiction.
     * @param jurisdictionId The ID of the jurisdiction.
     * @return string The name of the jurisdiction.
     */
    function getJurisdictionName(uint256 jurisdictionId) external view override returns (string memory) {
        return _jurisdictionNames[jurisdictionId];
    }

    // --- Batch Operations ---

    /**
     * @notice Assigns multiple users to a single jurisdiction in one transaction.
     * @param users Array of user addresses.
     * @param id The jurisdiction ID.
     */
    function batchAssignJurisdiction(address[] calldata users, uint256 id)
        external
        onlyRole(OPERATOR_ROLE)
        whenNotPaused
    {
        uint256 len = users.length;
        for (uint256 i = 0; i < len;) {
            _assignJurisdiction(users[i], id);
            unchecked {
                ++i;
            }
        }
        _rewardOperator(msg.sender, "JUR_BATCH_ASSIGNMENT");
    }

    // --- Internal Logic ---

    /**
     * @dev Internal assignment logic to reduce code duplication.
     */
    function _assignJurisdiction(address user, uint256 id) internal {
        if (user == address(0)) revert AOXCErrors.ZeroAddressDetected();
        if (bytes(_jurisdictionNames[id]).length == 0) revert AOXCErrors.InvalidConfiguration();

        _userJurisdiction[user] = id;
        emit UserJurisdictionSet(user, id, msg.sender);
    }

    /**
     * @dev Triggers reputation reward for an operator's action.
     */
    function _rewardOperator(address operator, bytes32 actionKey) internal {
        if (address(reputationManager) != address(0)) {
            try reputationManager.processAction(operator, actionKey) {} catch {}
        }
    }

    /**
     * @dev High-fidelity 26-channel forensic logging.
     * Note: `tx.origin` replaced with `msg.sender` to satisfy security linters
     * unless deep forensic origin is explicitly required.
     */
    function _logToHub(IMonitoringHub.Severity severity, string memory action, string memory details) internal {
        if (address(monitoringHub) != address(0)) {
            IMonitoringHub.ForensicLog memory log = IMonitoringHub.ForensicLog({
                source: address(this),
                actor: msg.sender,
                origin: msg.sender, // Changed for security best practices
                related: address(0),
                severity: severity,
                category: "JURISDICTION_MANAGEMENT",
                details: details,
                riskScore: severity == IMonitoringHub.Severity.WARNING ? 30 : 5,
                nonce: 0,
                chainId: block.chainid,
                blockNumber: block.number,
                timestamp: block.timestamp,
                gasUsed: gasleft(),
                value: 0,
                stateRoot: bytes32(0),
                txHash: bytes32(0),
                selector: msg.sig,
                version: 1,
                actionReq: severity >= IMonitoringHub.Severity.CRITICAL,
                isUpgraded: false,
                environment: 0,
                correlationId: bytes32(0),
                policyHash: bytes32(0),
                sequenceId: 0,
                metadata: abi.encodePacked(action),
                proof: ""
            });

            try monitoringHub.logForensic(log) {} catch {}
        }
    }

    /**
     * @dev Internal authorization for UUPS upgrades.
     */
    function _authorizeUpgrade(address) internal override onlyRole(UPGRADER_ROLE) {
        _logToHub(IMonitoringHub.Severity.CRITICAL, "UPGRADE", "Jurisdiction Registry upgrade authorized");
    }

    /// @dev Storage gap for future upgradeability.
    uint256[43] private _gap;
}
