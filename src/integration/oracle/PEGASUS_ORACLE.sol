// SPDX-License-Identifier: MIT
pragma solidity 0.8.33;

import { AccessControl } from "@openzeppelin/contracts/access/AccessControl.sol";
import { ReentrancyGuard } from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

// --- CUSTOM ERRORS (Gas Optimization & Audit Readiness) ---
error RankInsufficient(uint256 required, uint256 actual);
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

// --- PEGASUS TOKEN ---
contract PegasusToken is ERC20 {
    constructor() ERC20("Pegasus Oracle Token", "PEGASUS") {
        _mint(msg.sender, 1_000_000 * 10 ** 18);
    }
}

/**
 * @title PegasusOracle
 * @notice SECTOR_ID 4: Oracle and Intelligence Synthesis
 * @dev Academic and Professional Grade Smart Contract with AOXP Multiplier Logic
 */
contract PegasusOracle is AccessControl, ReentrancyGuard {
    using SafeERC20 for IERC20;
    using SafeERC20 for PegasusToken;

    // --- CONSTANTS ---
    string public constant SECTOR_NAME = "PEGASUS_ORACLE";
    uint256 public constant SECTOR_ID = 4;

    // --- DEPARTMENT IDENTIFIERS ---
    bytes32 public constant PEGASUS_APEX = keccak256("DEPT_PEGASUS_APEX");
    bytes32 public constant PEGASUS_KINETIC = keccak256("DEPT_PEGASUS_KINETIC");
    bytes32 public constant PEGASUS_FLUX = keccak256("DEPT_PEGASUS_FLUX");
    bytes32 public constant PEGASUS_NEURAL = keccak256("DEPT_PEGASUS_NEURAL");
    bytes32 public constant PEGASUS_AEGIS = keccak256("DEPT_PEGASUS_AEGIS");
    bytes32 public constant PEGASUS_PULSE = keccak256("DEPT_PEGASUS_PULSE");

    bytes32 public constant PEGASUS_CAPTAIN_ROLE = keccak256("PEGASUS_CAPTAIN_ROLE");

    // --- IMMUTABLES (SCREAMING_SNAKE_CASE) ---
    IReputationManager public immutable REPUTATION_MANAGER;
    IMonitoringHub public immutable MONITORING_HUB;
    IERC20 public immutable AOXC_TOKEN;
    PegasusToken public immutable PEGASUS_TOKEN;

    struct IntelligenceReport {
        uint256 timestamp;
        uint256 value;
        bytes32 sourceHash;
        bool isValidated;
    }

    mapping(bytes32 => IntelligenceReport) public oracleRegistry;

    // --- EVENTS ---
    event IntelligenceSynthesized(bytes32 indexed dataKey, uint256 value, address indexed synther);
    event DataBlacklisted(bytes32 indexed dataKey, string reason);
    event SwapToAoxc(address indexed user, uint256 pegasusAmount, uint256 aoxcAmount);
    event SwapFromAoxc(address indexed user, uint256 aoxcAmount, uint256 pegasusAmount);
    event StreamIngested(bytes32 indexed dataKey, uint256 value);

    // --- MODIFIERS ---
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
        PEGASUS_TOKEN = new PegasusToken();

        _grantRole(DEFAULT_ADMIN_ROLE, _andromeda);
        _grantRole(PEGASUS_CAPTAIN_ROLE, _captain);
    }

    // --- CORE ORACLE OPERATIONS ---

    function synthesizeData(
        bytes32 _dataKey,
        uint256 _rawValue,
        bytes32 _proof
    ) external onlyQualified(PEGASUS_NEURAL) nonReentrant {
        oracleRegistry[_dataKey] = IntelligenceReport({
            timestamp: block.timestamp,
            value: _rawValue,
            sourceHash: _proof,
            isValidated: true
        });

        _log(IMonitoringHub.Severity.INFO, "SYNTHESIS", "New intelligence report finalized.");
        emit IntelligenceSynthesized(_dataKey, _rawValue, msg.sender);
    }

    /**
     * @dev IngestStream fixed to avoid 'Unused Function Parameter' warning.
     */
    function ingestStream(bytes32 _dataKey, uint256 _value) external onlyQualified(PEGASUS_PULSE) {
        emit StreamIngested(_dataKey, _value);
        _log(IMonitoringHub.Severity.DEBUG, "INGESTION", "Raw signal stream recorded.");
    }

    function invalidateData(
        bytes32 _dataKey,
        string calldata _reason
    ) external onlyQualified(PEGASUS_AEGIS) {
        oracleRegistry[_dataKey].isValidated = false;
        _log(IMonitoringHub.Severity.WARNING, "INTEGRITY", "Data set invalidated.");
        emit DataBlacklisted(_dataKey, _reason);
    }

    // --- SWAP FUNCTIONS (1:1 Ratio using SafeERC20) ---

    function swapToAoxc(uint256 pegasusAmount) external nonReentrant {
        PEGASUS_TOKEN.safeTransferFrom(msg.sender, address(this), pegasusAmount);
        AOXC_TOKEN.safeTransfer(msg.sender, pegasusAmount);

        emit SwapToAoxc(msg.sender, pegasusAmount, pegasusAmount);
    }

    function swapFromAoxc(uint256 aoxcAmount) external nonReentrant {
        AOXC_TOKEN.safeTransferFrom(msg.sender, address(this), aoxcAmount);
        PEGASUS_TOKEN.safeTransfer(msg.sender, aoxcAmount);

        emit SwapFromAoxc(msg.sender, aoxcAmount, aoxcAmount);
    }

    // --- INTERNAL HELPERS ---

    /**
     * @dev Logic moved to internal function to optimize bytecode and contract size.
     */
    function _checkRank(bytes32 _deptId) internal view {
        uint256 currentRank = REPUTATION_MANAGER.getRank(msg.sender);
        uint256 required = _getRankRequirement(_deptId);
        if (currentRank < required) {
            revert RankInsufficient(required, currentRank);
        }
    }

    function _getRankRequirement(bytes32 _deptId) internal pure returns (uint256) {
        if (_deptId == PEGASUS_APEX) return 6;
        if (_deptId == PEGASUS_NEURAL) return 5;
        if (_deptId == PEGASUS_KINETIC || _deptId == PEGASUS_AEGIS) return 4;
        if (_deptId == PEGASUS_FLUX) return 3;
        if (_deptId == PEGASUS_PULSE) return 2;
        return 255; // Safety fallback
    }

    function _log(IMonitoringHub.Severity _sev, string memory _cat, string memory _det) internal {
        if (address(MONITORING_HUB) != address(0)) {
            MONITORING_HUB.emitLog(_sev, SECTOR_NAME, _cat, _det);
        }
    }
}
