// SPDX-License-Identifier: MIT
pragma solidity 0.8.33;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { ReentrancyGuard } from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import { Pausable } from "@openzeppelin/contracts/utils/Pausable.sol";
import { AccessControl } from "@openzeppelin/contracts/access/AccessControl.sol";
import { IMonitoringHub } from "../interfaces/IMonitoringHub.sol";

interface ITreasury {
    function withdraw(address token, address to, uint256 amount) external;
}

interface IPyth {
    struct Price {
        int64 price;
        uint64 conf;
        int32 expo;
        uint256 publishTime;
    }
    function getPriceNoOlderThan(bytes32 id, uint256 age) external view returns (Price memory);
}

/**
 * @title AOXCSwap
 * @author AOXC Core Engineering
 * @notice Ultimate swap infrastructure with 26-channel DAO Risk Engine and Forensic Hub.
 * @dev Fully compliant with forge-lint standards and Akdeniz V2 security protocols.
 */
contract AOXCSwap is ReentrancyGuard, Pausable, AccessControl {
    using SafeERC20 for IERC20;

    // --- Roles (DAO Departments) ---
    bytes32 public constant SWAP_ADMIN_ROLE = keccak256("SWAP_ADMIN_ROLE");
    bytes32 public constant RISK_MANAGER_ROLE = keccak256("RISK_MANAGER_ROLE");

    // --- Infrastructure Immutables (Lint: SCREAMING_SNAKE_CASE) ---
    ITreasury public immutable TREASURY;
    IERC20 public immutable AOXC_TOKEN;
    IPyth public immutable PYTH;
    IMonitoringHub public immutable MONITORING_HUB;

    bytes32 public constant OKB_PRICE_ID =
        0x39d15024467d16374971485675e2f782c5f94d9b4b0a48b8b091f86c2d499317;

    // --- Risk Parameters ---
    uint256 public highValueThreshold = 1000 ether;
    uint256 public constant MAX_SLIPPAGE_DEVIATION = 500; // 5% base

    // --- State ---
    bool public isAutomatedRate = true;
    uint256 public manualRate;

    // --- Custom Errors ---
    error Swap__ZeroValue();
    error Swap__SlippageViolation(uint256 received, uint256 expected);
    error Swap__OracleFailure();
    error Swap__TreasuryFailure();
    error Swap__UnauthorizedAction();

    constructor(
        address _treasury,
        address _aoxc,
        address _pyth,
        address _monitoringHub,
        address _admin
    ) {
        TREASURY = ITreasury(_treasury);
        AOXC_TOKEN = IERC20(_aoxc);
        PYTH = IPyth(_pyth);
        MONITORING_HUB = IMonitoringHub(_monitoringHub);

        _grantRole(DEFAULT_ADMIN_ROLE, _admin);
        _grantRole(SWAP_ADMIN_ROLE, _admin);
        _grantRole(RISK_MANAGER_ROLE, _admin);
    }

    /**
     * @notice Primary Swap Entrypoint.
     * @param minAoxcOut Minimum amount of AOXC expected (Lint: mixedCase compliant).
     */
    function swapOkBtoAoxc(uint256 minAoxcOut) external payable nonReentrant whenNotPaused {
        uint256 amountIn = msg.value;
        if (amountIn == 0) revert Swap__ZeroValue();

        // 1. Fetch Rate & Calculate Output
        (uint256 currentRate, uint256 rawPrice) = _fetchValidatedRate();
        uint256 amountOut = (amountIn * currentRate) / 1e18;

        // 2. Pre-Execution Risk Check
        uint8 riskScore = _calculateRiskScore(amountIn, amountOut, minAoxcOut);

        if (amountOut < minAoxcOut) {
            _reportToHub(
                IMonitoringHub.Severity.WARNING,
                "RISK_ENGINE",
                "Slippage Violation Blocked",
                riskScore
            );
            revert Swap__SlippageViolation(amountOut, minAoxcOut);
        }

        // 3. Treasury Logic
        (bool success, ) = payable(address(TREASURY)).call{ value: amountIn }("");
        if (!success) {
            _reportToHub(
                IMonitoringHub.Severity.CRITICAL,
                "FINANCE_CHANNEL",
                "Treasury Inbound Failed",
                99
            );
            revert Swap__TreasuryFailure();
        }

        // 4. Asset Release
        TREASURY.withdraw(address(AOXC_TOKEN), msg.sender, amountOut);

        // 5. Final Forensic Reporting
        _reportToHub(
            riskScore > 50 ? IMonitoringHub.Severity.WARNING : IMonitoringHub.Severity.INFO,
            "SWAP_EXECUTED",
            string(abi.encodePacked("In:", _uint2str(amountIn), " Rate:", _uint2str(rawPrice))),
            riskScore
        );
    }

    // --- Internal Engines ---

    function _fetchValidatedRate() internal view returns (uint256 normalized, uint256 raw) {
        if (!isAutomatedRate) return (manualRate, 0);
        try PYTH.getPriceNoOlderThan(OKB_PRICE_ID, 60) returns (IPyth.Price memory p) {
            if (p.price <= 0) revert Swap__OracleFailure();
            return (uint256(uint64(p.price)) * 10 ** 10, uint256(uint64(p.price)));
        } catch {
            revert Swap__OracleFailure();
        }
    }

    function _calculateRiskScore(
        uint256 _in,
        uint256 _out,
        uint256 _min
    ) internal view returns (uint8) {
        uint8 score = 10;
        if (_in >= highValueThreshold) score += 40;
        if (_out == _min) score += 20;
        return score;
    }

    function _reportToHub(
        IMonitoringHub.Severity severity,
        string memory category,
        string memory details,
        uint8 riskScore
    ) internal {
        if (address(MONITORING_HUB) != address(0)) {
            IMonitoringHub.ForensicLog memory log = IMonitoringHub.ForensicLog({
                source: address(this),
                actor: msg.sender,
                origin: tx.origin,
                related: address(AOXC_TOKEN),
                severity: severity,
                category: category,
                details: details,
                riskScore: riskScore,
                nonce: 0,
                chainId: block.chainid,
                blockNumber: block.number,
                timestamp: block.timestamp,
                gasUsed: gasleft(),
                value: msg.value,
                stateRoot: bytes32(0),
                txHash: bytes32(0),
                selector: msg.sig,
                version: 2,
                actionReq: severity >= IMonitoringHub.Severity.CRITICAL,
                isUpgraded: false,
                environment: 1,
                correlationId: bytes32(0),
                policyHash: bytes32(0),
                sequenceId: 0,
                metadata: "",
                proof: ""
            });
            try MONITORING_HUB.logForensic(log) {} catch {}
        }
    }

    // --- DAO Management ---

    function updateRiskThreshold(uint256 _newThreshold) external onlyRole(RISK_MANAGER_ROLE) {
        highValueThreshold = _newThreshold;
        _reportToHub(IMonitoringHub.Severity.INFO, "GOVERNANCE", "Risk threshold updated", 0);
    }

    function emergencyPause() external onlyRole(SWAP_ADMIN_ROLE) {
        _pause();
        _reportToHub(IMonitoringHub.Severity.CRITICAL, "EMERGENCY", "System Halted", 100);
    }

    /**
     * @dev Converts uint to string with lint-safe typecasting.
     */
    function _uint2str(uint256 _i) internal pure returns (string memory) {
        if (_i == 0) return "0";
        uint256 j = _i;
        uint256 len;
        while (j != 0) len++;
        j /= 10;
        bytes memory bstr = new bytes(len);
        uint256 k = len;
        while (_i != 0) {
            // casting to 'uint8' is safe because 48 + (0-9) is always < 255
            // forge-lint: disable-next-line(unsafe-typecast)
            bstr[--k] = bytes1(uint8(48 + (_i % 10)));
            _i /= 10;
        }
        return string(bstr);
    }
}
