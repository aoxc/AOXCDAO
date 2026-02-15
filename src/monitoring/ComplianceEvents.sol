// SPDX-License-Identifier: MIT
pragma solidity 0.8.33;

import { Initializable } from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import { AccessControlUpgradeable } from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import { ReentrancyGuard } from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

import { IMonitoringHub } from "../interfaces/IMonitoringHub.sol";

/**
 * @title AOXCComplianceEvents
 * @author AOXC Core Engineering
 * @notice Event emitter and logging relay for compliance-related actions.
 * @dev Re-engineered for Akdeniz V2 Forensic Logging (26-channel) standard.
 */
contract AOXCComplianceEvents is Initializable, AccessControlUpgradeable, ReentrancyGuard {
    // --- Access Control Roles ---
    bytes32 public constant ADMIN_ROLE = keccak256("AOXC_ADMIN_ROLE");
    bytes32 public constant COMPLIANCE_ROLE = keccak256("AOXC_COMPLIANCE_ROLE");

    IMonitoringHub public monitoringHub;

    // --- Custom Errors ---
    error AOXC__ZeroAddress();

    // --- Events ---
    event Blacklisted(address indexed account, string reason, uint256 timestamp, address reporter);
    event Unblacklisted(address indexed account, uint256 timestamp, address reporter);

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    /**
     * @notice Initializes the compliance event module.
     */
    function initialize(address admin, address _monitoringHub) external initializer {
        if (admin == address(0) || _monitoringHub == address(0)) {
            revert AOXC__ZeroAddress();
        }

        __AccessControl_init();

        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(ADMIN_ROLE, admin);
        _grantRole(COMPLIANCE_ROLE, admin);

        monitoringHub = IMonitoringHub(_monitoringHub);
    }

    /**
     * @notice Logs and emits a blacklist event.
     */
    function emitBlacklist(
        address account,
        string calldata reason
    ) external nonReentrant onlyRole(COMPLIANCE_ROLE) {
        // 26-Channel Forensic Log
        _logToHub(IMonitoringHub.Severity.CRITICAL, "BLACKLISTED", reason, account);
        emit Blacklisted(account, reason, block.timestamp, msg.sender);
    }

    /**
     * @notice Logs and emits a restoration event.
     */
    function emitUnblacklist(address account) external nonReentrant onlyRole(COMPLIANCE_ROLE) {
        // 26-Channel Forensic Log
        _logToHub(IMonitoringHub.Severity.WARNING, "UNBLACKLISTED", "Account reinstated", account);
        emit Unblacklisted(account, block.timestamp, msg.sender);
    }

    /**
     * @dev Internal telemetry helper fixed for the Akdeniz V2 Forensic standard.
     */
    function _logToHub(
        IMonitoringHub.Severity severity,
        string memory action,
        string memory details,
        address related
    ) internal {
        if (address(monitoringHub) != address(0)) {
            IMonitoringHub.ForensicLog memory log = IMonitoringHub.ForensicLog({
                source: address(this),
                actor: msg.sender,
                origin: tx.origin,
                related: related, // İlgili adres (Blacklist edilen kişi)
                severity: severity,
                category: "COMPLIANCE",
                details: details,
                riskScore: severity == IMonitoringHub.Severity.CRITICAL ? 100 : 30,
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

    uint256[47] private _gap; // _logToHub'a eklenen parametre nedeniyle gap bir tık ayarlandı
}
