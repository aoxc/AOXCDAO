// SPDX-License-Identifier: MIT
pragma solidity 0.8.33;

import { AccessControl } from "@openzeppelin/contracts/access/AccessControl.sol";
import { ReentrancyGuard } from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

// --- CUSTOM ERRORS (Academic & Gas Efficient) ---
error RankInsufficient(uint256 required, uint256 actual);
error DepartmentLocked(bytes32 deptId);
error QuotaExceeded(uint256 available);
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

// --- VIRGO TOKEN ---
contract VirgoToken is ERC20 {
    constructor() ERC20("Virgo Fabricator Token", "VIRGO") {
        _mint(msg.sender, 1_000_000 * 10 ** 18);
    }
}

/**
 * @title VirgoFabricator
 * @notice SECTOR_ID 1: Production and Fabrication
 * @dev Audit-Ready Implementation with SafeERC20 and Optimized Modifiers
 */
contract VirgoFabricator is AccessControl, ReentrancyGuard {
    using SafeERC20 for IERC20;
    using SafeERC20 for VirgoToken;

    // --- CONSTANTS ---
    string public constant SECTOR_NAME = "VIRGO_FABRICATOR";
    uint256 public constant SECTOR_ID = 1;
    uint256 public constant EPOCH_DURATION = 7 days;
    bytes32 public constant VIRGO_CAPTAIN_ROLE = keccak256("VIRGO_CAPTAIN_ROLE");

    // --- DEPARTMENT IDENTIFIERS ---
    bytes32 public constant VIRGO_APEX = keccak256("DEPT_VIRGO_APEX");
    bytes32 public constant VIRGO_KINETIC = keccak256("DEPT_VIRGO_KINETIC");
    bytes32 public constant VIRGO_FLUX = keccak256("DEPT_VIRGO_FLUX");
    bytes32 public constant VIRGO_NEURAL = keccak256("DEPT_VIRGO_NEURAL");
    bytes32 public constant VIRGO_AEGIS = keccak256("DEPT_VIRGO_AEGIS");
    bytes32 public constant VIRGO_PULSE = keccak256("DEPT_VIRGO_PULSE");

    // --- IMMUTABLES ---
    IERC20 public immutable AOXC_TOKEN;
    IReputationManager public immutable REPUTATION_MANAGER;
    IMonitoringHub public immutable MONITORING_HUB;
    VirgoToken public immutable VIRGO_TOKEN;

    struct Department {
        uint256 rankRequirement;
        uint256 epochQuota;
        uint256 epochSpent;
        bool isOperational;
    }

    mapping(bytes32 => Department) public departmentRegistry;
    uint256 public epochResetTimestamp;

    // --- EVENTS ---
    event ProductionExecuted(address indexed operator, uint256 amount);
    event DepartmentLockdown(bytes32 indexed department, bool status);
    event QuotaRecalibrated(bytes32 indexed department, uint256 newQuota);
    event SwapToAoxc(address indexed user, uint256 virgoAmount, uint256 aoxcAmount);
    event SwapFromAoxc(address indexed user, uint256 aoxcAmount, uint256 virgoAmount);

    // --- MODIFIER OPTIMIZATION ---
    modifier onlyQualified(bytes32 _deptId) {
        _checkQualification(_deptId);
        _;
    }

    constructor(
        address _aoxcToken,
        address _reputation,
        address _monitoring,
        address _andromeda,
        address _captain
    ) {
        if (_aoxcToken == address(0) || _reputation == address(0) || _monitoring == address(0)) {
            revert ZeroAddressDetected();
        }

        AOXC_TOKEN = IERC20(_aoxcToken);
        REPUTATION_MANAGER = IReputationManager(_reputation);
        MONITORING_HUB = IMonitoringHub(_monitoring);
        VIRGO_TOKEN = new VirgoToken();

        _grantRole(DEFAULT_ADMIN_ROLE, _andromeda);
        _grantRole(VIRGO_CAPTAIN_ROLE, _captain);

        _initializeDepartments();
        epochResetTimestamp = block.timestamp + EPOCH_DURATION;
    }

    /**
     * @dev LINT: Named struct fields usage for better readability and safety.
     */
    function _initializeDepartments() internal {
        departmentRegistry[VIRGO_APEX] = Department({
            rankRequirement: 6, epochQuota: 1_000_000e18, epochSpent: 0, isOperational: true
        });
        departmentRegistry[VIRGO_KINETIC] = Department({
            rankRequirement: 4, epochQuota: 500_000e18, epochSpent: 0, isOperational: true
        });
        departmentRegistry[VIRGO_FLUX] = Department({
            rankRequirement: 3, epochQuota: 200_000e18, epochSpent: 0, isOperational: true
        });
        departmentRegistry[VIRGO_NEURAL] =
            Department({ rankRequirement: 5, epochQuota: 0, epochSpent: 0, isOperational: true });
        departmentRegistry[VIRGO_AEGIS] =
            Department({ rankRequirement: 4, epochQuota: 0, epochSpent: 0, isOperational: true });
        departmentRegistry[VIRGO_PULSE] =
            Department({ rankRequirement: 2, epochQuota: 0, epochSpent: 0, isOperational: true });
    }

    // --- CORE OPERATIONS ---

    function executeFabrication(address _recipient, uint256 _amount)
        external
        onlyQualified(VIRGO_KINETIC)
        nonReentrant
    {
        _syncEpoch();
        Department storage dept = departmentRegistry[VIRGO_KINETIC];

        if (dept.epochSpent + _amount > dept.epochQuota) {
            revert QuotaExceeded(dept.epochQuota - dept.epochSpent);
        }

        dept.epochSpent += _amount;
        VIRGO_TOKEN.safeTransfer(_recipient, _amount);

        _log(IMonitoringHub.Severity.INFO, "PRODUCTION", "Fabrication successful.");
        emit ProductionExecuted(msg.sender, _amount);
    }

    function triggerLockdown(bytes32 _deptId, bool _status) external onlyQualified(VIRGO_AEGIS) {
        if (_deptId == VIRGO_APEX) revert("Virgo: Apex cannot be locked");

        departmentRegistry[_deptId].isOperational = !_status;
        _log(IMonitoringHub.Severity.WARNING, "SECURITY", "Lockdown state toggled.");
        emit DepartmentLockdown(_deptId, _status);
    }

    function calibrateQuota(bytes32 _deptId, uint256 _newQuota) external onlyQualified(VIRGO_APEX) {
        departmentRegistry[_deptId].epochQuota = _newQuota;
        emit QuotaRecalibrated(_deptId, _newQuota);
    }

    // --- SWAP FUNCTIONS (SafeERC20) ---

    function swapToAoxc(uint256 virgoAmount) external nonReentrant {
        VIRGO_TOKEN.safeTransferFrom(msg.sender, address(this), virgoAmount);
        AOXC_TOKEN.safeTransfer(msg.sender, virgoAmount);

        emit SwapToAoxc(msg.sender, virgoAmount, virgoAmount);
    }

    function swapFromAoxc(uint256 aoxcAmount) external nonReentrant {
        AOXC_TOKEN.safeTransferFrom(msg.sender, address(this), aoxcAmount);
        VIRGO_TOKEN.safeTransfer(msg.sender, aoxcAmount);

        emit SwapFromAoxc(msg.sender, aoxcAmount, aoxcAmount);
    }

    // --- HELPERS ---

    function _checkQualification(bytes32 _deptId) internal view {
        uint256 currentRank = REPUTATION_MANAGER.getRank(msg.sender);
        Department storage dept = departmentRegistry[_deptId];

        if (currentRank < dept.rankRequirement) {
            revert RankInsufficient(dept.rankRequirement, currentRank);
        }
        if (!dept.isOperational) {
            revert DepartmentLocked(_deptId);
        }
    }

    function _syncEpoch() internal {
        if (block.timestamp >= epochResetTimestamp) {
            epochResetTimestamp = block.timestamp + EPOCH_DURATION;
            departmentRegistry[VIRGO_KINETIC].epochSpent = 0;
            departmentRegistry[VIRGO_FLUX].epochSpent = 0;
        }
    }

    function _log(IMonitoringHub.Severity _sev, string memory _cat, string memory _det) internal {
        if (address(MONITORING_HUB) != address(0)) {
            MONITORING_HUB.emitLog(_sev, SECTOR_NAME, _cat, _det);
        }
    }
}
