// SPDX-License-Identifier: MIT
pragma solidity 0.8.33;

import {Initializable} from "@openzeppelin-upgradeable/proxy/utils/Initializable.sol";
import {
    AccessControlEnumerableUpgradeable
} from "@openzeppelin-upgradeable/access/extensions/AccessControlEnumerableUpgradeable.sol";
import {PausableUpgradeable} from "@openzeppelin-upgradeable/utils/PausableUpgradeable.sol";
import {UUPSUpgradeable} from "@openzeppelin-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

import {IAOXCUpgradeAuthorizer} from "@api/api04_IAoxcUpgradeAuthorizer_170226.sol";
import {IMonitoringHub} from "@api/api29_IMonitoringHub_170226.sol";

/**
 * @title AOXCUpgradeAuthorizer
 * @author AOXCMainEngine Core Engineering
 * @notice Enterprise-grade multi-sig approval and rate-limiting mechanism for AOXCMainEngine upgrades.
 * @dev Fully compliant with 26-channel MonitoringHub forensic standards.
 */
contract AOXCUpgradeAuthorizer is
    Initializable,
    AccessControlEnumerableUpgradeable,
    PausableUpgradeable,
    UUPSUpgradeable,
    ReentrancyGuard,
    IAOXCUpgradeAuthorizer
{
    // --- Access Control Roles ---
    bytes32 public constant UPGRADE_ADMIN_ROLE = keccak256("AOXC_UPGRADE_ADMIN_ROLE");

    // --- State Variables ---
    IMonitoringHub public monitoringHub;
    uint256 public lastUpgradeTimestamp;
    uint256 public minUpgradeInterval;

    // Multi-sig state tracking
    uint256 public upgradeNonce;
    uint256 public requiredApprovals;

    // nonce => implementation_address => approval_count
    mapping(uint256 => mapping(address => uint256)) public implementationApprovals;
    // nonce => implementation_address => admin => has_approved
    mapping(uint256 => mapping(address => mapping(address => bool))) private _hasApproved;

    // --- Standardized Errors ---
    error AOXC__UnauthorizedCaller(address caller);
    error AOXC__ZeroAddress();
    error AOXC__InsufficientApprovals(uint256 required, uint256 current);
    error AOXC__UpgradeRateLimited(uint256 nextAvailable);
    error AOXC__AlreadyApproved();
    error AOXC__InvalidImplementation();

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    /**
     * @notice Initializes the Upgrade Authorizer.
     */
    function initialize(address admin, address _monitoringHub, uint256 _requiredApprovals, uint256 _minInterval)
        external
        initializer
    {
        if (admin == address(0) || _monitoringHub == address(0)) {
            revert AOXC__ZeroAddress();
        }

        __AccessControlEnumerable_init();
        __Pausable_init();

        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(UPGRADE_ADMIN_ROLE, admin);

        monitoringHub = IMonitoringHub(_monitoringHub);
        requiredApprovals = _requiredApprovals > 0 ? _requiredApprovals : 1;
        minUpgradeInterval = _minInterval;

        _logToHub(IMonitoringHub.Severity.INFO, "INITIALIZE", "Upgrade Authorizer Online");
    }

    /**
     * @notice Casts a vote for a specific new implementation address.
     */
    function approveUpgrade(address newImplementation) external onlyRole(UPGRADE_ADMIN_ROLE) whenNotPaused {
        if (newImplementation == address(0)) {
            revert AOXC__ZeroAddress();
        }
        if (_hasApproved[upgradeNonce][newImplementation][msg.sender]) {
            revert AOXC__AlreadyApproved();
        }

        _hasApproved[upgradeNonce][newImplementation][msg.sender] = true;
        implementationApprovals[upgradeNonce][newImplementation]++;

        _logToHub(IMonitoringHub.Severity.INFO, "UPGRADE_VOTE", "Admin approval recorded");
    }

    /**
     * @notice Validates an upgrade request during the UUPS transaction lifecycle.
     */
    function validateUpgrade(address caller, address newImplementation) external override whenNotPaused nonReentrant {
        if (!hasRole(UPGRADE_ADMIN_ROLE, caller)) revert AOXC__UnauthorizedCaller(caller);

        if (block.timestamp < lastUpgradeTimestamp + minUpgradeInterval) {
            revert AOXC__UpgradeRateLimited(lastUpgradeTimestamp + minUpgradeInterval);
        }

        uint256 currentCount = implementationApprovals[upgradeNonce][newImplementation];
        if (currentCount < requiredApprovals) {
            revert AOXC__InsufficientApprovals(requiredApprovals, currentCount);
        }

        upgradeNonce++;
        lastUpgradeTimestamp = block.timestamp;

        _logToHub(IMonitoringHub.Severity.CRITICAL, "UPGRADE_AUTHORIZED", "Consensus reached");
    }

    // --- Configuration Controls ---

    function setRequiredApprovals(uint256 newRequired) external onlyRole(DEFAULT_ADMIN_ROLE) {
        requiredApprovals = newRequired;
        _logToHub(IMonitoringHub.Severity.WARNING, "CONFIG_CHANGE", "Threshold updated");
    }

    function setMinInterval(uint256 newInterval) external onlyRole(DEFAULT_ADMIN_ROLE) {
        minUpgradeInterval = newInterval;
        _logToHub(IMonitoringHub.Severity.WARNING, "CONFIG_CHANGE", "Rate-limit adjusted");
    }

    // --- View Helpers ---

    function isUpgradeAuthorized(address implementation) external view override returns (bool) {
        return implementationApprovals[upgradeNonce][implementation] >= requiredApprovals;
    }

    function getAuthorizerVersion() external pure override returns (uint256) {
        return 6; // Version incremented for Forensic Struct integration
    }

    /**
     * @dev High-fidelity 26-channel forensic logging.
     */
    function _logToHub(IMonitoringHub.Severity severity, string memory action, string memory details) internal {
        if (address(monitoringHub) != address(0)) {
            IMonitoringHub.ForensicLog memory log = IMonitoringHub.ForensicLog({
                source: address(this),
                actor: msg.sender,
                origin: tx.origin,
                related: address(0),
                severity: severity,
                category: "GOVERNANCE_UPGRADE",
                details: details,
                riskScore: severity == IMonitoringHub.Severity.CRITICAL ? 90 : 20,
                nonce: upgradeNonce,
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

    function _authorizeUpgrade(address) internal override onlyRole(DEFAULT_ADMIN_ROLE) {
        _logToHub(IMonitoringHub.Severity.CRITICAL, "SELF_UPGRADE", "Authorizer upgrading");
    }

    uint256[41] private _gap;
}
