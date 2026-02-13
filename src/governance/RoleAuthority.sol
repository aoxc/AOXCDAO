// SPDX-License-Identifier: MIT
pragma solidity 0.8.33;

import { Initializable } from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {
    AccessControlEnumerableUpgradeable
} from "@openzeppelin/contracts-upgradeable/access/extensions/AccessControlEnumerableUpgradeable.sol";
import {
    PausableUpgradeable
} from "@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol";
import {
    UUPSUpgradeable
} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";
import { IMonitoringHub } from "../interfaces/IMonitoringHub.sol";

contract RoleAuthority is
    Initializable,
    AccessControlEnumerableUpgradeable,
    PausableUpgradeable,
    UUPSUpgradeable
{
    using Strings for address;

    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");
    IMonitoringHub public monitoringHub;

    error AOXC__ZeroAddress();

    constructor() {
        _disableInitializers();
    }

    function initialize(address admin, IMonitoringHub _monitoringHub) external initializer {
        if (admin == address(0) || address(_monitoringHub) == address(0)) {
            revert AOXC__ZeroAddress();
        }
        __AccessControlEnumerable_init();
        __Pausable_init();
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(ADMIN_ROLE, admin);
        _grantRole(UPGRADER_ROLE, admin);
        monitoringHub = _monitoringHub;
        _logToHub(IMonitoringHub.Severity.INFO, "INITIALIZE", "RoleAuthority activated");
    }

    function _logToHub(
        IMonitoringHub.Severity severity,
        string memory action,
        string memory details
    ) internal {
        if (address(monitoringHub) != address(0)) {
            // 26-Channel Forensic Standard
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
            try monitoringHub.logForensic(log) { } catch { }
        }
    }

    function _authorizeUpgrade(address) internal override onlyRole(UPGRADER_ROLE) { }
    uint256[40] private _gap;
}
