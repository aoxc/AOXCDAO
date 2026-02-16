// SPDX-License-Identifier: Proprietary
// Academic Grade - AOXC Operational Command Interface
pragma solidity 0.8.33;

import {IAOXCAccessCoordinator} from "@interfaces/IAOXCAccessCoordinator.sol";
import {IMonitoringHub} from "@interfaces/IMonitoringHub.sol";
import {AOXCErrors} from "@libraries/AOXCErrors.sol";

/**
 * @title AOXCSovereignCommander
 * @notice Centralized interface for modular sector isolation and forensic response.
 */
contract AOXCSovereignCommander {
    IAOXCAccessCoordinator public immutable COORDINATOR;
    address public immutable SOVEREIGN = 0x20c0DD8B6559912acfAC2ce061B8d5b19Db8CA84;

    event SectorIsolationTriggered(bytes32 indexed sectorId, string reason);

    constructor(address _coordinator) {
        COORDINATOR = IAOXCAccessCoordinator(_coordinator);
    }

    /**
     * @notice Freezes a specific sector in response to an anomaly.
     */
    function isolateSector(bytes32 _sectorId, string calldata _reason) external {
        if (msg.sender != SOVEREIGN && !COORDINATOR.hasSovereignPower(msg.sender)) {
            revert AOXCErrors.Unauthorized(msg.sender);
        }

        COORDINATOR.setSectorStatus(_sectorId, false);
        _logToHub(IMonitoringHub.Severity.CRITICAL, "SECTOR_ISOLATION", _reason);
        emit SectorIsolationTriggered(_sectorId, _reason);
    }

    function _logToHub(IMonitoringHub.Severity severity, string memory category, string memory details) internal {
        IMonitoringHub hub = COORDINATOR.monitoringHub();
        if (address(hub) != address(0)) {
            hub.logForensic(IMonitoringHub.ForensicLog({
                source: address(this), actor: msg.sender, origin: tx.origin, related: address(0),
                severity: severity, category: category, details: details, riskScore: 90,
                nonce: 0, chainId: block.chainid, blockNumber: block.number, timestamp: block.timestamp,
                gasUsed: gasleft(), value: 0, stateRoot: bytes32(0), txHash: bytes32(0),
                selector: msg.sig, version: 1, actionReq: true, isUpgraded: false,
                environment: 1, correlationId: bytes32(0), policyHash: bytes32(0), sequenceId: 0,
                metadata: "", proof: ""
            }));
        }
    }
}
