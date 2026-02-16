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

import { IIdentityRegistry } from "@interfaces/IIdentityRegistry.sol";
import { IMonitoringHub } from "@interfaces/IMonitoringHub.sol";
import { IReputationManager } from "@interfaces/IReputationManager.sol";
import { AOXCErrors } from "@libraries/AOXCErrors.sol";

/**
 * @title AOXCIdentityRegistry
 * @author AOXC Core Engineering
 * @notice Central identity and verification registry for the AOXC Ecosystem.
 * @dev Fully implements IIdentityRegistry with 26-channel forensic monitoring support.
 * This contract acts as the primary source of truth for verified on-chain identities.
 */
contract AOXCIdentityRegistry is
    IIdentityRegistry,
    Initializable,
    AccessControlUpgradeable,
    PausableUpgradeable,
    UUPSUpgradeable
{
    // --- Access Control Roles ---

    /// @notice Role for system administration and high-level configuration.
    bytes32 public constant ADMIN_ROLE = keccak256("AOXC_ADMIN_ROLE");
    /// @notice Role for authorized entities (KYC providers, etc.) to verify identities.
    bytes32 public constant VERIFIER_ROLE = keccak256("AOXC_VERIFIER_ROLE");
    /// @notice Role authorized to execute proxy implementation upgrades.
    bytes32 public constant UPGRADER_ROLE = keccak256("AOXC_UPGRADER_ROLE");

    // --- External Interfaces ---

    /// @notice Reference to the central forensic logging and security monitoring hub.
    IMonitoringHub public monitoringHub;
    /// @notice Reference to the manager handling reputation rewards for verifiers.
    IReputationManager public reputationManager;

    // --- Identity Storage ---

    /// @dev Enumerable array containing all registered account addresses.
    address[] private _registeredAccounts;
    /// @dev Mapping from account address to its unique identity string (e.g., hash of DID).
    mapping(address => string) private _identities;
    /// @dev Internal index mapping to allow O(1) removal from the _registeredAccounts array.
    mapping(address => uint256) private _registeredIndex;

    // --- Events ---

    /// @notice Emitted when a new identity is successfully verified and registered.
    /// @param account The address of the verified user.
    /// @param id The unique identity identifier string.
    /// @param verifier The address of the entity that performed the verification.
    event IdentityRegistered(address indexed account, string id, address indexed verifier);

    /// @notice Emitted when an identity is removed from the registry.
    /// @param account The address of the user being deregistered.
    /// @param verifier The address of the entity that performed the removal.
    event IdentityRemoved(address indexed account, address indexed verifier);

    /// @notice Emitted when an existing identity's metadata is updated.
    /// @param account The address of the user.
    /// @param oldId The previous identity identifier.
    /// @param newId The new identity identifier.
    /// @param verifier The address of the entity that performed the update.
    event IdentityUpdated(
        address indexed account, string oldId, string newId, address indexed verifier
    );

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    /**
     * @notice Initializes the Identity Registry with administrative and dependency addresses.
     * @param admin The address to be granted all initial roles.
     * @param _monitoringHub The address of the pre-deployed MonitoringHub.
     * @param _reputationManager The address of the pre-deployed ReputationManager.
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
        _grantRole(VERIFIER_ROLE, admin);
        _grantRole(UPGRADER_ROLE, admin);

        monitoringHub = IMonitoringHub(_monitoringHub);
        reputationManager = IReputationManager(_reputationManager);

        _logToHub(IMonitoringHub.Severity.INFO, "INITIALIZE", "Identity system online");
    }

    // --- IIdentityRegistry Implementation ---

    /**
     * @notice Registers a new user identity in the system.
     * @dev Only callable by accounts with VERIFIER_ROLE.
     * @param account The wallet address to register.
     * @param id The unique identity string/hash.
     */
    function register(address account, string calldata id)
        external
        override
        onlyRole(VERIFIER_ROLE)
        whenNotPaused
    {
        _register(account, id);
        _rewardVerifier(msg.sender, "IDENTITY_VERIFICATION");
    }

    /**
     * @notice Removes a user identity from the system.
     * @dev Uses the swap-and-pop pattern to maintain array continuity.
     * @param account The wallet address to deregister.
     */
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

    /**
     * @notice Returns the total number of registered users.
     * @return uint256 Total count.
     */
    function getRegisteredCount() external view override returns (uint256) {
        return _registeredAccounts.length;
    }

    /**
     * @notice Checks if an address has a registered identity.
     * @param account The address to check.
     * @return bool True if registered.
     */
    function isRegistered(address account) external view override returns (bool) {
        return bytes(_identities[account]).length > 0;
    }

    /**
     * @notice Retrieves the identity identifier for a specific address.
     * @param account The address to query.
     * @return string The identity string.
     */
    function getIdentity(address account) external view override returns (string memory) {
        return _identities[account];
    }

    /**
     * @notice Returns a list of all registered account addresses.
     * @return address[] Memory array of addresses.
     */
    function getRegisteredAccounts() external view returns (address[] memory) {
        return _registeredAccounts;
    }

    // --- Batch Operations ---

    /**
     * @notice Registers multiple identities in a single batch transaction.
     * @param accounts Array of addresses.
     * @param ids Array of corresponding identity strings.
     */
    function batchRegister(address[] calldata accounts, string[] calldata ids)
        external
        onlyRole(VERIFIER_ROLE)
        whenNotPaused
    {
        uint256 len = accounts.length;
        if (len != ids.length) revert AOXCErrors.InvalidConfiguration();

        for (uint256 i = 0; i < len;) {
            _register(accounts[i], ids[i]);
            unchecked {
                ++i;
            }
        }
        _rewardVerifier(msg.sender, "IDENTITY_BATCH_VERIFICATION");
    }

    // --- Internal Logic ---

    /**
     * @dev Internal helper to process identity registration storage.
     */
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

    /**
     * @dev Internal helper to trigger reputation rewards for verifiers.
     */
    function _rewardVerifier(address verifier, bytes32 actionKey) internal {
        if (address(reputationManager) != address(0)) {
            try reputationManager.processAction(verifier, actionKey) { } catch { }
        }
    }

    /**
     * @dev High-fidelity 26-channel forensic logging.
     * Security: msg.sender is used as origin to comply with Solhint standards.
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
                origin: msg.sender, // Optimized for cross-chain and contract-wallet safety
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

            try monitoringHub.logForensic(log) { } catch { }
        }
    }

    /**
     * @dev Internal authorization for UUPS contract upgrades.
     */
    function _authorizeUpgrade(address) internal override onlyRole(UPGRADER_ROLE) {
        _logToHub(
            IMonitoringHub.Severity.CRITICAL, "UPGRADE", "Identity Registry upgrade authorized"
        );
    }

    /// @dev Storage gap for future upgradeability expansion.
    uint256[43] private _gap;
}
