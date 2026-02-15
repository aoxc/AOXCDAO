// SPDX-License-Identifier: MIT
pragma solidity 0.8.33;

import { AccessControl } from "@openzeppelin/contracts/access/AccessControl.sol";
import { ReentrancyGuard } from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @dev Custom Errors - Gas verimliliği ve net hata takibi.
 */
error RankInsufficient(uint256 required, uint256 actual);
error ZeroAddressDetected();
error RouteNotVerified(uint256 chainId);

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

// --- CENTAURUS TOKEN ---
contract CentaurusToken is ERC20 {
    constructor() ERC20("Centaurus Bridge Token", "CENTAURUS") {
        _mint(msg.sender, 1_000_000 * 10 ** 18);
    }
}

/**
 * @title CentaurusBridge
 * @notice SECTOR_ID 3: Cross-Chain Logistics and Data Dispatch
 * @dev Fixed for Solc 0.8.33 memory/calldata conversion (Error 9553 fix).
 */
contract CentaurusBridge is AccessControl, ReentrancyGuard {
    using SafeERC20 for IERC20;
    using SafeERC20 for CentaurusToken;

    // --- CONSTANTS ---
    string public constant SECTOR_NAME = "CENTAURUS_BRIDGE";
    uint256 public constant SECTOR_ID = 3;
    bytes32 public constant CENTAURUS_CAPTAIN_ROLE = keccak256("CENTAURUS_CAPTAIN_ROLE");

    // --- DEPARTMENTS ---
    bytes32 public constant CENTAURUS_APEX = keccak256("DEPT_CENTAURUS_APEX");
    bytes32 public constant CENTAURUS_KINETIC = keccak256("DEPT_CENTAURUS_KINETIC");
    bytes32 public constant CENTAURUS_FLUX = keccak256("DEPT_CENTAURUS_FLUX");
    bytes32 public constant CENTAURUS_NEURAL = keccak256("DEPT_CENTAURUS_NEURAL");
    bytes32 public constant CENTAURUS_AEGIS = keccak256("DEPT_CENTAURUS_AEGIS");
    bytes32 public constant CENTAURUS_PULSE = keccak256("DEPT_CENTAURUS_PULSE");

    // --- IMMUTABLES ---
    IReputationManager public immutable REPUTATION_MANAGER;
    IMonitoringHub public immutable MONITORING_HUB;
    IERC20 public immutable AOXC_TOKEN;
    CentaurusToken public immutable CENTAURUS_TOKEN;

    struct LogisticsPath {
        uint256 targetChainId;
        bool isVerified;
        uint256 signalStrength; // 0-100
    }

    mapping(uint256 => LogisticsPath) public activeRoutes;

    // --- EVENTS ---
    event RouteEstablished(uint256 indexed chainId, bool status);
    event SignalRecalibrated(uint256 indexed chainId, uint256 newStrength);
    event DispatchInitiated(address indexed actor, uint256 targetChainId, bytes32 dataHash);
    event SwapToAoxc(address indexed user, uint256 centaurusAmount, uint256 aoxcAmount);
    event SwapFromAoxc(address indexed user, uint256 aoxcAmount, uint256 centaurusAmount);

    modifier onlyQualified(bytes32 _deptId) {
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
        CENTAURUS_TOKEN = new CentaurusToken();

        _grantRole(DEFAULT_ADMIN_ROLE, _andromeda);
        _grantRole(CENTAURUS_CAPTAIN_ROLE, _captain);
    }

    // --- CORE BRIDGE OPERATIONS ---

    function dispatchData(
        uint256 _targetChain,
        bytes32 _dataHash
    ) external onlyQualified(CENTAURUS_KINETIC) nonReentrant {
        if (!activeRoutes[_targetChain].isVerified) revert RouteNotVerified(_targetChain);

        _log(IMonitoringHub.Severity.INFO, "LOGISTICS", "Data dispatch initiated.");
        emit DispatchInitiated(msg.sender, _targetChain, _dataHash);
    }

    function establishRoute(
        uint256 _chainId,
        uint256 _strength
    ) external onlyQualified(CENTAURUS_APEX) {
        activeRoutes[_chainId] = LogisticsPath({
            targetChainId: _chainId,
            isVerified: true,
            signalStrength: _strength
        });

        _log(IMonitoringHub.Severity.WARNING, "DIPLOMACY", "New cross-chain route established.");
        emit RouteEstablished(_chainId, true);
    }

    function heartbeatSignal(
        uint256 _chainId,
        uint256 _newStrength
    ) external onlyQualified(CENTAURUS_PULSE) {
        activeRoutes[_chainId].signalStrength = _newStrength;
        emit SignalRecalibrated(_chainId, _newStrength);
    }

    // --- SWAP FUNCTIONS ---

    function swapToAoxc(uint256 _centaurusAmount) external nonReentrant {
        CENTAURUS_TOKEN.safeTransferFrom(msg.sender, address(this), _centaurusAmount);
        AOXC_TOKEN.safeTransfer(msg.sender, _centaurusAmount);
        emit SwapToAoxc(msg.sender, _centaurusAmount, _centaurusAmount);
    }

    function swapFromAoxc(uint256 _aoxcAmount) external nonReentrant {
        AOXC_TOKEN.safeTransferFrom(msg.sender, address(this), _aoxcAmount);
        CENTAURUS_TOKEN.safeTransfer(msg.sender, _aoxcAmount);
        emit SwapFromAoxc(msg.sender, _aoxcAmount, _aoxcAmount);
    }

    // --- HELPERS ---

    function _checkRank(bytes32 _deptId) internal view {
        uint256 currentRank = REPUTATION_MANAGER.getRank(msg.sender);
        uint256 required = _getRequiredRank(_deptId);
        if (currentRank < required) {
            revert RankInsufficient(required, currentRank);
        }
    }

    function _getRequiredRank(bytes32 _deptId) internal pure returns (uint256) {
        if (_deptId == CENTAURUS_APEX) return 6;
        if (_deptId == CENTAURUS_NEURAL) return 5;
        if (_deptId == CENTAURUS_KINETIC || _deptId == CENTAURUS_AEGIS) return 4;
        if (_deptId == CENTAURUS_FLUX) return 3;
        if (_deptId == CENTAURUS_PULSE) return 2;
        return 255;
    }

    /**
     * @dev Memory bridge implemented to avoid Error 9553.
     */
    function _log(IMonitoringHub.Severity _sev, string memory _cat, string memory _det) internal {
        if (address(MONITORING_HUB) != address(0)) {
            MONITORING_HUB.emitLog(_sev, SECTOR_NAME, _cat, _det);
        }
    }
}
