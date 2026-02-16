// SPDX-License-Identifier: MIT
pragma solidity 0.8.33;

import { Initializable } from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import { AccessControlUpgradeable } from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import { PausableUpgradeable } from "@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol";
import { UUPSUpgradeable } from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import { ReentrancyGuard } from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

// --- INTERNAL INTERFACES ---
import { AOXC } from "../core/AOXC.sol";
import { AssetBackingLedger } from "./AssetBackingLedger.sol";
import { IMonitoringHub } from "@interfaces/IMonitoringHub.sol";
import { IReputationManager } from "@interfaces/IReputationManager.sol";

/**
 * @title AOXCMintController
 * @author AOXC Protocol Team
 * @notice Central hub for backed token issuance and redemption.
 * @dev Manages the relationship between assets in the Ledger and AOXC token supply.
 * Implements UUPS upgradeability pattern and rigorous access control.
 */
contract AOXCMintController is
    Initializable,
    AccessControlUpgradeable,
    PausableUpgradeable,
    UUPSUpgradeable,
    ReentrancyGuard
{
    // --- Access Control Roles ---

    /// @notice Role for addresses authorized to mint new tokens.
    bytes32 public constant MINTER_ROLE = keccak256("AOXC_MINTER_ROLE");
    /// @notice Role for administrative configuration and upgrades.
    bytes32 public constant ADMIN_ROLE = keccak256("AOXC_ADMIN_ROLE");
    /// @notice Role for emergency actions like freezing assets.
    bytes32 public constant OPERATOR_ROLE = keccak256("AOXC_OPERATOR_ROLE");

    // --- State Variables ---

    /// @notice Reference to the Asset Backing Ledger contract.
    AssetBackingLedger public ledger;
    /// @notice Reference to the centralized monitoring and logging hub.
    IMonitoringHub public monitoringHub;
    /// @notice Reference to the reputation scoring system.
    IReputationManager public reputationManager;

    /// @notice Mapping from asset identity hash to its corresponding ERC20 token.
    mapping(bytes32 => IERC20) public assetIdToToken;
    /// @notice Mapping to track if an asset's minting/redemption is halted.
    mapping(bytes32 => bool) public frozenAssets;
    /// @notice Maximum amount allowed to be minted in a single transaction per asset.
    mapping(bytes32 => uint256) public maxMintPerTx;

    // --- Custom Errors ---

    /// @dev Thrown when a zero address is provided where a valid address is required.
    error AOXC__ZeroAddress();
    /// @dev Thrown when the ledger does not have enough collateral.
    error AOXC__InsufficientBacking();
    /// @dev Thrown when a mint request exceeds the safety limit.
    /// @param requested The amount attempted to mint.
    /// @param limit The current safety limit for the asset.
    error AOXC__ExceedsMintLimit(uint256 requested, uint256 limit);
    /// @dev Thrown when attempting to interact with a frozen asset.
    /// @param assetId The unique identifier of the frozen asset.
    error AOXC__AssetFrozen(bytes32 assetId);
    /// @dev Thrown when the asset ID is not mapped to a valid token.
    error AOXC__InvalidToken();

    // --- Events ---

    /// @notice Emitted when new tokens are successfully minted.
    /// @param caller The address that triggered the minting.
    /// @param to The recipient of the minted tokens.
    /// @param amount The quantity of tokens issued.
    /// @param assetId The identifier of the backing asset.
    event TokensMinted(
        address indexed caller, 
        address indexed to, 
        uint256 amount, 
        bytes32 indexed assetId
    );

    /// @notice Emitted when tokens are redeemed for backing assets.
    /// @param caller The address that triggered the redemption.
    /// @param from The address from which tokens were burned.
    /// @param amount The quantity of tokens redeemed.
    /// @param assetId The identifier of the backing asset.
    event TokensRedeemed(
        address indexed caller, 
        address indexed from, 
        uint256 amount, 
        bytes32 indexed assetId
    );

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    /**
     * @notice Initializes the Mint Controller with core dependencies.
     * @dev Sets up roles and links external registry contracts.
     * @param admin The address granted administrative privileges.
     * @param _ledger The address of the AssetBackingLedger.
     * @param _monitoringHub The address of the MonitoringHub.
     * @param _reputationManager The address of the ReputationManager.
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
        __UUPSUpgradeable_init();
        __ReentrancyGuard_init();

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
     * @notice Mints new AOXC tokens by utilizing asset backing from the Ledger.
     * @dev Requires MINTER_ROLE. Validates safety limits and asset status.
     * @param to The recipient address for the new tokens.
     * @param amount The amount of tokens to mint.
     * @param assetId The identifier for the backing collateral.
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

        // 1. Withdraw backing from Ledger (Ensures collateral availability)
        ledger.withdrawAsset(assetId, amount);

        // 2. Token Issuance
        address tokenAddr = address(assetIdToToken[assetId]);
        if (tokenAddr == address(0)) revert AOXC__InvalidToken();
        
        AOXC(tokenAddr).mint(to, amount);

        // 3. Reputation Processing (Soft fail to ensure minting completes)
        if (address(reputationManager) != address(0)) {
            try reputationManager.processAction(to, keccak256("MINT_ASSET")) { } catch { }
        }

        emit TokensMinted(msg.sender, to, amount, assetId);
        _notifyHub(IMonitoringHub.Severity.INFO, "MINT_SUCCESS", "Asset-backed issuance complete");
    }

    /**
     * @notice Burns AOXC and restores the backing asset in the Ledger.
     * @dev The caller must have the required token balance.
     * @param amount The amount of tokens to redeem.
     * @param assetId The identifier of the backing collateral to restore.
     */
    function redeem(uint256 amount, bytes32 assetId) external whenNotPaused nonReentrant {
        if (frozenAssets[assetId]) revert AOXC__AssetFrozen(assetId);

        address tokenAddr = address(assetIdToToken[assetId]);
        if (tokenAddr == address(0)) revert AOXC__InvalidToken();

        // 1. Burn Tokens (Deducted from caller)
        AOXC(tokenAddr).burn(msg.sender, amount);

        // 2. Restore backing to Ledger
        ledger.depositAsset(assetId, amount);

        emit TokensRedeemed(msg.sender, msg.sender, amount, assetId);
        _notifyHub(IMonitoringHub.Severity.INFO, "REDEEM_SUCCESS", "Collateral backing restored");
    }

    // --- Admin & Safety Controls ---

    /**
     * @notice Configures the relationship between an asset ID and its ERC20 token.
     * @param assetId The unique identifier for the asset.
     * @param tokenAddress The contract address of the associated token.
     */
    function setAssetMapping(bytes32 assetId, address tokenAddress) external onlyRole(ADMIN_ROLE) {
        if (tokenAddress == address(0)) revert AOXC__ZeroAddress();
        assetIdToToken[assetId] = IERC20(tokenAddress);
        _notifyHub(IMonitoringHub.Severity.WARNING, "CONFIG_UPDATE", "Asset mapping changed");
    }

    /**
     * @notice Sets the maximum mintable amount per transaction for a specific asset.
     * @param assetId The identifier of the asset.
     * @param limit The maximum amount allowed.
     */
    function setSafetyLimit(bytes32 assetId, uint256 limit) external onlyRole(ADMIN_ROLE) {
        maxMintPerTx[assetId] = limit;
        _notifyHub(IMonitoringHub.Severity.WARNING, "CONFIG_UPDATE", "Safety limit adjusted");
    }

    /**
     * @notice Freezes or unfreezes minting/redemption for a specific asset.
     * @param assetId The identifier of the asset.
     * @param status True to freeze, false to unfreeze.
     */
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
     * @dev Internal helper for high-fidelity forensic logging via MonitoringHub.
     * @param severity The importance level of the log.
     * @param action Short string identifier for the action.
     * @param message Detailed description of the event.
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
                origin: msg.sender, // Replaced tx.origin with msg.sender for security compliance
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

    /**
     * @dev Internal function to authorize contract upgrades.
     * @param newImplementation The address of the new implementation contract.
     */
    function _authorizeUpgrade(address newImplementation) internal override onlyRole(ADMIN_ROLE) {
        _notifyHub(IMonitoringHub.Severity.CRITICAL, "UPGRADE", "Controller upgrade authorized");
    }

    /// @dev Storage gap for future upgradeability versions.
    uint256[43] private _gap;
}
