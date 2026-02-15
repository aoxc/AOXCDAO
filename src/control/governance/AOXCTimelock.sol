// SPDX-License-Identifier: MIT
pragma solidity 0.8.33;

import { Initializable } from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import { TimelockControllerUpgradeable } from "@openzeppelin/contracts-upgradeable/governance/TimelockControllerUpgradeable.sol";
import { UUPSUpgradeable } from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import { IMonitoringHub } from "@interfaces/IMonitoringHub.sol";
import { AOXCErrors } from "@libraries/AOXCErrors.sol";

contract AOXCTimelock is Initializable, TimelockControllerUpgradeable, UUPSUpgradeable {
    IMonitoringHub public monitoringHub;
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");

    event UpgradeAuthorized(address indexed newImplementation);

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(
        uint256 minDelay,
        address[] memory proposers,
        address[] memory executors,
        address admin,
        address _monitoring
    ) external initializer {
        if (_monitoring == address(0) || admin == address(0)) {
            revert AOXCErrors.ZeroAddressDetected();
        }
        __TimelockController_init(minDelay, proposers, executors, admin);
        monitoringHub = IMonitoringHub(_monitoring);
        _grantRole(UPGRADER_ROLE, admin);
        _logToHub(IMonitoringHub.Severity.INFO, "INITIALIZE", "Fortress Timelock Online");
    }

    function _logToHub(
        IMonitoringHub.Severity severity,
        string memory action,
        string memory details
    ) internal {
        if (address(monitoringHub) != address(0)) {
            // Struct 26 kanal standardına (action alanı detaylara gömülerek) çekildi
            IMonitoringHub.ForensicLog memory log = IMonitoringHub.ForensicLog({
                source: address(this),
                actor: msg.sender,
                origin: tx.origin,
                related: address(0),
                severity: severity,
                category: "GOVERNANCE",
                details: string(abi.encodePacked(action, ": ", details)),
                riskScore: severity >= IMonitoringHub.Severity.WARNING ? 60 : 10,
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
                metadata: abi.encode(action),
                proof: ""
            });
            try monitoringHub.logForensic(log) {} catch {}
        }
    }

    function _authorizeUpgrade(
        address newImplementation
    ) internal override onlyRole(UPGRADER_ROLE) {
        if (newImplementation == address(0)) {
            revert AOXCErrors.ZeroAddressDetected();
        }
        emit UpgradeAuthorized(newImplementation);
        _logToHub(IMonitoringHub.Severity.CRITICAL, "UPGRADE", "Infrastructure migration");
    }

    uint256[43] private _gap;
}
