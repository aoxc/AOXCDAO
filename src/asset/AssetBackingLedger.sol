// SPDX-License-Identifier: MIT
pragma solidity 0.8.33;

import { Initializable } from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {
    AccessControlUpgradeable
} from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import {
    PausableUpgradeable
} from "@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol";
import {
    UUPSUpgradeable
} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import { ReentrancyGuard } from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

import { IMonitoringHub } from "../interfaces/IMonitoringHub.sol";
import { IReputationManager } from "../interfaces/IReputationManager.sol";

/**
 * @title AssetBackingLedger
 * @author AOXC Core Engineering
 * @notice Central accounting module for collateral assets in the AOXC ecosystem.
 * @dev Fully compliant with 26-channel MonitoringHub and UUPS Proxy pattern (OZ v5).
 */
contract AssetBackingLedger is
    Initializable,
    AccessControlUpgradeable,
    PausableUpgradeable,
    UUPSUpgradeable,
    ReentrancyGuard
{
    // --- Roles ---
    bytes32 public constant ADMIN_ROLE = keccak256("AOXC_ADMIN_ROLE");
    bytes32 public constant ASSET_MANAGER_ROLE = keccak256("AOXC_ASSET_MANAGER_ROLE");
    bytes32 public constant OPERATOR_ROLE = keccak256("AOXC_OPERATOR_ROLE");

    // --- State Variables ---
    IMonitoringHub public monitoringHub;
    IReputationManager public reputationManager;

    uint256 public totalAssets;
    uint256 public systemLimit;

    bytes32[] private _assetIds;
    mapping(bytes32 => uint256) private _assetBalances;
    mapping(bytes32 => bool) private _isAssetKnown;

    // --- Custom Errors ---
    error AOXC__ZeroAddress();
    error AOXC__ZeroAmount();
    error AOXC__InsufficientBalance();
    error AOXC__InvalidAssetId();
    error AOXC__SystemCapReached(uint256 currentTotal, uint256 limit);
    error AOXC__OnlyTimelock();

    // --- Events ---
    event AssetDeposited(
        address indexed caller, bytes32 indexed assetId, uint256 amount, uint256 timestamp
    );
    event AssetWithdrawn(
        address indexed caller, bytes32 indexed assetId, uint256 amount, uint256 timestamp
    );
    event TotalAssetsUpdated(uint256 oldTotal, uint256 newTotal, uint256 timestamp);
    event SystemLimitUpdated(uint256 oldLimit, uint256 newLimit);

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    /**
     * @notice Proxy initialization.
     */
    function initialize(address admin, address _monitoringHub, address _reputationManager)
        external
        initializer
    {
        if (admin == address(0) || _monitoringHub == address(0)) {
            revert AOXC__ZeroAddress();
        }

        __AccessControl_init();
        __Pausable_init();
        // NOT: OpenZeppelin v5'te __UUPSUpgradeable_init() kaldırılmıştır.

        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(ADMIN_ROLE, admin);
        _grantRole(ASSET_MANAGER_ROLE, admin);
        _grantRole(OPERATOR_ROLE, admin);

        monitoringHub = IMonitoringHub(_monitoringHub);
        reputationManager = IReputationManager(_reputationManager);
        systemLimit = type(uint128).max;

        _logToHub(IMonitoringHub.Severity.INFO, "INITIALIZE", "Asset Ledger Online");
    }

    // --- External Operations ---

    function depositAsset(bytes32 assetId, uint256 amount)
        external
        onlyRole(ASSET_MANAGER_ROLE)
        whenNotPaused
        nonReentrant
    {
        if (assetId == bytes32(0)) revert AOXC__InvalidAssetId();
        if (amount == 0) revert AOXC__ZeroAmount();

        if (totalAssets + amount > systemLimit) {
            _logToHub(IMonitoringHub.Severity.WARNING, "LIMIT_EXCEEDED", "Deposit blocked by cap");
            revert AOXC__SystemCapReached(totalAssets, systemLimit);
        }

        if (!_isAssetKnown[assetId]) {
            _assetIds.push(assetId);
            _isAssetKnown[assetId] = true;
        }

        uint256 oldTotal = totalAssets;
        unchecked {
            _assetBalances[assetId] += amount;
            totalAssets += amount;
        }

        if (address(reputationManager) != address(0)) {
            try reputationManager.processAction(msg.sender, keccak256("ASSET_LEDGER_UPDATE")) { }
                catch { }
        }

        emit TotalAssetsUpdated(oldTotal, totalAssets, block.timestamp);
        emit AssetDeposited(msg.sender, assetId, amount, block.timestamp);

        _logToHub(IMonitoringHub.Severity.INFO, "ASSET_DEPOSIT", "Collateral increased");
    }

    function withdrawAsset(bytes32 assetId, uint256 amount)
        external
        onlyRole(ASSET_MANAGER_ROLE)
        whenNotPaused
        nonReentrant
    {
        if (assetId == bytes32(0)) revert AOXC__InvalidAssetId();
        if (amount == 0) revert AOXC__ZeroAmount();

        uint256 currentBalance = _assetBalances[assetId];
        if (currentBalance < amount) revert AOXC__InsufficientBalance();

        uint256 oldTotal = totalAssets;
        unchecked {
            _assetBalances[assetId] = currentBalance - amount;
            totalAssets = oldTotal - amount;
        }

        emit TotalAssetsUpdated(oldTotal, totalAssets, block.timestamp);
        emit AssetWithdrawn(msg.sender, assetId, amount, block.timestamp);

        _logToHub(IMonitoringHub.Severity.INFO, "ASSET_WITHDRAW", "Collateral decreased");
    }

    // --- Governance ---

    function setSystemLimit(uint256 newLimit) external onlyRole(DEFAULT_ADMIN_ROLE) {
        uint256 old = systemLimit;
        systemLimit = newLimit;
        emit SystemLimitUpdated(old, newLimit);
        _logToHub(IMonitoringHub.Severity.WARNING, "GOVERNANCE", "Asset limit adjusted");
    }

    // --- Internal Helpers ---

    /**
     * @notice High-fidelity 26-channel forensic logging.
     */
    function _logToHub(
        IMonitoringHub.Severity severity,
        string memory action,
        string memory details
    ) internal {
        if (address(monitoringHub) != address(0)) {
            IMonitoringHub.ForensicLog memory log = IMonitoringHub.ForensicLog({
                source: address(this),
                actor: msg.sender,
                origin: tx.origin,
                related: address(0),
                severity: severity,
                category: "ASSET_LEDGER",
                details: details,
                riskScore: 0,
                nonce: 0,
                chainId: block.chainid,
                blockNumber: block.number,
                timestamp: block.timestamp,
                gasUsed: gasleft(),
                value: msg.value,
                stateRoot: bytes32(0),
                txHash: bytes32(0), // Will be visible on-chain via tx
                selector: msg.sig,
                version: 1,
                actionReq: severity == IMonitoringHub.Severity.EMERGENCY,
                isUpgraded: false,
                environment: 0, // 0: Production
                correlationId: bytes32(0),
                policyHash: bytes32(0),
                sequenceId: 0,
                metadata: abi.encodePacked(action),
                proof: ""
            });

            try monitoringHub.logForensic(log) { } catch { }
        }
    }

    function _authorizeUpgrade(address) internal override onlyRole(ADMIN_ROLE) {
        _logToHub(IMonitoringHub.Severity.CRITICAL, "UPGRADE", "Auth upgrade requested");
    }

    // --- Storage Gap ---
    uint256[43] private _gap;
}
