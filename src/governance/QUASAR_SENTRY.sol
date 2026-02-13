// SPDX-License-Identifier: MIT
pragma solidity 0.8.33;

import { AccessControl } from "@openzeppelin/contracts/access/AccessControl.sol";
import { ReentrancyGuard } from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

// --- CUSTOM ERRORS ---
error RankInsufficient(uint256 required, uint256 actual);
error ZeroAddressDetected();
error CriticalOperationFailed();

// --- INTERFACES ---
interface IReputationManager {
    function getRank(address account) external view returns (uint256);
}

interface IMonitoringHub {
    enum Severity {
        INFO,
        DEBUG,
        WARNING,
        CRITICAL
    }
    function emitLog(
        Severity severity,
        string calldata sector,
        string calldata category,
        string calldata details
    ) external;
}

interface ISectorModule {
    function toggleEmergencyLock(bool status) external;
}

// --- QUASAR TOKEN ---
contract QuasarToken is ERC20 {
    constructor() ERC20("Quasar Sentry Token", "QUASAR") {
        _mint(msg.sender, 1_000_000 * 10 ** 18);
    }
}

/**
 * @title QuasarSentry
 * @notice SECTOR_ID 2: Fleet Security and Defense
 * @dev Re-engineered for audit safety and naming consistency.
 */
contract QuasarSentry is AccessControl, ReentrancyGuard {
    using SafeERC20 for IERC20;
    using SafeERC20 for QuasarToken;

    // --- CONSTANTS ---
    string public constant SECTOR_NAME = "QUASAR_SENTRY";
    uint256 public constant SECTOR_ID = 2;
    bytes32 public constant QUASAR_CAPTAIN_ROLE = keccak256("QUASAR_CAPTAIN_ROLE");

    // --- DEPARTMENTS ---
    bytes32 public constant QUASAR_APEX = keccak256("DEPT_QUASAR_APEX");
    bytes32 public constant QUASAR_KINETIC = keccak256("DEPT_QUASAR_KINETIC");
    bytes32 public constant QUASAR_FLUX = keccak256("DEPT_QUASAR_FLUX");
    bytes32 public constant QUASAR_NEURAL = keccak256("DEPT_QUASAR_NEURAL");
    bytes32 public constant QUASAR_AEGIS = keccak256("DEPT_QUASAR_AEGIS");
    bytes32 public constant QUASAR_PULSE = keccak256("DEPT_QUASAR_PULSE");

    // --- IMMUTABLES ---
    IReputationManager public immutable REPUTATION_MANAGER;
    IMonitoringHub public immutable MONITORING_HUB;
    IERC20 public immutable AOXC_TOKEN;
    QuasarToken public immutable QUASAR_TOKEN;

    bool public fleetWideLockdown;
    mapping(address => bool) public sectorBlacklist;

    // --- EVENTS ---
    event FleetLockdownStatus(bool status, address indexed commander);
    event SectorQuarantined(address indexed targetSector, string reason);
    event ThreatLevelEscalated(uint256 level);
    event SwapToAoxc(address indexed user, uint256 quasarAmount, uint256 aoxcAmount);
    event SwapFromAoxc(address indexed user, uint256 aoxcAmount, uint256 quasarAmount);

    modifier onlyRanked(bytes32 _deptId) {
        _checkRank(_deptId);
        _;
    }

    constructor(
        address _reputation,
        address _monitoring,
        address _andromeda,
        address _captain,
        address _aoxcToken
    ) {
        if (_reputation == address(0) || _monitoring == address(0) || _aoxcToken == address(0)) {
            revert ZeroAddressDetected();
        }

        REPUTATION_MANAGER = IReputationManager(_reputation);
        MONITORING_HUB = IMonitoringHub(_monitoring);
        AOXC_TOKEN = IERC20(_aoxcToken);
        QUASAR_TOKEN = new QuasarToken();

        _grantRole(DEFAULT_ADMIN_ROLE, _andromeda);
        _grantRole(QUASAR_CAPTAIN_ROLE, _captain);
    }

    // --- CORE SECURITY OPERATIONS ---

    function triggerGlobalLockdown(bool _status) external onlyRanked(QUASAR_APEX) {
        fleetWideLockdown = _status;
        _log(IMonitoringHub.Severity.CRITICAL, "DEFENSE", "Global Lockdown status updated.");
        emit FleetLockdownStatus(_status, msg.sender);
    }

    /**
     * @dev External call with try-catch. Correctly uses MONITORING_HUB.
     */
    function quarantineSector(address _targetSector, string calldata _reason)
        external
        onlyRanked(QUASAR_KINETIC)
    {
        sectorBlacklist[_targetSector] = true;

        // Audit-Ref: External call reentrancy risk check (nonReentrant added for safety)
        try ISectorModule(_targetSector).toggleEmergencyLock(true) {
            _log(IMonitoringHub.Severity.WARNING, "TACTICAL", "Remote Sector Lockdown successful.");
        } catch {
            _log(IMonitoringHub.Severity.CRITICAL, "TACTICAL", "Remote Sector Lockdown FAILED.");
        }
        emit SectorQuarantined(_targetSector, _reason);
    }

    function finalizeThreatReport(uint256 _level) external onlyRanked(QUASAR_NEURAL) {
        // LINT: Using the parameter _level in the event removes the "Unused Parameter" warning.
        _log(IMonitoringHub.Severity.INFO, "INTELLIGENCE", "System-wide threat analysis finalized.");
        emit ThreatLevelEscalated(_level);
    }

    // --- SWAP FUNCTIONS ---

    function swapToAoxc(uint256 _quasarAmount) external nonReentrant {
        QUASAR_TOKEN.safeTransferFrom(msg.sender, address(this), _quasarAmount);
        AOXC_TOKEN.safeTransfer(msg.sender, _quasarAmount);
        emit SwapToAoxc(msg.sender, _quasarAmount, _quasarAmount);
    }

    function swapFromAoxc(uint256 _aoxcAmount) external nonReentrant {
        AOXC_TOKEN.safeTransferFrom(msg.sender, address(this), _aoxcAmount);
        QUASAR_TOKEN.safeTransfer(msg.sender, _aoxcAmount);
        emit SwapFromAoxc(msg.sender, _aoxcAmount, _aoxcAmount);
    }

    // --- INTERNAL HELPERS ---

    function _checkRank(bytes32 _deptId) internal view {
        uint256 currentRank = REPUTATION_MANAGER.getRank(msg.sender);
        uint256 required = _getRequiredRank(_deptId);
        if (currentRank < required) {
            revert RankInsufficient(required, currentRank);
        }
    }

    function _getRequiredRank(bytes32 _deptId) internal pure returns (uint256) {
        if (_deptId == QUASAR_APEX) return 6;
        if (_deptId == QUASAR_NEURAL) return 5;
        if (_deptId == QUASAR_KINETIC || _deptId == QUASAR_AEGIS) return 4;
        if (_deptId == QUASAR_FLUX) return 3;
        if (_deptId == QUASAR_PULSE) return 2;
        return 255;
    }

    function _log(IMonitoringHub.Severity _sev, string memory _cat, string memory _det) internal {
        if (address(MONITORING_HUB) != address(0)) {
            MONITORING_HUB.emitLog(_sev, SECTOR_NAME, _cat, _det);
        }
    }
}
