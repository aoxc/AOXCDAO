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

import { IJurisdictionRegistry } from "@interfaces/IJurisdictionRegistry.sol";
import { IMonitoringHub } from "@interfaces/IMonitoringHub.sol";
import { IReputationManager } from "@interfaces/IReputationManager.sol";
import { AOXCErrors } from "@libraries/AOXCErrors.sol";

/**
 * @title AOXCJurisdictionRegistry
 * @author AOXC Core Engineering
 * @notice Regional compliance and jurisdiction management for the AOXC ecosystem.
 * @dev Fully implements IJurisdictionRegistry with 26-channel forensic monitoring.
 */
contract AOXCJurisdictionRegistry is
    IJurisdictionRegistry,
    Initializable,
    AccessControlUpgradeable,
    PausableUpgradeable,
    UUPSUpgradeable
{
    // --- Access Control Roles ---
    bytes32 public constant ADMIN_ROLE = keccak256("AOXC_ADMIN_ROLE");
    bytes32 public constant OPERATOR_ROLE = keccak256("AOXC_OPERATOR_ROLE");
    bytes32 public constant UPGRADER_ROLE = keccak256("AOXC_UPGRADER_ROLE");

    // --- External Interfaces ---
    IMonitoringHub public monitoringHub;
    IReputationManager public reputationManager;

    // --- Jurisdiction Storage ---
    uint256[] private _jurisdictionIds;
    mapping(uint256 => string) private _jurisdictionNames;
    mapping(uint256 => bool) private _jurisdictionAllowed;
    mapping(address => uint256) private _userJurisdiction;
    mapping(uint256 => uint256) private _jurisdictionIndex;

    // --- Events ---
    event JurisdictionAdded(
        uint256 indexed id, string name, bool allowed, address indexed operator
    );
    event JurisdictionRemoved(uint256 indexed id, address indexed operator);
    event UserJurisdictionSet(
        address indexed user, uint256 indexed jurisdictionId, address indexed operator
    );
    event UserJurisdictionRevoked(address indexed user, address indexed operator);

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    /**
     * @notice Initializes the Jurisdiction Registry.
     */
    function initialize(address admin, address _monitoringHub, address _reputationManager)
        external
        initializer
    {
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

    function assignJurisdiction(address user, uint256 id)
        external
        override
        onlyRole(OPERATOR_ROLE)
        whenNotPaused
    {
        _assignJurisdiction(user, id);
        _rewardOperator(msg.sender, "JUR_ASSIGNMENT");
    }

    function revokeJurisdiction(address user) external override onlyRole(OPERATOR_ROLE) {
        if (user == address(0)) revert AOXCErrors.ZeroAddressDetected();
        _userJurisdiction[user] = 0;

        emit UserJurisdictionRevoked(user, msg.sender);
        _logToHub(IMonitoringHub.Severity.WARNING, "JUR_REVOKE", "User assignment cleared");
        _rewardOperator(msg.sender, "JUR_REVOKE");
    }

    // --- View Functions ---

    function isAllowed(address account) external view override returns (bool) {
        uint256 jurId = _userJurisdiction[account];
        return jurId != 0 && _jurisdictionAllowed[jurId];
    }

    function getUserJurisdiction(address user) external view override returns (uint256) {
        return _userJurisdiction[user];
    }

    function jurisdictionExists(uint256 jurisdictionId) external view override returns (bool) {
        return bytes(_jurisdictionNames[jurisdictionId]).length > 0;
    }

    function getJurisdictionCount() external view override returns (uint256) {
        return _jurisdictionIds.length;
    }

    function getJurisdictionName(uint256 jurisdictionId)
        external
        view
        override
        returns (string memory)
    {
        return _jurisdictionNames[jurisdictionId];
    }

    // --- Batch Operations ---

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

    function _assignJurisdiction(address user, uint256 id) internal {
        if (user == address(0)) revert AOXCErrors.ZeroAddressDetected();
        if (bytes(_jurisdictionNames[id]).length == 0) revert AOXCErrors.InvalidConfiguration();

        _userJurisdiction[user] = id;
        emit UserJurisdictionSet(user, id, msg.sender);
    }

    function _rewardOperator(address operator, bytes32 actionKey) internal {
        if (address(reputationManager) != address(0)) {
            try reputationManager.processAction(operator, actionKey) { } catch { }
        }
    }

    /**
     * @dev High-fidelity 26-channel forensic logging.
     */
    function _logToHub(
        IMonitoringHub.Severity severity,
        string memory action,
        string memory details
    ) internal {
        if (address(monitoringHub) != address(0)) {
            IMonitoringHub.ForensicLog memory log = IMonitoringHub.ForensicLog({
                source: address(this),
                actor: msg.sender,
                origin: tx.origin,
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

            try monitoringHub.logForensic(log) { } catch { }
        }
    }

    function _authorizeUpgrade(address) internal override onlyRole(UPGRADER_ROLE) {
        _logToHub(
            IMonitoringHub.Severity.CRITICAL, "UPGRADE", "Jurisdiction Registry upgrade authorized"
        );
    }

    uint256[43] private _gap;
}
