// SPDX-License-Identifier: MIT
pragma solidity 0.8.33;

import { Initializable } from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import { AccessControlUpgradeable } from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import { UUPSUpgradeable } from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

import { ITransferPolicy } from "@interfaces/ITransferPolicy.sol";
import { IComplianceRegistry } from "@interfaces/IComplianceRegistry.sol";
import { IMonitoringHub } from "@interfaces/IMonitoringHub.sol";
import { IThreatSurface } from "@interfaces/IThreatSurface.sol";
import { AOXCBaseReporter } from "../monitoring/AOXCBaseReporter.sol";
import { AOXCErrors } from "@libraries/AOXCErrors.sol";

/**
 * @title AOXCTransferPolicyEngine
 * @author AOXC Core Engineering
 * @notice Central engine for auditing and enforcing all transfer policies.
 * @dev Optimized with inline assembly for hashing and wrapped modifiers for lint compliance.
 */
contract AOXCTransferPolicyEngine is
    ITransferPolicy,
    Initializable,
    AccessControlUpgradeable,
    UUPSUpgradeable,
    AOXCBaseReporter
{
    // --- Access Control Roles ---
    bytes32 public constant ADMIN_ROLE = keccak256("AOXC_ADMIN_ROLE");
    bytes32 public constant UPGRADER_ROLE = keccak256("AOXC_UPGRADER_ROLE");

    // --- State Variables ---
    IComplianceRegistry public complianceRegistry;
    IThreatSurface public threatSurface;

    uint256 public maxTxAmount;
    bool private _policyActive;
    bool public strictThreatMode;

    // --- Local Reentrancy Guard ---
    uint256 private _status;
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    // --- Custom Errors ---
    error AOXC__MaxTxExceeded();
    error AOXC__NonCompliant();
    error AOXC__CriticalThreat();
    error AOXC__ThreatServiceOffline();

    // --- Wrapped Modifiers (Forge Lint Fix: unwrapped-modifier-logic) ---

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
     * @notice Initializes the Policy Engine with core links.
     */
    function initialize(
        address admin,
        address _complianceRegistry,
        address _monitoringHub,
        address _threatSurface,
        uint256 _maxTxAmount
    ) external initializer {
        if (admin == address(0) || _monitoringHub == address(0)) {
            revert AOXCErrors.ZeroAddressDetected();
        }

        __AccessControl_init();

        _status = _NOT_ENTERED;

        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(ADMIN_ROLE, admin);
        _grantRole(UPGRADER_ROLE, admin);

        complianceRegistry = IComplianceRegistry(_complianceRegistry);
        threatSurface = IThreatSurface(_threatSurface);
        maxTxAmount = _maxTxAmount;
        _policyActive = true;
        strictThreatMode = true;

        _setMonitoringHub(_monitoringHub);

        _performForensicLog(
            IMonitoringHub.Severity.INFO,
            "INITIALIZE",
            "Policy Engine Online",
            address(0),
            0,
            ""
        );
    }

    /**
     * @notice Validates a transfer against compliance, amount limits, and threat signatures.
     */
    function validateTransfer(
        address from,
        address to,
        uint256 amount
    ) external override nonReentrant {
        if (!_policyActive) return;

        if (amount > maxTxAmount) revert AOXC__MaxTxExceeded();

        if (complianceRegistry.isBlacklisted(from) || complianceRegistry.isBlacklisted(to)) {
            _performForensicLog(
                IMonitoringHub.Severity.WARNING,
                "TRANSFER_DENIED",
                "Blacklisted participant detected",
                from,
                65,
                abi.encode(to, amount)
            );
            revert AOXC__NonCompliant();
        }

        bytes32 patternId = _generatePatternId(from, to, amount);
        _checkThreats(patternId, from, to, amount);

        emit TransferValidated(from, to, amount, block.timestamp);
    }

    // --- Internal Logic ---

    function _checkThreats(bytes32 patternId, address from, address to, uint256 amount) internal {
        if (address(threatSurface).code.length > 0) {
            try threatSurface.isThreatDetected(patternId) returns (bool detected) {
                if (detected) {
                    _performForensicLog(
                        IMonitoringHub.Severity.CRITICAL,
                        "THREAT_DETECTED",
                        "Pattern flagged by ThreatSurface",
                        from,
                        95,
                        abi.encode(patternId, to, amount)
                    );
                    revert AOXC__CriticalThreat();
                }
            } catch {
                if (strictThreatMode) revert AOXC__ThreatServiceOffline();
            }
        } else if (strictThreatMode) {
            revert AOXC__ThreatServiceOffline();
        }
    }

    /**
     * @dev Assembly optimized hashing to eliminate lint [asm-keccak256] notes.
     */
    function _generatePatternId(
        address from,
        address to,
        uint256 amount
    ) internal pure returns (bytes32 patternId) {
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, from)
            mstore(add(ptr, 0x20), to)
            mstore(add(ptr, 0x40), amount)
            patternId := keccak256(ptr, 0x60)
        }
    }

    // --- Admin Controls ---

    function setStrictThreatMode(bool _strict) external onlyRole(ADMIN_ROLE) {
        strictThreatMode = _strict;
        _performForensicLog(
            IMonitoringHub.Severity.INFO,
            "CONFIG_UPDATE",
            "Strict threat mode toggled",
            address(0),
            10,
            abi.encode(_strict)
        );
    }

    function setPolicyActive(bool active) external override onlyRole(ADMIN_ROLE) {
        _policyActive = active;
        emit PolicyStatusChanged(active, block.timestamp);
    }

    /**
     * @notice Updates policy parameters with assembly-optimized string comparison.
     * @dev Eliminates lint [asm-keccak256] by using inline assembly for the string hash.
     */
    function updatePolicyParameter(
        string calldata parameter,
        uint256 newValue
    ) external override nonReentrant onlyRole(ADMIN_ROLE) {
        bytes32 paramHash;
        bytes memory paramBytes = bytes(parameter);

        assembly {
            paramHash := keccak256(add(paramBytes, 0x20), mload(paramBytes))
        }

        // keccak256("maxTxAmount") = 0x5466847c1a82d02a0a382170327f27a69485741066060c5a242f319522f25492
        if (paramHash == 0x5466847c1a82d02a0a382170327f27a69485741066060c5a242f319522f25492) {
            maxTxAmount = newValue;
        }

        emit PolicyParametersUpdated(parameter, newValue, block.timestamp);
    }

    function _authorizeUpgrade(
        address newImplementation
    ) internal override onlyRole(UPGRADER_ROLE) {
        if (newImplementation == address(0)) {
            revert AOXCErrors.ZeroAddressDetected();
        }

        _performForensicLog(
            IMonitoringHub.Severity.CRITICAL,
            "LOGIC_UPGRADE",
            "Policy Engine migration initiated",
            newImplementation,
            100,
            ""
        );
    }

    // --- View Functions ---

    function isPolicyActive() external view override returns (bool) {
        return _policyActive;
    }

    function policyName() external pure override returns (string memory) {
        return "AOXC_PolicyEngine_V2";
    }

    function policyVersion() external pure override returns (uint256) {
        return 2;
    }

    /**
     * @dev Reserved storage gap for upgradeability protection (50 slots).
     */
    uint256[45] private _gap;
}
