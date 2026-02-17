// SPDX-License-Identifier: MIT
pragma solidity 0.8.33;

import {Initializable} from "@openzeppelin-upgradeable/proxy/utils/Initializable.sol";
import {AccessControlUpgradeable} from "@openzeppelin-upgradeable/access/AccessControlUpgradeable.sol";
import {UUPSUpgradeable} from "@openzeppelin-upgradeable/proxy/utils/UUPSUpgradeable.sol";

import {IMonitoringHub} from "@api/api29_IMonitoringHub_170226.sol";
import {AOXCBaseReporter} from "data/data08_AoxcBaseReporter_170226.sol";
import {AOXCErrors} from "@libraries/core08_AoxcErrorDefinitions_170226.sol";

/**
 * @title AOXCEmergencyPauseGuard
 * @author AOXC Core Engineering
 * @notice "Iron Fist" Circuit Breaker for the AOXC Ecosystem.
 * @dev Re-engineered for Akdeniz V2 with wrapped modifiers for lint compliance and gas optimization.
 * Performance: Optimized bytecode via internal calls in modifiers.
 */
contract AOXCEmergencyPauseGuard is Initializable, AccessControlUpgradeable, UUPSUpgradeable, AOXCBaseReporter {
    // --- Access Control Roles ---
    bytes32 public constant ADMIN_ROLE = keccak256("AOXC_ADMIN_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("AOXC_PAUSER_ROLE");
    bytes32 public constant GUARDIAN_ROLE = keccak256("AOXC_GUARDIAN_ROLE");
    bytes32 public constant UPGRADER_ROLE = keccak256("AOXC_UPGRADER_ROLE");

    // --- State Variables ---
    bool public paused;
    uint256 public lastPauseTime;
    uint256 public minPauseDuration;

    // Guardian Consensus State
    uint256 public constant GUARDIAN_THRESHOLD = 3;
    uint256 public activeGuardianVotes;
    mapping(address => bool) public hasVotedForPause;

    // --- Local Reentrancy Guard State ---
    uint256 private _status;
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    // --- Events ---
    event Paused(address indexed account, uint256 timestamp, string reason);
    event Unpaused(address indexed account, uint256 timestamp);
    event GuardianVoteCasted(address indexed guardian, uint256 totalVotes);
    event MinPauseDurationUpdated(uint256 oldDuration, uint256 newDuration);

    // --- Wrapped Modifiers (Forge Lint Fix: unwrapped-modifier-logic) ---

    /**
     * @dev Optimized Reentrancy Guard wrapping to satisfy enterprise lint rules and reduce contract size.
     */
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
     * @notice Initializes the Emergency Pause Guard logic.
     * @param admin Initial administrator and pauser.
     * @param _monitoringHub Forensic logging hub address.
     * @param _minPauseDuration Minimum seconds the system must stay paused.
     */
    function initialize(address admin, address _monitoringHub, uint256 _minPauseDuration) external initializer {
        if (admin == address(0) || _monitoringHub == address(0)) {
            revert AOXCErrors.ZeroAddressDetected();
        }

        __AccessControl_init();

        _status = _NOT_ENTERED;
        _setMonitoringHub(_monitoringHub);
        minPauseDuration = _minPauseDuration;

        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(ADMIN_ROLE, admin);
        _grantRole(PAUSER_ROLE, admin);
        _grantRole(UPGRADER_ROLE, admin);

        _performForensicLog(IMonitoringHub.Severity.INFO, "INITIALIZE", "Circuit Breaker Active", address(0), 0, "");
    }

    // --- Core Logic ---

    /**
     * @notice Manually pauses the entire protocol in case of an emergency.
     * @param reason The forensic justification for the pause.
     */
    function pause(string calldata reason) external onlyRole(PAUSER_ROLE) nonReentrant {
        if (paused) revert AOXCErrors.ProtocolPaused();
        _executePause(reason);
    }

    /**
     * @notice Guardian consensus mechanism to trigger an emergency pause.
     * @dev Automatically triggers pause when GUARDIAN_THRESHOLD is met.
     */
    function triggerGuardianPause() external onlyRole(GUARDIAN_ROLE) {
        if (paused) revert AOXCErrors.ProtocolPaused();
        if (hasVotedForPause[msg.sender]) revert AOXCErrors.SecurityAssumptionViolated();

        hasVotedForPause[msg.sender] = true;
        activeGuardianVotes++;

        _performForensicLog(
            IMonitoringHub.Severity.WARNING,
            "GUARDIAN_VOTE",
            "Emergency consensus vote logged",
            msg.sender,
            50,
            abi.encode(activeGuardianVotes)
        );

        emit GuardianVoteCasted(msg.sender, activeGuardianVotes);

        if (activeGuardianVotes >= GUARDIAN_THRESHOLD) {
            _executePause("Guardian Consensus Threshold Met");
        }
    }

    /**
     * @notice Resumes protocol operations.
     * @dev Enforcement of minPauseDuration to prevent premature recovery during active attacks.
     */
    function unpause() external onlyRole(ADMIN_ROLE) nonReentrant {
        if (!paused) revert AOXCErrors.InvalidConfiguration();
        if (block.timestamp < lastPauseTime + minPauseDuration) {
            revert AOXCErrors.SecurityAssumptionViolated();
        }

        paused = false;
        activeGuardianVotes = 0;

        _performForensicLog(
            IMonitoringHub.Severity.INFO, "SYSTEM_UNPAUSED", "Normal operations resumed", msg.sender, 0, ""
        );

        emit Unpaused(msg.sender, block.timestamp);
    }

    // --- View Functions ---

    /**
     * @notice Returns current pause state.
     */
    function isPaused() external view returns (bool) {
        return paused;
    }

    // --- Internal Helpers ---

    function _executePause(string memory reason) internal {
        paused = true;
        lastPauseTime = block.timestamp;

        _performForensicLog(IMonitoringHub.Severity.CRITICAL, "SYSTEM_PAUSED", reason, msg.sender, 100, "");

        emit Paused(msg.sender, block.timestamp, reason);
    }

    /**
     * @dev Restricts implementation upgrades to the UPGRADER_ROLE.
     */
    function _authorizeUpgrade(address newImplementation) internal override onlyRole(UPGRADER_ROLE) {
        if (newImplementation == address(0)) {
            revert AOXCErrors.ZeroAddressDetected();
        }

        _performForensicLog(
            IMonitoringHub.Severity.CRITICAL,
            "PAUSE_GUARD_UPGRADE",
            "Logic migration authorized",
            newImplementation,
            100,
            ""
        );
    }

    /**
     * @dev Reserved storage gap for upgradeability protection (50 slots).
     */
    uint256[43] private _gap;
}
