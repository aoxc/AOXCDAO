// SPDX-License-Identifier: MIT
pragma solidity 0.8.33;

import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {AccessControlUpgradeable} from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import {PausableUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol";

import {IComplianceRegistry} from "@interfaces/IComplianceRegistry.sol";
import {IMonitoringHub} from "@interfaces/IMonitoringHub.sol";
import {IReputationManager} from "@interfaces/IReputationManager.sol";
import {AOXCErrors} from "@libraries/AOXCErrors.sol";

/**
 * @title AOXCComplianceRegistry
 * @author AOXC Core Engineering
 * @notice Centralized compliance and blacklist management for the AOXC ecosystem.
 * @dev Fully implements IComplianceRegistry with 26-channel forensic monitoring.
 * Provides granular control over restricted accounts with reason-based blacklisting.
 */
contract AOXCComplianceRegistry is
    IComplianceRegistry,
    Initializable,
    AccessControlUpgradeable,
    UUPSUpgradeable,
    PausableUpgradeable
{
    // --- Access Control Roles ---

    /// @notice Role for high-level administrative tasks.
    bytes32 public constant ADMIN_ROLE = keccak256("AOXC_ADMIN_ROLE");
    /// @notice Role for legal and compliance officers authorized to manage the blacklist.
    bytes32 public constant COMPLIANCE_OFFICER_ROLE = keccak256("AOXC_COMPLIANCE_OFFICER_ROLE");
    /// @notice Role authorized to trigger contract implementation upgrades.
    bytes32 public constant UPGRADER_ROLE = keccak256("AOXC_UPGRADER_ROLE");

    // --- External Interfaces ---

    /// @notice Reference to the centralized forensic logging and monitoring hub.
    IMonitoringHub public monitoringHub;
    /// @notice Reference to the reputation scoring manager for officer incentives.
    IReputationManager public reputationManager;

    // --- Blacklist Storage ---

    /// @dev Enumerable array of all currently blacklisted addresses.
    address[] private _blacklistedAccounts;
    /// @dev Mapping to check if an address is currently restricted.
    mapping(address => bool) private _blacklisted;
    /// @dev Mapping to store the justification for each blacklist action.
    mapping(address => string) private _blacklistReasons;
    /// @dev Internal mapping for O(1) removal from the _blacklistedAccounts array.
    mapping(address => uint256) private _blacklistIndex;

    // --- Events ---

    /// @notice Emitted when an account is added to the blacklist.
    /// @param account The address being restricted.
    /// @param reason The legal or technical justification for the restriction.
    /// @param officer The address of the officer who performed the action.
    event Blacklisted(address indexed account, string reason, address indexed officer);

    /// @notice Emitted when an account is removed from the blacklist.
    /// @param account The address whose restrictions were lifted.
    /// @param officer The address of the officer who performed the action.
    event Unblacklisted(address indexed account, address indexed officer);

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    /**
     * @notice Initializes the Compliance Registry contract with core dependencies.
     * @param admin The default administrator address.
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
        _grantRole(COMPLIANCE_OFFICER_ROLE, admin);
        _grantRole(UPGRADER_ROLE, admin);

        monitoringHub = IMonitoringHub(_monitoringHub);
        reputationManager = IReputationManager(_reputationManager);

        _logToHub(IMonitoringHub.Severity.INFO, "INITIALIZE", "Compliance system online");
    }

    // --- IComplianceRegistry Implementation ---

    /**
     * @notice Restricts an account from interacting with protected protocol functions.
     * @param account The address to blacklist.
     * @param reason String description of why the account is being blacklisted.
     */
    function addToBlacklist(address account, string calldata reason)
        external
        override
        onlyRole(COMPLIANCE_OFFICER_ROLE)
        whenNotPaused
    {
        _addToBlacklist(account, reason);
        _rewardOfficer(msg.sender, "COMPLIANCE_ACTION");
    }

    /**
     * @notice Lifts restrictions from a previously blacklisted account.
     * @param account The address to restore.
     */
    function removeFromBlacklist(address account) external override onlyRole(COMPLIANCE_OFFICER_ROLE) whenNotPaused {
        if (!_blacklisted[account]) revert AOXCErrors.InvalidConfiguration();

        _removeFromBlacklist(account);
        _rewardOfficer(msg.sender, "COMPLIANCE_REMOVE_ACTION");
    }

    /**
     * @notice Returns the total number of currently blacklisted accounts.
     * @return uint256 Count of restricted addresses.
     */
    function getBlacklistCount() external view override returns (uint256) {
        return _blacklistedAccounts.length;
    }

    /**
     * @notice Checks if a specific account is currently blacklisted.
     * @param account The address to query.
     * @return bool True if the account is restricted.
     */
    function isBlacklisted(address account) external view override returns (bool) {
        return _blacklisted[account];
    }

    /**
     * @notice Retrieves the documented reason for an account's blacklist status.
     * @param account The restricted address.
     * @return string The justification string.
     */
    function getBlacklistReason(address account) external view override returns (string memory) {
        if (!_blacklisted[account]) revert AOXCErrors.InvalidConfiguration();
        return _blacklistReasons[account];
    }

    // --- Batch Operations ---

    /**
     * @notice Processes multiple blacklist entries in a single transaction for gas efficiency.
     * @dev Arrays must have identical lengths.
     * @param accounts Array of addresses to restrict.
     * @param reasons Array of justifications corresponding to each address.
     */
    function batchAddToBlacklist(address[] calldata accounts, string[] calldata reasons)
        external
        onlyRole(COMPLIANCE_OFFICER_ROLE)
        whenNotPaused
    {
        uint256 len = accounts.length;
        if (len != reasons.length) revert AOXCErrors.InvalidConfiguration();

        for (uint256 i = 0; i < len;) {
            _addToBlacklist(accounts[i], reasons[i]);
            unchecked {
                ++i;
            }
        }
        _rewardOfficer(msg.sender, "COMPLIANCE_BATCH_ACTION");
    }

    // --- Internal Logic ---

    /**
     * @dev Internal logic for blacklisting. Updates status, mapping, and enumerable array.
     */
    function _addToBlacklist(address account, string memory reason) internal {
        if (account == address(0)) revert AOXCErrors.ZeroAddressDetected();
        if (_blacklisted[account]) revert AOXCErrors.InvalidConfiguration();
        if (bytes(reason).length == 0) revert AOXCErrors.InvalidConfiguration();

        _blacklisted[account] = true;
        _blacklistReasons[account] = reason;
        _blacklistIndex[account] = _blacklistedAccounts.length;
        _blacklistedAccounts.push(account);

        emit Blacklisted(account, reason, msg.sender);
        _logToHub(IMonitoringHub.Severity.WARNING, "COMPLIANCE_ADD", reason);
    }

    /**
     * @dev Internal logic for unblacklisting using the swap-and-pop pattern to maintain array integrity.
     */
    function _removeFromBlacklist(address account) internal {
        uint256 indexToRemove = _blacklistIndex[account];
        uint256 lastIndex = _blacklistedAccounts.length - 1;

        if (indexToRemove != lastIndex) {
            address lastAccount = _blacklistedAccounts[lastIndex];
            _blacklistedAccounts[indexToRemove] = lastAccount;
            _blacklistIndex[lastAccount] = indexToRemove;
        }

        _blacklistedAccounts.pop();
        _blacklisted[account] = false;
        delete _blacklistReasons[account];
        delete _blacklistIndex[account];

        emit Unblacklisted(account, msg.sender);
        _logToHub(IMonitoringHub.Severity.INFO, "COMPLIANCE_REMOVE", "Account cleared");
    }

    /**
     * @dev Processes officer reputation rewards if the reputation manager is linked.
     */
    function _rewardOfficer(address officer, bytes32 actionKey) internal {
        if (address(reputationManager) != address(0)) {
            try reputationManager.processAction(officer, actionKey) {} catch {}
        }
    }

    /**
     * @dev High-fidelity 26-channel forensic logging.
     * Replaced `tx.origin` with `msg.sender` for security compliance.
     */
    function _logToHub(IMonitoringHub.Severity severity, string memory action, string memory details) internal {
        if (address(monitoringHub) != address(0)) {
            IMonitoringHub.ForensicLog memory log = IMonitoringHub.ForensicLog({
                source: address(this),
                actor: msg.sender,
                origin: msg.sender, // Optimized for security analysis
                related: address(0),
                severity: severity,
                category: "COMPLIANCE",
                details: details,
                riskScore: severity == IMonitoringHub.Severity.WARNING ? 50 : 0,
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
     * @notice Returns the full list of blacklisted accounts.
     * @return address[] Memory array containing all restricted addresses.
     */
    function getBlacklistedAccounts() external view returns (address[] memory) {
        return _blacklistedAccounts;
    }

    /**
     * @dev Internal authorization for UUPS contract upgrades.
     */
    function _authorizeUpgrade(address) internal override onlyRole(UPGRADER_ROLE) {
        _logToHub(IMonitoringHub.Severity.CRITICAL, "UPGRADE", "Compliance Registry upgrade authorized");
    }

    /// @dev Storage gap for future upgradeability expansion.
    uint256[43] private _gap;
}
