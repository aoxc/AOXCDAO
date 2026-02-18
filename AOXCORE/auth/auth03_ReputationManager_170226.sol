// SPDX-License-Identifier: MIT
pragma solidity 0.8.33;

import {Initializable} from "@openzeppelin-upgradeable/proxy/utils/Initializable.sol";
import {AccessControlUpgradeable} from "@openzeppelin-upgradeable/access/AccessControlUpgradeable.sol";
import {PausableUpgradeable} from "@openzeppelin-upgradeable/utils/PausableUpgradeable.sol";
import {UUPSUpgradeable} from "@openzeppelin-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

import {IAOXP} from "@interfaces/api18_IAoxp_170226.sol";
import {IMonitoringHub} from "@api/api29_IMonitoringHub_170226.sol";
import {AOXCErrors} from "@libraries/core08_AoxcErrorDefinitions_170226.sol";

/**
 * @title ReputationManager
 * @author AOXCMainEngine Core Engineering
 * @notice Akdeniz V2 Reputation Engine - Full 26-Channel Forensic Integration.
 */
contract ReputationManager is
    Initializable,
    AccessControlUpgradeable,
    PausableUpgradeable,
    UUPSUpgradeable,
    ReentrancyGuard
{
    // --- Roller ---
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");

    // --- Durum Değişkenleri ---
    IAOXP public aoxp;
    IMonitoringHub public monitoringHub;

    struct ActionConfig {
        uint256 reward;
        uint256 weight;
        uint256 cooldown;
    }

    struct UserData {
        uint256 score;
        uint256 multiplier;
        uint256 lastAction;
    }

    mapping(bytes32 => ActionConfig) public actions;
    mapping(address => UserData) private _users;

    uint256[] public thresholds;
    uint256[] public multipliers;
    uint256 public minMultiplier;
    uint256 public maxMultiplier;

    // --- Eventler ---
    event ActionConfigured(bytes32 indexed actionType, uint256 reward, uint256 weight, uint256 cooldown);
    event ReputationProcessed(address indexed user, bytes32 indexed actionType, uint256 newScore);

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(
        address admin,
        address _aoxp,
        address _monitoringHub,
        uint256 _minMultiplier,
        uint256 _maxMultiplier,
        uint256[] memory _thresholds,
        uint256[] memory _multipliers
    ) external initializer {
        if (admin == address(0) || _aoxp == address(0) || _monitoringHub == address(0)) {
            revert AOXCErrors.ZeroAddressDetected();
        }
        if (_thresholds.length != _multipliers.length) {
            revert AOXCErrors.InvalidConfiguration();
        }

        __AccessControl_init();
        __Pausable_init();

        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(ADMIN_ROLE, admin);
        _grantRole(UPGRADER_ROLE, admin);
        _grantRole(OPERATOR_ROLE, admin);

        aoxp = IAOXP(_aoxp);
        monitoringHub = IMonitoringHub(_monitoringHub);
        minMultiplier = _minMultiplier;
        maxMultiplier = _maxMultiplier;
        thresholds = _thresholds;
        multipliers = _multipliers;

        _logToHub(IMonitoringHub.Severity.INFO, "INITIALIZE", "Reputation system deployed");
    }

    function setAction(bytes32 actionType, uint256 reward, uint256 weight, uint256 cooldown)
        external
        onlyRole(ADMIN_ROLE)
    {
        actions[actionType] = ActionConfig({reward: reward, weight: weight, cooldown: cooldown});
        _logToHub(IMonitoringHub.Severity.WARNING, "CONFIG_CHANGE", "Action parameters updated");
        emit ActionConfigured(actionType, reward, weight, cooldown);
    }

    function processAction(address user, bytes32 actionType)
        external
        onlyRole(OPERATOR_ROLE)
        whenNotPaused
        nonReentrant
    {
        ActionConfig memory cfg = actions[actionType];
        UserData storage userRef = _users[user];

        if (block.timestamp < userRef.lastAction + cfg.cooldown) {
            revert AOXCErrors.ProtocolPaused();
        }

        userRef.score += cfg.weight;
        userRef.lastAction = block.timestamp;
        userRef.multiplier = _calculateMultiplier(userRef.score);

        if (cfg.reward > 0) {
            // DÜZELTME: IAOXP (address to, uint256 id, uint256 amount, bytes data) uyumu
            try aoxp.awardXp(user, 0, cfg.reward, "") {} catch {}
        }

        emit ReputationProcessed(user, actionType, userRef.score);
        _logToHub(IMonitoringHub.Severity.INFO, "REPUTATION_UPDATE", "User score incremented");
    }

    function getMultiplier(address user) external view returns (uint256) {
        uint256 m = _users[user].multiplier;
        if (m < minMultiplier) return minMultiplier;
        if (m > maxMultiplier) return maxMultiplier;
        return (m == 0) ? minMultiplier : m;
    }

    function _calculateMultiplier(uint256 score) internal view returns (uint256) {
        uint256 m = minMultiplier;
        uint256 len = thresholds.length;
        for (uint256 i = 0; i < len;) {
            if (score >= thresholds[i]) {
                m = multipliers[i];
            } else {
                break;
            }
            unchecked {
                ++i;
            }
        }
        return m > maxMultiplier ? maxMultiplier : m;
    }

    /**
     * @dev 26-Channel Akdeniz V2 Forensic Logging
     */
    function _logToHub(IMonitoringHub.Severity severity, string memory action, string memory details) internal {
        if (address(monitoringHub) != address(0)) {
            IMonitoringHub.ForensicLog memory log = IMonitoringHub.ForensicLog({
                source: address(this),
                actor: msg.sender,
                origin: tx.origin,
                related: address(0),
                severity: severity,
                category: "REPUTATION_ENGINE",
                details: details,
                riskScore: severity == IMonitoringHub.Severity.CRITICAL ? 80 : 10,
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

    function _authorizeUpgrade(address) internal override onlyRole(UPGRADER_ROLE) {
        _logToHub(IMonitoringHub.Severity.CRITICAL, "UPGRADE", "Reputation upgrade authorized");
    }

    uint256[42] private _gap;
}
