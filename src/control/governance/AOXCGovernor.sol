// SPDX-License-Identifier: MIT
/**
 * @title AOXCGovernor Hardened Framework
 * @author AOXCDAO Institutional Engineering
 * @notice Central Governance Engine with Multi-Layered Security.
 * @dev Optimized for OpenZeppelin 5.5.x. Features:
 * - Anti-Initialization Hijacking
 * - Strict Zero-Address Validation
 * - Emergency State Awareness
 * - Access-Controlled Infrastructure Migration
 * 🎓 LEVEL: Pro Ultimate Academic (Security Hardened)
 */
pragma solidity 0.8.33;

import { Initializable } from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import { AccessControlUpgradeable } from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import { GovernorUpgradeable } from "@openzeppelin/contracts-upgradeable/governance/GovernorUpgradeable.sol";
import { GovernorCountingSimpleUpgradeable } from "@openzeppelin/contracts-upgradeable/governance/extensions/GovernorCountingSimpleUpgradeable.sol";
import { GovernorVotesUpgradeable } from "@openzeppelin/contracts-upgradeable/governance/extensions/GovernorVotesUpgradeable.sol";
import { GovernorTimelockControlUpgradeable } from "@openzeppelin/contracts-upgradeable/governance/extensions/GovernorTimelockControlUpgradeable.sol";
import { TimelockControllerUpgradeable } from "@openzeppelin/contracts-upgradeable/governance/TimelockControllerUpgradeable.sol";
import { IVotes } from "@openzeppelin/contracts/governance/utils/IVotes.sol";
import { UUPSUpgradeable } from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import { ReentrancyGuard } from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

// --- 🔗 AOXC DAO Technical Interfaces ---
import { IAOXCAndromedaCore } from "@interfaces/IAOXCAndromedaCore.sol";
import { IReputationManager } from "@interfaces/IReputationManager.sol";

contract AOXCGovernor is
    Initializable,
    GovernorUpgradeable,
    GovernorCountingSimpleUpgradeable,
    GovernorVotesUpgradeable,
    GovernorTimelockControlUpgradeable,
    AccessControlUpgradeable,
    UUPSUpgradeable,
    ReentrancyGuard
{
    // --- 🏛️ Custom Errors (Gas-Efficient Security) ---
    error AOXC_ZeroAddressForbidden();
    error AOXC_ProtocolEmergencyLocked();
    error AOXC_InconsistentConfiguration();

    // --- 🔑 Access Control Constants ---
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");
    uint256 private constant BPS_DENOMINATOR = 10_000;

    // --- 🛰️ Protocol Infrastructure ---
    IReputationManager public reputationManager;
    IAOXCAndromedaCore public andromedaCore;

    // --- 🔔 Events ---
    event InfrastructureUpdated(address indexed reputationManager, address indexed andromedaCore);

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    /**
     * @notice Hardened initialization process.
     * @dev Ensures all core components are valid upon deployment.
     */
    function initialize(
        IVotes _token,
        TimelockControllerUpgradeable _timelock,
        address _admin,
        address _repManager,
        address _andromeda
    ) public initializer {
        if (
            address(_token) == address(0) ||
            address(_timelock) == address(0) ||
            _admin == address(0) ||
            _repManager == address(0) ||
            _andromeda == address(0)
        ) {
            revert AOXC_ZeroAddressForbidden();
        }

        __Governor_init("AOXCGovernor");
        __GovernorVotes_init(_token);
        __GovernorTimelockControl_init(_timelock);
        __AccessControl_init();

        reputationManager = IReputationManager(_repManager);
        andromedaCore = IAOXCAndromedaCore(_andromeda);

        _grantRole(DEFAULT_ADMIN_ROLE, _admin);
        _grantRole(UPGRADER_ROLE, _admin);
    }

    // --- ⚖️ Advanced Weighted Voting Logic ---

    function _getVotes(
        address account,
        uint256 timepoint,
        bytes memory params
    ) internal view override(GovernorUpgradeable, GovernorVotesUpgradeable) returns (uint256) {
        uint256 baseVotes = super._getVotes(account, timepoint, params);
        if (baseVotes == 0) return 0;

        if (address(andromedaCore) != address(0)) {
            if (
                andromedaCore.getProtocolState() == IAOXCAndromedaCore.ProtocolState.EMERGENCY_PAUSE
            ) {
                return 0;
            }
        }

        uint256 multiplier = BPS_DENOMINATOR;

        if (address(reputationManager) != address(0)) {
            uint256 repMult = reputationManager.getMultiplier(account);
            if (repMult > 500) repMult = 500;
            multiplier = (multiplier * repMult) / 100;
        }

        return (baseVotes * multiplier) / BPS_DENOMINATOR;
    }

    // --- 📑 Governance Policy ---

    function votingDelay() public pure override returns (uint256) {
        return 7200;
    }

    function votingPeriod() public pure override returns (uint256) {
        return 50400;
    }

    function proposalThreshold() public pure override returns (uint256) {
        return 100_000e18;
    }

    function quorum(uint256 timepoint) public view override returns (uint256) {
        return (token().getPastTotalSupply(timepoint) * 4) / 100;
    }

    // --- 🛠️ Operational Security ---

    function updateInfrastructure(
        address _repManager,
        address _andromeda
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        if (_repManager == address(0) || _andromeda == address(0)) {
            revert AOXC_ZeroAddressForbidden();
        }

        reputationManager = IReputationManager(_repManager);
        andromedaCore = IAOXCAndromedaCore(_andromeda);

        emit InfrastructureUpdated(_repManager, _andromeda);
    }

    // --- 🏗️ Inheritance Resolution & Security Overrides ---

    function state(
        uint256 pId
    )
        public
        view
        override(GovernorUpgradeable, GovernorTimelockControlUpgradeable)
        returns (ProposalState)
    {
        return super.state(pId);
    }

    function proposalNeedsQueuing(
        uint256 pId
    ) public view override(GovernorUpgradeable, GovernorTimelockControlUpgradeable) returns (bool) {
        return super.proposalNeedsQueuing(pId);
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
        uint256 pId,
        address[] memory t,
        uint256[] memory v,
        bytes[] memory c,
        bytes32 d
    ) internal override(GovernorUpgradeable, GovernorTimelockControlUpgradeable) nonReentrant {
        super._executeOperations(pId, t, v, c, d);
    }

    function _queueOperations(
        uint256 pId,
        address[] memory t,
        uint256[] memory v,
        bytes[] memory c,
        bytes32 d
    ) internal override(GovernorUpgradeable, GovernorTimelockControlUpgradeable) returns (uint48) {
        return super._queueOperations(pId, t, v, c, d);
    }

    function _cancel(
        address[] memory t,
        uint256[] memory v,
        bytes[] memory c,
        bytes32 d
    ) internal override(GovernorUpgradeable, GovernorTimelockControlUpgradeable) returns (uint256) {
        return super._cancel(t, v, c, d);
    }

    function supportsInterface(
        bytes4 iId
    ) public view override(GovernorUpgradeable, AccessControlUpgradeable) returns (bool) {
        return super.supportsInterface(iId);
    }

    /**
     * @dev Critical Security Gate for Logic Upgrades.
     * @notice Mutability restricted to 'view' to suppress Solc 0.8.33 warnings.
     */
    function _authorizeUpgrade(
        address newImplementation
    ) internal view override onlyRole(UPGRADER_ROLE) {
        if (newImplementation == address(0)) {
            revert AOXC_ZeroAddressForbidden();
        }
    }
}
