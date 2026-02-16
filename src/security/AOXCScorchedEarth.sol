// SPDX-License-Identifier: Proprietary
// Academic Grade - AOXC Catastrophic Recovery & Audit Protocol (Optimized)
pragma solidity 0.8.33;

import {IAOXCAccessCoordinator} from "@interfaces/IAOXCAccessCoordinator.sol";
import {IAOXCSafeguardVault} from "@interfaces/IAOXCSafeguardVault.sol";
import {ITreasury} from "@interfaces/ITreasury.sol";
import {IMonitoringHub} from "@interfaces/IMonitoringHub.sol";
import {AOXCErrors} from "@libraries/AOXCErrors.sol";
import {AOXCConstants} from "@libraries/AOXCConstants.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/**
 * @title AOXCScorchedEarth
 * @notice Protocol Isolation & Audit-Controlled Compensation Module.
 */
contract AOXCScorchedEarth is ReentrancyGuard {
    struct CompensationProposal {
        address victim;
        uint256 amount;
        bool approved;
        bool executed;
    }

    IAOXCAccessCoordinator public immutable COORDINATOR;
    IAOXCSafeguardVault public immutable SAFEGUARD;
    ITreasury public immutable TREASURY;
    address public immutable SOVEREIGN = 0x20c0DD8B6559912acfAC2ce061B8d5b19Db8CA84;

    mapping(uint256 => CompensationProposal) public proposals;
    uint256 public proposalCount;

    event ProposalCreated(uint256 indexed id, address indexed victim, uint256 amount);
    event ProposalAudited(uint256 indexed id, address indexed auditor);
    event CompensationFinalized(uint256 indexed id, address indexed victim);

    constructor(address _coord, address _safe, address _treasury) {
        if (_coord == address(0) || _safe == address(0) || _treasury == address(0)) {
            revert AOXCErrors.InvalidConfiguration();
        }
        COORDINATOR = IAOXCAccessCoordinator(_coord);
        SAFEGUARD = IAOXCSafeguardVault(_safe);
        TREASURY = ITreasury(_treasury);
    }

    function proposeCompensation(address _victim, uint256 _amount) external {
        if (!COORDINATOR.hasSovereignPower(msg.sender)) {
            revert AOXCErrors.Unauthorized(msg.sender);
        }
        
        uint256 id = ++proposalCount;
        proposals[id] = CompensationProposal({
            victim: _victim,
            amount: _amount,
            approved: false,
            executed: false
        });

        _logToHub(IMonitoringHub.Severity.INFO, "COMP_PROPOSAL", "Pending Audit");
        emit ProposalCreated(id, _victim, _amount);
    }

    function approveCompensation(uint256 _id) external {
        // DÜZELTME: Undeclared identifier hatası için merkezi hata kütüphanesi kullanıldı.
        if (!COORDINATOR.isOperationAllowed(AOXCConstants.AUDITOR_ROLE, msg.sender)) {
            revert AOXCErrors.Unauthorized(msg.sender);
        }
        
        CompensationProposal storage p = proposals[_id];
        if (p.victim == address(0) || p.approved) revert AOXCErrors.InvalidConfiguration();
        
        p.approved = true;
        _logToHub(IMonitoringHub.Severity.WARNING, "COMP_APPROVED", "Audit Complete");
        emit ProposalAudited(_id, msg.sender);
    }

    function executeCompensation(uint256 _id) external nonReentrant {
        CompensationProposal storage p = proposals[_id];
        if (!p.approved || p.executed) revert AOXCErrors.InvalidConfiguration();

        p.executed = true;
        SAFEGUARD.releaseCompensation(p.victim, p.amount);

        _logToHub(IMonitoringHub.Severity.INFO, "COMP_EXECUTED", "Aid Finalized");
        emit CompensationFinalized(_id, p.victim);
    }

    function _logToHub(IMonitoringHub.Severity severity, string memory category, string memory details) internal {
        IMonitoringHub hub = COORDINATOR.monitoringHub();
        if (address(hub) != address(0)) {
            hub.logForensic(IMonitoringHub.ForensicLog({
                source: address(this), actor: msg.sender, origin: tx.origin, related: address(0),
                severity: severity, category: category, details: details, riskScore: 20,
                nonce: 0, chainId: block.chainid, blockNumber: block.number, timestamp: block.timestamp,
                gasUsed: gasleft(), value: 0, stateRoot: bytes32(0), txHash: bytes32(0),
                selector: msg.sig, version: 1, actionReq: false, isUpgraded: false,
                environment: 1, correlationId: bytes32(0), policyHash: bytes32(0), sequenceId: 0,
                metadata: "", proof: ""
            }));
        }
    }
}
