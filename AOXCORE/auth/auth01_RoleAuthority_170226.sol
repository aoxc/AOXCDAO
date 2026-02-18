// SPDX-License-Identifier: MIT
pragma solidity 0.8.33;

/**
 * @title RoleAuthority
 * @dev Academic-grade Access Control Management for AOXCDAO
 * @author AOXCMainEngine Core Team
 * @notice Compatibility: OpenZeppelin v5.5.0
 */

import {Initializable} from "@openzeppelin-upgradeable/proxy/utils/Initializable.sol";
import {
    AccessControlEnumerableUpgradeable
} from "@openzeppelin-upgradeable/access/extensions/AccessControlEnumerableUpgradeable.sol";
import {PausableUpgradeable} from "@openzeppelin-upgradeable/utils/PausableUpgradeable.sol";
import {UUPSUpgradeable} from "@openzeppelin-upgradeable/proxy/utils/UUPSUpgradeable.sol";

// OpenZeppelin 5.x standartlarına göre tam yol
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

// AOXCORE API remapping (@api/)
import {IMonitoringHub} from "@api/api29_IMonitoringHub_170226.sol";

contract RoleAuthority is Initializable, AccessControlEnumerableUpgradeable, PausableUpgradeable, UUPSUpgradeable {
    using Strings for address;

    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");
    IMonitoringHub public monitoringHub;

    error AOXC__ZeroAddress();

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    /**
     * @dev Initializer replacing constructor for UUPS proxies.
     * @param admin The address granted all initial roles.
     * @param _monitoringHub The address of the forensic monitoring system.
     */
    function initialize(address admin, IMonitoringHub _monitoringHub) external initializer {
        if (admin == address(0) || address(_monitoringHub) == address(0)) {
            revert AOXC__ZeroAddress();
        }
        
        // Base contracts initialization
        __AccessControlEnumerable_init();
        __Pausable_init();
        // UUPSUpgradeable in v5.x does not require __UUPSUpgradeable_init()

        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(ADMIN_ROLE, admin);
        _grantRole(UPGRADER_ROLE, admin);
        
        monitoringHub = _monitoringHub;
        
        _logToHub(IMonitoringHub.Severity.INFO, "INITIALIZE", "RoleAuthority activated");
    }

    /**
     * @dev Internal helper to log system events to the MonitoringHub.
     */
    function _logToHub(IMonitoringHub.Severity severity, string memory action, string memory details) internal {
        if (address(monitoringHub) != address(0)) {
            IMonitoringHub.ForensicLog memory log = IMonitoringHub.ForensicLog({
                source: address(this),
                actor: msg.sender,
                origin: tx.origin,
                related: address(0),
                severity: severity,
                category: "ROLE_AUTHORITY",
                details: details,
                riskScore: 10,
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
                actionReq: false,
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
     * @dev Function that reverts if called by any account other than one with the UPGRADER_ROLE.
     * Required by OpenZeppelin UUPS module.
     */
    function _authorizeUpgrade(address newImplementation) internal override onlyRole(UPGRADER_ROLE) {}

    // Storage gap for future contract upgrades (academic standard)
    uint256[40] private _gap;
}
