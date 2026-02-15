// SPDX-License-Identifier: MIT
pragma solidity 0.8.33;

import { Initializable } from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import { AccessControlUpgradeable } from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import { PausableUpgradeable } from "@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol";
import { UUPSUpgradeable } from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

import { IIdentityRegistry } from "@interfaces/IIdentityRegistry.sol";
import { IMonitoringHub } from "@interfaces/IMonitoringHub.sol";
import { IReputationManager } from "@interfaces/IReputationManager.sol";
import { AOXCErrors } from "@libraries/AOXCErrors.sol";

/**
 * @title AOXCIdentityRegistry
 * @author AOXC Core Engineering
 * @notice Central identity and verification registry for the AOXC Ecosystem.
 * @dev Fully implements IIdentityRegistry with 26-channel forensic monitoring support.
 */
contract AOXCIdentityRegistry is
    IIdentityRegistry,
    Initializable,
    AccessControlUpgradeable,
    PausableUpgradeable,
    UUPSUpgradeable
{
    // --- Access Control Roles ---
    bytes32 public constant ADMIN_ROLE = keccak256("AOXC_ADMIN_ROLE");
    bytes32 public constant VERIFIER_ROLE = keccak256("AOXC_VERIFIER_ROLE");
    bytes32 public constant UPGRADER_ROLE = keccak256("AOXC_UPGRADER_ROLE");

    // --- External Interfaces ---
    IMonitoringHub public monitoringHub;
    IReputationManager public reputationManager;

    // --- Identity Storage ---
    address[] private _registeredAccounts;
    mapping(address => string) private _identities;
    mapping(address => uint256) private _registeredIndex;

    // --- Events ---
    event IdentityRegistered(address indexed account, string id, address indexed verifier);
    event IdentityRemoved(address indexed account, address indexed verifier);
    event IdentityUpdated(
        address indexed account,
        string oldId,
        string newId,
        address indexed verifier
    );

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    /**
     * @notice Initializes the Identity Registry.
     */
    function initialize(
        address admin,
        address _monitoringHub,
        address _reputationManager
    ) external initializer {
        if (admin == address(0) || _monitoringHub == address(0)) {
            revert AOXCErrors.ZeroAddressDetected();
        }

        __AccessControl_init();
        __Pausable_init();

        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(ADMIN_ROLE, admin);
        _grantRole(VERIFIER_ROLE, admin);
        _grantRole(UPGRADER_ROLE, admin);

        monitoringHub = IMonitoringHub(_monitoringHub);
        reputationManager = IReputationManager(_reputationManager);

        _logToHub(IMonitoringHub.Severity.INFO, "INITIALIZE", "Identity system online");
    }

    // --- IIdentityRegistry Implementation ---

    function register(
        address account,
        string calldata id
    ) external override onlyRole(VERIFIER_ROLE) whenNotPaused {
        _register(account, id);
        _rewardVerifier(msg.sender, "IDENTITY_VERIFICATION");
    }

    function deregister(address account) external override onlyRole(VERIFIER_ROLE) whenNotPaused {
        if (bytes(_identities[account]).length == 0) revert AOXCErrors.InvalidItemID(0);

        uint256 indexToRemove = _registeredIndex[account];
        uint256 lastIndex = _registeredAccounts.length - 1;

        if (indexToRemove != lastIndex) {
            address lastAccount = _registeredAccounts[lastIndex];
            _registeredAccounts[indexToRemove] = lastAccount;
            _registeredIndex[lastAccount] = indexToRemove;
        }

        _registeredAccounts.pop();
        delete _identities[account];
        delete _registeredIndex[account];

        emit IdentityRemoved(account, msg.sender);
        _logToHub(IMonitoringHub.Severity.WARNING, "IDENTITY_REVOKE", "Identity purged");
    }

    // --- View Functions ---

    function getRegisteredCount() external view override returns (uint256) {
        return _registeredAccounts.length;
    }

    function isRegistered(address account) external view override returns (bool) {
        return bytes(_identities[account]).length > 0;
    }

    function getIdentity(address account) external view override returns (string memory) {
        return _identities[account];
    }

    function getRegisteredAccounts() external view returns (address[] memory) {
        return _registeredAccounts;
    }

    // --- Batch Operations ---

    function batchRegister(
        address[] calldata accounts,
        string[] calldata ids
    ) external onlyRole(VERIFIER_ROLE) whenNotPaused {
        uint256 len = accounts.length;
        if (len != ids.length) revert AOXCErrors.InvalidConfiguration();

        for (uint256 i = 0; i < len; ) {
            _register(accounts[i], ids[i]);
            unchecked {
                ++i;
            }
        }
        _rewardVerifier(msg.sender, "IDENTITY_BATCH_VERIFICATION");
    }

    // --- Internal Logic ---

    function _register(address account, string memory id) internal {
        if (account == address(0)) revert AOXCErrors.ZeroAddressDetected();
        if (bytes(_identities[account]).length != 0) revert AOXCErrors.InvalidConfiguration();
        if (bytes(id).length == 0) revert AOXCErrors.MetadataInconsistent();

        _identities[account] = id;
        _registeredIndex[account] = _registeredAccounts.length;
        _registeredAccounts.push(account);

        emit IdentityRegistered(account, id, msg.sender);
        _logToHub(IMonitoringHub.Severity.INFO, "IDENTITY_REG", id);
    }

    function _rewardVerifier(address verifier, bytes32 actionKey) internal {
        if (address(reputationManager) != address(0)) {
            try reputationManager.processAction(verifier, actionKey) {} catch {}
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
                category: "IDENTITY_MANAGEMENT",
                details: details,
                riskScore: severity == IMonitoringHub.Severity.WARNING ? 40 : 10,
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

    function _authorizeUpgrade(address) internal override onlyRole(UPGRADER_ROLE) {
        _logToHub(
            IMonitoringHub.Severity.CRITICAL,
            "UPGRADE",
            "Identity Registry upgrade authorized"
        );
    }

    uint256[43] private _gap;
}
