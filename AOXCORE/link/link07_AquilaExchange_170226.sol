// SPDX-License-Identifier: MIT
pragma solidity 0.8.33;

import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @dev Custom Errors - Gas tasarrufu ve net hata takibi sağlar.
 */
error RankInsufficient(uint256 required, uint256 actual);
error ZeroAddressDetected();
error MarketAlreadyHalted(bytes32 pair);
error InsufficientLiquidity();

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
    function emitLog(Severity severity, string calldata sector, string calldata category, string calldata details)
        external;
}

// --- AQUILA TOKEN ---
contract AquilaToken is ERC20 {
    constructor() ERC20("Aquila Exchange Token", "AQUILA") {
        _mint(msg.sender, 1_000_000 * 10 ** 18);
    }
}

/**
 * @title AquilaExchange
 * @notice SECTOR_ID 5: Economic Exchange and Liquidity Hub
 * @dev Re-engineered for audit compliance and gas efficiency.
 */
contract AquilaExchange is AccessControl, ReentrancyGuard {
    using SafeERC20 for IERC20;
    using SafeERC20 for AquilaToken;

    // --- CONSTANTS ---
    string public constant SECTOR_NAME = "AQUILA_EXCHANGE";
    uint256 public constant SECTOR_ID = 5;
    bytes32 public constant AQUILA_CAPTAIN_ROLE = keccak256("AQUILA_CAPTAIN_ROLE");

    // --- DEPARTMENTS ---
    bytes32 public constant AQUILA_APEX = keccak256("DEPT_AQUILA_APEX");
    bytes32 public constant AQUILA_KINETIC = keccak256("DEPT_AQUILA_KINETIC");
    bytes32 public constant AQUILA_FLUX = keccak256("DEPT_AQUILA_FLUX");
    bytes32 public constant AQUILA_NEURAL = keccak256("DEPT_AQUILA_NEURAL");
    bytes32 public constant AQUILA_AEGIS = keccak256("DEPT_AQUILA_AEGIS");
    bytes32 public constant AQUILA_PULSE = keccak256("DEPT_AQUILA_PULSE");

    // --- IMMUTABLES (Naming Convention Fixed) ---
    IReputationManager public immutable REPUTATION_MANAGER;
    IMonitoringHub public immutable MONITORING_HUB;
    IERC20 public immutable AOXC_TOKEN;
    AquilaToken public immutable AQUILA_TOKEN;

    struct MarketPair {
        uint256 tradeFee;
        uint256 volumeLimit;
        bool isTradingEnabled;
    }

    mapping(bytes32 => MarketPair) public registry;

    // --- EVENTS ---
    event TradeExecuted(address indexed trader, bytes32 indexed pair, uint256 amount);
    event LiquidityInjected(bytes32 indexed pair, uint256 amount);
    event MarketHalted(bytes32 indexed pair, string reason);
    event SwapToAoxc(address indexed user, uint256 aquilaAmount, uint256 aoxcAmount);
    event SwapFromAoxc(address indexed user, uint256 aoxcAmount, uint256 aquilaAmount);

    modifier onlyQualified(bytes32 _deptId) {
        _checkRank(_deptId);
        _;
    }

    constructor(address _reputation, address _monitoring, address _andromeda, address _captain, address _aoxcToken) {
        if (_reputation == address(0) || _monitoring == address(0) || _aoxcToken == address(0)) {
            revert ZeroAddressDetected();
        }

        REPUTATION_MANAGER = IReputationManager(_reputation);
        MONITORING_HUB = IMonitoringHub(_monitoring);
        AOXC_TOKEN = IERC20(_aoxcToken);
        AQUILA_TOKEN = new AquilaToken();

        _grantRole(DEFAULT_ADMIN_ROLE, _andromeda);
        _grantRole(AQUILA_CAPTAIN_ROLE, _captain);
    }

    // --- CORE OPERATIONS ---

    /**
     * @dev Liquidity management now emits event with data.
     * In a real DEX, this would interact with a pool contract.
     */
    function manageLiquidity(bytes32 _pair, uint256 _amount) external onlyQualified(AQUILA_FLUX) nonReentrant {
        // Audit Fix: Veriyi state'e yansıtıyoruz veya event ile doğruluyoruz
        registry[_pair].volumeLimit += _amount;

        _log(IMonitoringHub.Severity.INFO, "LIQUIDITY", "Liquidity adjustment executed.");
        emit LiquidityInjected(_pair, _amount);
    }

    function recalibratePricing(bytes32 _pair, uint256 _newFee) external onlyQualified(AQUILA_NEURAL) {
        registry[_pair].tradeFee = _newFee;
        _log(IMonitoringHub.Severity.WARNING, "ECONOMY", "Pricing model updated.");
    }

    function haltMarket(bytes32 _pair, string calldata _reason) external onlyQualified(AQUILA_AEGIS) {
        if (!registry[_pair].isTradingEnabled) {
            revert MarketAlreadyHalted(_pair);
        }

        registry[_pair].isTradingEnabled = false;
        _log(IMonitoringHub.Severity.CRITICAL, "SECURITY", "Market operation halted.");
        emit MarketHalted(_pair, _reason);
    }

    // --- SWAP FUNCTIONS (SafeERC20 Enforced) ---

    function swapToAoxc(uint256 _aquilaAmount) external nonReentrant {
        // SafeTransferFrom balance kontrolünü otomatik yapar
        AQUILA_TOKEN.safeTransferFrom(msg.sender, address(this), _aquilaAmount);

        // AOXCMainEngine transferi
        AOXC_TOKEN.safeTransfer(msg.sender, _aquilaAmount);

        emit SwapToAoxc(msg.sender, _aquilaAmount, _aquilaAmount);
    }

    function swapFromAoxc(uint256 _aoxcAmount) external nonReentrant {
        AOXC_TOKEN.safeTransferFrom(msg.sender, address(this), _aoxcAmount);
        AQUILA_TOKEN.safeTransfer(msg.sender, _aoxcAmount);

        emit SwapFromAoxc(msg.sender, _aoxcAmount, _aoxcAmount);
    }

    // --- INTERNAL HELPERS ---

    function _checkRank(bytes32 _deptId) internal view {
        uint256 currentRank = REPUTATION_MANAGER.getRank(msg.sender);
        uint256 required = _getRankRequirement(_deptId);
        if (currentRank < required) {
            revert RankInsufficient(required, currentRank);
        }
    }

    function _getRankRequirement(bytes32 _deptId) internal pure returns (uint256) {
        if (_deptId == AQUILA_APEX) return 6;
        if (_deptId == AQUILA_NEURAL) return 5;
        if (_deptId == AQUILA_KINETIC || _deptId == AQUILA_AEGIS) return 4;
        if (_deptId == AQUILA_FLUX) return 3;
        if (_deptId == AQUILA_PULSE) return 2;
        return 255;
    }

    function _log(IMonitoringHub.Severity _sev, string memory _cat, string memory _det) internal {
        if (address(MONITORING_HUB) != address(0)) {
            MONITORING_HUB.emitLog(_sev, SECTOR_NAME, _cat, _det);
        }
    }
}
