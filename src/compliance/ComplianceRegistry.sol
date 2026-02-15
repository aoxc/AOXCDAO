// SPDX-License-Identifier: MIT
pragma solidity 0.8.33;

import { Initializable } from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import { AccessControlUpgradeable } from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import { UUPSUpgradeable } from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import { PausableUpgradeable } from "@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol";

import { IComplianceRegistry } from "../interfaces/IComplianceRegistry.sol";
import { IMonitoringHub } from "../interfaces/IMonitoringHub.sol";
import { IReputationManager } from "../interfaces/IReputationManager.sol";
import { AOXCErrors } from "../libraries/AOXCErrors.sol";

/**
 * @title AOXCComplianceRegistry
 * @author AOXC Core Engineering
 * @notice Centralized compliance and blacklist management for the AOXC ecosystem.
 * @dev Fully implements IComplianceRegistry with 26-channel forensic monitoring.
 */
contract AOXCComplianceRegistry is
    IComplianceRegistry,
    Initializable,
    AccessControlUpgradeable,
    UUPSUpgradeable,
    PausableUpgradeable
{
    // --- Access Control Roles ---
    bytes32 public constant ADMIN_ROLE = keccak256("AOXC_ADMIN_ROLE");
    bytes32 public constant COMPLIANCE_OFFICER_ROLE = keccak256("AOXC_COMPLIANCE_OFFICER_ROLE");
    bytes32 public constant UPGRADER_ROLE = keccak256("AOXC_UPGRADER_ROLE");

    // --- External Interfaces ---
    IMonitoringHub public monitoringHub;
    IReputationManager public reputationManager;

    // --- Blacklist Storage ---
    address[] private _blacklistedAccounts;
    mapping(address => bool) private _blacklisted;
    mapping(address => string) private _blacklistReasons;
    mapping(address => uint256) private _blacklistIndex;

    // --- Events ---
    event Blacklisted(address indexed account, string reason, address indexed officer);
    event Unblacklisted(address indexed account, address indexed officer);

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    /**
     * @notice Initializes the Compliance Registry contract.
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
        _grantRole(COMPLIANCE_OFFICER_ROLE, admin);
        _grantRole(UPGRADER_ROLE, admin);

        monitoringHub = IMonitoringHub(_monitoringHub);
        reputationManager = IReputationManager(_reputationManager);

        _logToHub(IMonitoringHub.Severity.INFO, "INITIALIZE", "Compliance system online");
    }

    // --- IComplianceRegistry Implementation ---

    function addToBlacklist(
        address account,
        string calldata reason
    ) external override onlyRole(COMPLIANCE_OFFICER_ROLE) whenNotPaused {
        _addToBlacklist(account, reason);
        _rewardOfficer(msg.sender, "COMPLIANCE_ACTION");
    }

    function removeFromBlacklist(
        address account
    ) external override onlyRole(COMPLIANCE_OFFICER_ROLE) whenNotPaused {
        if (!_blacklisted[account]) revert AOXCErrors.InvalidConfiguration();

        _removeFromBlacklist(account);
        _rewardOfficer(msg.sender, "COMPLIANCE_REMOVE_ACTION");
    }

    function getBlacklistCount() external view override returns (uint256) {
        return _blacklistedAccounts.length;
    }

    function isBlacklisted(address account) external view override returns (bool) {
        return _blacklisted[account];
    }

    function getBlacklistReason(address account) external view override returns (string memory) {
        if (!_blacklisted[account]) revert AOXCErrors.InvalidConfiguration();
        return _blacklistReasons[account];
    }

    // --- Batch Operations ---

    function batchAddToBlacklist(
        address[] calldata accounts,
        string[] calldata reasons
    ) external onlyRole(COMPLIANCE_OFFICER_ROLE) whenNotPaused {
        uint256 len = accounts.length;
        if (len != reasons.length) revert AOXCErrors.InvalidConfiguration();

        for (uint256 i = 0; i < len; ) {
            _addToBlacklist(accounts[i], reasons[i]);
            unchecked {
                ++i;
            }
        }
        _rewardOfficer(msg.sender, "COMPLIANCE_BATCH_ACTION");
    }

    // --- Internal Logic ---

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

    function _rewardOfficer(address officer, bytes32 actionKey) internal {
        if (address(reputationManager) != address(0)) {
            try reputationManager.processAction(officer, actionKey) {} catch {}
        }
    }

    /**
     * @dev Implementation of high-fidelity 26-channel forensic logging.
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
                environment: 0, // 0: Production
                correlationId: bytes32(0),
                policyHash: bytes32(0),
                sequenceId: 0,
                metadata: abi.encodePacked(action),
                proof: ""
            });

            try monitoringHub.logForensic(log) {} catch {}
        }
    }

    function getBlacklistedAccounts() external view returns (address[] memory) {
        return _blacklistedAccounts;
    }

    function _authorizeUpgrade(address) internal override onlyRole(UPGRADER_ROLE) {
        _logToHub(
            IMonitoringHub.Severity.CRITICAL,
            "UPGRADE",
            "Compliance Registry upgrade authorized"
        );
    }

    uint256[43] private _gap;
}
