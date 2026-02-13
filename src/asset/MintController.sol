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
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

// --- INTERNAL INTERFACES ---
import { AOXC } from "../core/AOXC.sol";
import { AssetBackingLedger } from "./AssetBackingLedger.sol";
import { IMonitoringHub } from "../interfaces/IMonitoringHub.sol";
import { IReputationManager } from "../interfaces/IReputationManager.sol";

/**
 * @title AOXCMintController
 * @notice Central hub for backed token issuance and redemption.
 * @dev Manages the relationship between assets in the Ledger and AOXC token supply.
 */
contract AOXCMintController is
    Initializable,
    AccessControlUpgradeable,
    PausableUpgradeable,
    UUPSUpgradeable,
    ReentrancyGuard
{
    // --- Access Control Roles ---
    bytes32 public constant MINTER_ROLE = keccak256("AOXC_MINTER_ROLE");
    bytes32 public constant ADMIN_ROLE = keccak256("AOXC_ADMIN_ROLE");
    bytes32 public constant OPERATOR_ROLE = keccak256("AOXC_OPERATOR_ROLE");

    // --- State Variables ---
    AssetBackingLedger public ledger;
    IMonitoringHub public monitoringHub;
    IReputationManager public reputationManager;

    mapping(bytes32 => IERC20) public assetIdToToken;
    mapping(bytes32 => bool) public frozenAssets;
    mapping(bytes32 => uint256) public maxMintPerTx;

    // --- Custom Errors ---
    error AOXC__ZeroAddress();
    error AOXC__InsufficientBacking();
    error AOXC__ExceedsMintLimit(uint256 requested, uint256 limit);
    error AOXC__AssetFrozen(bytes32 assetId);
    error AOXC__InvalidToken();

    // --- Events ---
    event TokensMinted(
        address indexed caller, address indexed to, uint256 amount, bytes32 indexed assetId
    );
    event TokensRedeemed(
        address indexed caller, address indexed from, uint256 amount, bytes32 indexed assetId
    );

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    /**
     * @notice Initializes the Mint Controller.
     */
    function initialize(
        address admin,
        address _ledger,
        address _monitoringHub,
        address _reputationManager
    ) external initializer {
        if (admin == address(0) || _ledger == address(0) || _monitoringHub == address(0)) {
            revert AOXC__ZeroAddress();
        }

        __AccessControl_init();
        __Pausable_init();

        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(ADMIN_ROLE, admin);
        _grantRole(MINTER_ROLE, admin);
        _grantRole(OPERATOR_ROLE, admin);

        ledger = AssetBackingLedger(_ledger);
        monitoringHub = IMonitoringHub(_monitoringHub);
        reputationManager = IReputationManager(_reputationManager);

        _notifyHub(IMonitoringHub.Severity.INFO, "INITIALIZE", "MintController Online");
    }

    /**
     * @notice Mints new AOXC by utilizing asset backing from the Ledger.
     */
    function mint(address to, uint256 amount, bytes32 assetId)
        external
        whenNotPaused
        nonReentrant
        onlyRole(MINTER_ROLE)
    {
        if (to == address(0)) revert AOXC__ZeroAddress();
        if (frozenAssets[assetId]) revert AOXC__AssetFrozen(assetId);

        uint256 limit = maxMintPerTx[assetId];
        if (limit > 0 && amount > limit) revert AOXC__ExceedsMintLimit(amount, limit);

        // 1. Withdraw backing from Ledger
        ledger.withdrawAsset(assetId, amount);

        // 2. Token Issuance
        AOXC targetToken = AOXC(address(assetIdToToken[assetId]));
        if (address(targetToken) == address(0)) revert AOXC__InvalidToken();
        targetToken.mint(to, amount);

        // 3. Reputation Processing
        if (address(reputationManager) != address(0)) {
            try reputationManager.processAction(to, keccak256("MINT_ASSET")) { } catch { }
        }

        emit TokensMinted(msg.sender, to, amount, assetId);
        _notifyHub(IMonitoringHub.Severity.INFO, "MINT_SUCCESS", "Asset-backed issuance complete");
    }

    /**
     * @notice Burns AOXC and restores the backing asset in the Ledger.
     */
    function redeem(uint256 amount, bytes32 assetId) external whenNotPaused nonReentrant {
        if (frozenAssets[assetId]) revert AOXC__AssetFrozen(assetId);

        AOXC targetToken = AOXC(address(assetIdToToken[assetId]));
        if (address(targetToken) == address(0)) revert AOXC__InvalidToken();

        // 1. Burn Tokens (Deducted from caller)
        targetToken.burn(msg.sender, amount);

        // 2. Restore backing to Ledger
        ledger.depositAsset(assetId, amount);

        emit TokensRedeemed(msg.sender, msg.sender, amount, assetId);
        _notifyHub(IMonitoringHub.Severity.INFO, "REDEEM_SUCCESS", "Collateral backing restored");
    }

    // --- Admin & Safety Controls ---

    function setAssetMapping(bytes32 assetId, address tokenAddress) external onlyRole(ADMIN_ROLE) {
        if (tokenAddress == address(0)) revert AOXC__ZeroAddress();
        assetIdToToken[assetId] = IERC20(tokenAddress);
        _notifyHub(IMonitoringHub.Severity.WARNING, "CONFIG_UPDATE", "Asset mapping changed");
    }

    function setSafetyLimit(bytes32 assetId, uint256 limit) external onlyRole(ADMIN_ROLE) {
        maxMintPerTx[assetId] = limit;
        _notifyHub(IMonitoringHub.Severity.WARNING, "CONFIG_UPDATE", "Safety limit adjusted");
    }

    function toggleFreeze(bytes32 assetId, bool status) external onlyRole(OPERATOR_ROLE) {
        frozenAssets[assetId] = status;
        _notifyHub(
            status ? IMonitoringHub.Severity.CRITICAL : IMonitoringHub.Severity.WARNING,
            "SECURITY_ACTION",
            status ? "Asset Frozen" : "Asset Unfrozen"
        );
    }

    // --- Internal Helpers ---

    /**
     * @dev High-fidelity 26-channel forensic logging.
     */
    function _notifyHub(
        IMonitoringHub.Severity severity,
        string memory action,
        string memory message
    ) internal {
        if (address(monitoringHub) != address(0)) {
            IMonitoringHub.ForensicLog memory log = IMonitoringHub.ForensicLog({
                source: address(this),
                actor: msg.sender,
                origin: tx.origin,
                related: address(0),
                severity: severity,
                category: "MINT_CONTROLLER",
                details: message,
                riskScore: 0,
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

            try monitoringHub.logForensic(log) { } catch { }
        }
    }

    function _authorizeUpgrade(address) internal override onlyRole(ADMIN_ROLE) {
        _notifyHub(IMonitoringHub.Severity.CRITICAL, "UPGRADE", "Controller upgrade authorized");
    }

    uint256[43] private _gap;
}
