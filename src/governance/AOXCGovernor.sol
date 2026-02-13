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
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");
    bytes32 public constant VETO_ROLE = keccak256("VETO_ROLE");

    IReputationManager public reputationManager;
    IMonitoringHub public monitoringHub;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(
        IVotes _token,
        TimelockControllerUpgradeable _timelock,
        address _admin,
        IReputationManager _reputationManager,
        IMonitoringHub _monitoringHub
    ) public virtual initializer {
        if (_admin == address(0) || address(_monitoringHub) == address(0)) {
            revert AOXCErrors.ZeroAddressDetected();
        }

        __Governor_init("AOXCGovernor");
        __GovernorVotes_init(_token);
        __GovernorTimelockControl_init(_timelock);
        __AccessControl_init();
        __Pausable_init();
        // NOT: OZ v5'te __UUPSUpgradeable_init() kaldırıldı, bu yüzden burası boş kalmalı.

        reputationManager = _reputationManager;
        monitoringHub = _monitoringHub;

        _grantRole(DEFAULT_ADMIN_ROLE, _admin);
        _grantRole(UPGRADER_ROLE, _admin);
        _grantRole(VETO_ROLE, _admin);
    }

    function _getVotes(address account, uint256 timepoint, bytes memory params)
        internal
        view
        virtual
        override(GovernorUpgradeable, GovernorVotesUpgradeable)
        returns (uint256)
    {
        uint256 rawVotes = super._getVotes(account, timepoint, params);
        if (address(reputationManager) == address(0)) return rawVotes;

        uint256 multiplier = reputationManager.getMultiplier(account);
        return (rawVotes * multiplier) / 100;
    }

    // --- Zorunlu Override'lar ---
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

    function quorum(uint256 timepoint) public view virtual override returns (uint256) {
        return (token().getPastTotalSupply(timepoint) * 4) / 100;
    }

    function votingDelay() public pure virtual override returns (uint256) {
        return 7200;
    }

    function votingPeriod() public pure virtual override returns (uint256) {
        return 50400;
    }

    function proposalThreshold() public pure virtual override returns (uint256) {
        return 100000e18;
    }

    function _executor()
        internal
        view
        override(GovernorUpgradeable, GovernorTimelockControlUpgradeable)
        returns (address)
    {
        return super._executor();
    }

    function _executeOperations(
        uint256 proposalId,
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        bytes32 descriptionHash
    ) internal override(GovernorUpgradeable, GovernorTimelockControlUpgradeable) {
        super._executeOperations(proposalId, targets, values, calldatas, descriptionHash);
    }

    function _queueOperations(
        uint256 proposalId,
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        bytes32 descriptionHash
    ) internal override(GovernorUpgradeable, GovernorTimelockControlUpgradeable) returns (uint48) {
        return super._queueOperations(proposalId, targets, values, calldatas, descriptionHash);
    }

    function _cancel(
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        bytes32 descriptionHash
    ) internal override(GovernorUpgradeable, GovernorTimelockControlUpgradeable) returns (uint256) {
        return super._cancel(targets, values, calldatas, descriptionHash);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(GovernorUpgradeable, AccessControlUpgradeable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function _authorizeUpgrade(address newImplementation)
        internal
        override
        onlyRole(UPGRADER_ROLE)
    { }

    uint256[46] private _gap;
}
