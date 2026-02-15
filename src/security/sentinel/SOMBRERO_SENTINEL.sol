// SPDX-License-Identifier: MIT
pragma solidity 0.8.33;

import { AccessControl } from "@openzeppelin/contracts/access/AccessControl.sol";
import { ReentrancyGuard } from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

// --- CUSTOM ERRORS ---
error RankInsufficient(uint256 required, uint256 actual);
error RedAlertRestrictionActive();
error ZeroAddressDetected();

// --- EXTERNAL INTERFACES ---
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

// --- SOMBRERO TOKEN ---
contract SombreroToken is ERC20 {
    constructor() ERC20("Sombrero Sentinel Token", "SOMBRERO") {
        _mint(msg.sender, 1_000_000 * 10 ** 18);
    }
}

/**
 * @title SombreroSentinel
 * @notice SECTOR_ID 2: Security Surveillance and Intervention
 * @dev Re-engineered to solve Error 9553 (calldata/memory mismatch)
 */
contract SombreroSentinel is AccessControl, ReentrancyGuard {
    using SafeERC20 for IERC20;
    using SafeERC20 for SombreroToken;

    // --- CONSTANTS ---
    string public constant SECTOR_NAME = "SOMBRERO_SENTINEL";
    uint256 public constant SECTOR_ID = 2;
    bytes32 public constant SOMBRERO_CAPTAIN_ROLE = keccak256("SOMBRERO_CAPTAIN_ROLE");

    // --- DEPARTMENTS ---
    bytes32 public constant SOMBRERO_APEX = keccak256("DEPT_SOMBRERO_APEX");
    bytes32 public constant SOMBRERO_KINETIC = keccak256("DEPT_SOMBRERO_KINETIC");
    bytes32 public constant SOMBRERO_FLUX = keccak256("DEPT_SOMBRERO_FLUX");
    bytes32 public constant SOMBRERO_NEURAL = keccak256("DEPT_SOMBRERO_NEURAL");
    bytes32 public constant SOMBRERO_AEGIS = keccak256("DEPT_SOMBRERO_AEGIS");
    bytes32 public constant SOMBRERO_PULSE = keccak256("DEPT_SOMBRERO_PULSE");

    // --- IMMUTABLES ---
    IReputationManager public immutable REPUTATION_MANAGER;
    IMonitoringHub public immutable MONITORING_HUB;
    IERC20 public immutable AOXC_TOKEN;
    SombreroToken public immutable SOMBRERO_TOKEN;

    struct SecurityProtocol {
        uint256 minRank;
        bool alertActive;
        uint256 incidentCount;
    }

    mapping(bytes32 => SecurityProtocol) public protocols;
    bool public fleetWideRedAlert;

    // --- EVENTS ---
    event ThreatDetected(string threatType, address indexed suspect, uint256 severity);
    event FleetStateChanged(bool isRedAlert, address indexed commander);
    event InterventionExecuted(address indexed targetSector, string reason);
    event SwapToAoxc(address indexed user, uint256 sombreroAmount, uint256 aoxcAmount);
    event SwapFromAoxc(address indexed user, uint256 aoxcAmount, uint256 sombreroAmount);

    modifier onlyQualified(bytes32 _deptId) {
        _checkQualification(_deptId);
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
        SOMBRERO_TOKEN = new SombreroToken();

        _grantRole(DEFAULT_ADMIN_ROLE, _andromeda);
        _grantRole(SOMBRERO_CAPTAIN_ROLE, _captain);

        _initializeProtocols();
    }

    function _initializeProtocols() internal {
        protocols[SOMBRERO_APEX] =
            SecurityProtocol({ minRank: 6, alertActive: false, incidentCount: 0 });
        protocols[SOMBRERO_KINETIC] =
            SecurityProtocol({ minRank: 4, alertActive: false, incidentCount: 0 });
        protocols[SOMBRERO_NEURAL] =
            SecurityProtocol({ minRank: 5, alertActive: false, incidentCount: 0 });
        protocols[SOMBRERO_AEGIS] =
            SecurityProtocol({ minRank: 4, alertActive: false, incidentCount: 0 });
        protocols[SOMBRERO_PULSE] =
            SecurityProtocol({ minRank: 2, alertActive: false, incidentCount: 0 });
    }

    // --- CORE SECURITY OPERATIONS ---

    function triggerRedAlert(bool _active) external onlyQualified(SOMBRERO_APEX) {
        fleetWideRedAlert = _active;
        _log(IMonitoringHub.Severity.CRITICAL, "DEFENSE", "Global Fleet Red Alert Toggled.");
        emit FleetStateChanged(_active, msg.sender);
    }

    function reportAnomaly(string calldata _threatType, address _suspect)
        external
        onlyQualified(SOMBRERO_PULSE)
    {
        protocols[SOMBRERO_PULSE].incidentCount++;
        // calldata'dan gelen _threatType doğrudan iletilebilir
        _log(IMonitoringHub.Severity.WARNING, "SURVEILLANCE", _threatType);
        emit ThreatDetected(_threatType, _suspect, 1);
    }

    function executeIntervention(address _targetSector, string calldata _reason)
        external
        onlyQualified(SOMBRERO_KINETIC)
    {
        _log(IMonitoringHub.Severity.CRITICAL, "TACTICAL", "Intervention broadcasted.");
        emit InterventionExecuted(_targetSector, _reason);
    }

    // --- SWAP FUNCTIONS ---

    function swapToAoxc(uint256 _sombreroAmount) external nonReentrant {
        SOMBRERO_TOKEN.safeTransferFrom(msg.sender, address(this), _sombreroAmount);
        AOXC_TOKEN.safeTransfer(msg.sender, _sombreroAmount);
        emit SwapToAoxc(msg.sender, _sombreroAmount, _sombreroAmount);
    }

    function swapFromAoxc(uint256 _aoxcAmount) external nonReentrant {
        AOXC_TOKEN.safeTransferFrom(msg.sender, address(this), _aoxcAmount);
        SOMBRERO_TOKEN.safeTransfer(msg.sender, _aoxcAmount);
        emit SwapFromAoxc(msg.sender, _aoxcAmount, _aoxcAmount);
    }

    // --- HELPERS ---

    function _checkQualification(bytes32 _deptId) internal view {
        uint256 currentRank = REPUTATION_MANAGER.getRank(msg.sender);
        uint256 required = protocols[_deptId].minRank;

        if (currentRank < required) {
            revert RankInsufficient(required, currentRank);
        }

        if (fleetWideRedAlert && _deptId != SOMBRERO_APEX) {
            revert RedAlertRestrictionActive();
        }
    }

    /**
     * @dev FIX: Parametreleri 'memory' yaparak literal string kabulünü sağlıyoruz.
     */
    function _log(IMonitoringHub.Severity _sev, string memory _cat, string memory _det) internal {
        if (address(MONITORING_HUB) != address(0)) {
            // Interface calldata beklediği için burada iletim yapıyoruz
            MONITORING_HUB.emitLog(_sev, SECTOR_NAME, _cat, _det);
        }
    }
}
