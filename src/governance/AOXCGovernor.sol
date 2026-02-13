// SPDX-License-Identifier: MIT
pragma solidity 0.8.33;

import { Initializable } from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {
    AccessControlUpgradeable
} from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import {
    PausableUpgradeable
} from "@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol";
import {
    UUPSUpgradeable
} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import {
    GovernorUpgradeable
} from "@openzeppelin/contracts-upgradeable/governance/GovernorUpgradeable.sol";
import {
    GovernorCountingSimpleUpgradeable
} from "@openzeppelin/contracts-upgradeable/governance/extensions/GovernorCountingSimpleUpgradeable.sol";
import {
    GovernorVotesUpgradeable
} from "@openzeppelin/contracts-upgradeable/governance/extensions/GovernorVotesUpgradeable.sol";
import {
    GovernorTimelockControlUpgradeable
} from "@openzeppelin/contracts-upgradeable/governance/extensions/GovernorTimelockControlUpgradeable.sol";
import {
    TimelockControllerUpgradeable
} from "@openzeppelin/contracts-upgradeable/governance/TimelockControllerUpgradeable.sol";
import { IVotes } from "@openzeppelin/contracts/governance/utils/IVotes.sol";

import { IReputationManager } from "../interfaces/IReputationManager.sol";
import { IMonitoringHub } from "../interfaces/IMonitoringHub.sol";
import { AOXCErrors } from "../libraries/AOXCErrors.sol";

/**
 * @title AOXCGovernor
 * @author AOXC Core Engineering
 * @notice Reputation-weighted DAO governance system with high-fidelity forensic logging.
 */
contract AOXCGovernor is
    Initializable,
    GovernorUpgradeable,
    GovernorCountingSimpleUpgradeable,
    GovernorVotesUpgradeable,
    GovernorTimelockControlUpgradeable,
    PausableUpgradeable,
    AccessControlUpgradeable,
    UUPSUpgradeable
{
    // --- Access Control Roles ---
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");
    bytes32 public constant VETO_ROLE = keccak256("VETO_ROLE");

    // --- State Variables ---
    IReputationManager public reputationManager;
    IMonitoringHub public monitoringHub;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    /**
     * @notice Bootstrap the governance ecosystem.
     */
    function initialize(
        IVotes _token,
        TimelockControllerUpgradeable _timelock,
        address _admin,
        IReputationManager _reputationManager,
        IMonitoringHub _monitoringHub
    ) public initializer {
        if (_admin == address(0) || address(_monitoringHub) == address(0)) {
            revert AOXCErrors.ZeroAddressDetected();
        }

        __Governor_init("AOXCGovernor");
        __GovernorVotes_init(_token);
        __GovernorTimelockControl_init(_timelock);
        __AccessControl_init();
        __Pausable_init();

        reputationManager = _reputationManager;
        monitoringHub = _monitoringHub;

        _grantRole(DEFAULT_ADMIN_ROLE, _admin);
        _grantRole(UPGRADER_ROLE, _admin);
        _grantRole(VETO_ROLE, _admin);

        _logToHub(IMonitoringHub.Severity.INFO, "INITIALIZE", "Governance Consensus Layer Active");
    }

    // --- Reputation-Weighted Logic ---

    /**
     * @dev Applies the reputation multiplier to raw token votes.
     * Logic: (rawVotes * multiplier) / 100.
     */
    function _getVotes(address account, uint256 timepoint, bytes memory params)
        internal
        view
        override(GovernorUpgradeable, GovernorVotesUpgradeable)
        returns (uint256)
    {
        uint256 rawVotes = super._getVotes(account, timepoint, params);
        if (address(reputationManager) == address(0)) return rawVotes;

        uint256 multiplier = reputationManager.getMultiplier(account);
        return (rawVotes * multiplier) / 100;
    }

    function _countVote(
        uint256 proposalId,
        address account,
        uint8 support,
        uint256 weight,
        bytes memory params
    )
        internal
        virtual
        override(GovernorUpgradeable, GovernorCountingSimpleUpgradeable)
        returns (uint256)
    {
        uint256 result = super._countVote(proposalId, account, support, weight, params);

        // Participation Reward
        try reputationManager.processAction(account, keccak256("GOVERNANCE_VOTE")) { } catch { }

        _logToHub(IMonitoringHub.Severity.INFO, "VOTE_CAST", "Participation recorded");
        return result;
    }

    // --- Mandatory Overrides & Forensics ---

    function _queueOperations(
        uint256 proposalId,
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        bytes32 descriptionHash
    ) internal override(GovernorUpgradeable, GovernorTimelockControlUpgradeable) returns (uint48) {
        _logToHub(IMonitoringHub.Severity.WARNING, "PROPOSAL_QUEUED", "Action entering Timelock");
        return super._queueOperations(proposalId, targets, values, calldatas, descriptionHash);
    }

    function _executeOperations(
        uint256 proposalId,
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        bytes32 descriptionHash
    ) internal override(GovernorUpgradeable, GovernorTimelockControlUpgradeable) {
        _logToHub(
            IMonitoringHub.Severity.CRITICAL, "PROPOSAL_EXECUTED", "State modification finalized"
        );
        super._executeOperations(proposalId, targets, values, calldatas, descriptionHash);
    }

    /**
     * @dev Standardized 26-channel forensic logging for Governance actions.
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
                category: "GOVERNANCE",
                details: details,
                riskScore: severity >= IMonitoringHub.Severity.WARNING ? 70 : 10,
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

            try monitoringHub.logForensic(log) { } catch { }
        }
    }

    // --- Quorum & Thresholds ---

    function quorum(
        uint256 /* timepoint */
    )
        public
        view
        virtual
        override
        returns (uint256)
    {
        return 4_000_000e18; // 4% of 100M supply
    }

    function votingDelay() public pure override returns (uint256) {
        return 7_200;
    }

    function votingPeriod() public pure override returns (uint256) {
        return 50_400;
    }

    function proposalThreshold() public pure override returns (uint256) {
        return 100_000e18;
    }

    function state(uint256 proposalId)
        public
        view
        override(GovernorUpgradeable, GovernorTimelockControlUpgradeable)
        returns (ProposalState)
    {
        return super.state(proposalId);
    }

    function proposalNeedsQueuing(uint256 proposalId)
        public
        view
        override(GovernorUpgradeable, GovernorTimelockControlUpgradeable)
        returns (bool)
    {
        return super.proposalNeedsQueuing(proposalId);
    }

    function _cancel(
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        bytes32 descriptionHash
    ) internal override(GovernorUpgradeable, GovernorTimelockControlUpgradeable) returns (uint256) {
        _logToHub(
            IMonitoringHub.Severity.WARNING, "PROPOSAL_CANCELLED", "Governance action revoked"
        );
        return super._cancel(targets, values, calldatas, descriptionHash);
    }

    function _executor()
        internal
        view
        override(GovernorUpgradeable, GovernorTimelockControlUpgradeable)
        returns (address)
    {
        return super._executor();
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(GovernorUpgradeable, AccessControlUpgradeable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function _authorizeUpgrade(address) internal override onlyRole(UPGRADER_ROLE) {
        _logToHub(IMonitoringHub.Severity.CRITICAL, "GOVERNOR_UPGRADE", "Infrastructure migration");
    }

    uint256[46] private _gap;
}
