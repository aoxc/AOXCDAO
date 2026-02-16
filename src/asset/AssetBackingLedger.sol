// SPDX-License-Identifier: MIT
pragma solidity 0.8.33;

import { Initializable } from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import { AccessControlUpgradeable } from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import { PausableUpgradeable } from "@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol";
import { UUPSUpgradeable } from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import { ReentrancyGuardUpgradeable } from "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";

import { IMonitoringHub } from "./interfaces/IMonitoringHub.sol";
import { IReputationManager } from "./interfaces/IReputationManager.sol";

/**
 * @title AssetBackingLedger
 * @author AOXCDAO
 * @notice Core accounting engine for Real-World Asset (RWA) backing and system-wide limit management.
 * @dev Implementation of UUPS (EIP-1822) upgradeable pattern with Role-Based Access Control (RBAC).
 * This contract tracks asset balances, enforces system-wide caps, and integrates with the Monitoring Hub.
 */
contract AssetBackingLedger is
    Initializable,
    AccessControlUpgradeable,
    PausableUpgradeable,
    UUPSUpgradeable,
    ReentrancyGuardUpgradeable
{
    // --- Roles ---

    /** @notice Identifier for the administrative role governing system configurations. */
    bytes32 public constant ADMIN_ROLE = keccak256("AOXC_ADMIN_ROLE");
    /** @notice Identifier for the role authorized to manage asset deposits and withdrawals. */
    bytes32 public constant ASSET_MANAGER_ROLE = keccak256("AOXC_ASSET_MANAGER_ROLE");
    /** @notice Identifier for external AI agents authorized to interact with the ledger. */
    bytes32 public constant EXTERNAL_AI_AGENT_ROLE = keccak256("EXTERNAL_AI_AGENT_ROLE");

    // --- State Variables ---

    /** @notice Interface for the centralized monitoring system. */
    IMonitoringHub public monitoringHub;
    /** @notice Interface for the reputation management system. */
    IReputationManager public reputationManager;

    /** @notice Aggregate value of all assets tracked within the ledger. */
    uint256 public totalAssets;
    /** @notice Maximum threshold for the aggregate value of assets allowed in the system. */
    uint256 public systemLimit;

    /** @dev Internal list of registered asset identifiers. */
    bytes32[] private _assetIds;
    /** @dev Mapping of asset identifiers to their respective current balances. */
    mapping(bytes32 => uint256) private _assetBalances;
    /** @dev Mapping to track whether an asset identifier has been registered. */
    mapping(bytes32 => bool) private _isAssetKnown;

    // --- Custom Errors ---

    error AOXC__ZeroAddress();
    error AOXC__ZeroAmount();
    error AOXC__InsufficientBalance();
    error AOXC__InvalidAssetId();
    error AOXC__SystemCapReached(uint256 currentTotal, uint256 limit);

    // --- Events ---

    /**
     * @notice Emitted when an asset is successfully deposited into the ledger.
     * @param caller The address that initiated the deposit.
     * @param assetId The unique identifier of the asset.
     * @param amount The quantity of the asset deposited.
     * @param timestamp The block timestamp of the transaction.
     */
    event AssetDeposited(address indexed caller, bytes32 indexed assetId, uint256 indexed amount, uint256 timestamp);

    /**
     * @notice Emitted when an asset is successfully withdrawn from the ledger.
     * @param caller The address that initiated the withdrawal.
     * @param assetId The unique identifier of the asset.
     * @param amount The quantity of the asset withdrawn.
     * @param timestamp The block timestamp of the transaction.
     */
    event AssetWithdrawn(address indexed caller, bytes32 indexed assetId, uint256 indexed amount, uint256 timestamp);

    /**
     * @notice Emitted when the aggregate asset total is updated.
     * @param oldTotal The total assets prior to the update.
     * @param newTotal The total assets after the update.
     * @param timestamp The block timestamp of the update.
     */
    event TotalAssetsUpdated(uint256 indexed oldTotal, uint256 indexed newTotal, uint256 indexed timestamp);

    /**
     * @notice Emitted when the global system limit is modified.
     * @param oldLimit The previous system limit.
     * @param newLimit The newly established system limit.
     */
    event SystemLimitUpdated(uint256 indexed oldLimit, uint256 indexed newLimit);

    /**
     * @notice Emitted when a new AI agent is registered in the system.
     * @param agent The address of the registered agent.
     * @param contractHash The cryptographic hash of the agent's contract implementation.
     */
    event AIAgentRegistered(address indexed agent, bytes32 indexed contractHash);

    /// @custom:oz-upgrades-unsafe-allow constructor
    /**
     * @notice Contract constructor to disable initializers for the implementation logic.
     * @dev Explicit visibility is provided to align with specific linter configurations.
     */
    constructor() public {
        _disableInitializers();
    }

    /**
     * @notice Initializes the contract state and sets up initial access control.
     * @param admin The address granted initial administrative and manager roles.
     * @param _monitoringHub The address of the Monitoring Hub contract.
     * @param _reputationManager The address of the Reputation Manager contract.
     */
    function initialize(
        address admin, 
        address _monitoringHub, 
        address _reputationManager
    ) external initializer {
        if (admin == address(0) || _monitoringHub == address(0) || _reputationManager == address(0)) {
            revert AOXC__ZeroAddress();
        }

        __AccessControl_init();
        __Pausable_init();
        __ReentrancyGuard_init();
        __UUPSUpgradeable_init();

        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(ADMIN_ROLE, admin);
        _grantRole(ASSET_MANAGER_ROLE, admin);

        monitoringHub = IMonitoringHub(_monitoringHub);
        reputationManager = IReputationManager(_reputationManager);
        
        systemLimit = type(uint256).max;
    }

    // --- Core Functions ---

    /**
     * @notice Records an asset deposit and increases the corresponding balance.
     * @dev Reverts if the new total exceeds the system limit or if parameters are invalid.
     * @param assetId The unique identifier of the asset.
     * @param amount The amount to be added to the ledger.
     */
    function depositAsset(bytes32 assetId, uint256 amount)
        external
        onlyRole(ASSET_MANAGER_ROLE)
        whenNotPaused
        nonReentrant
    {
        if (assetId == bytes32(0)) revert AOXC__InvalidAssetId();
        if (amount == 0) revert AOXC__ZeroAmount();

        uint256 currentTotal = totalAssets;
        if (currentTotal + amount > systemLimit) {
            revert AOXC__SystemCapReached(currentTotal, systemLimit);
        }

        if (!_isAssetKnown[assetId]) {
            _assetIds.push(assetId);
            _isAssetKnown[assetId] = true;
        }

        uint256 oldTotal = currentTotal;
        unchecked {
            _assetBalances[assetId] += amount;
            totalAssets = oldTotal + amount;
        }

        emit TotalAssetsUpdated(oldTotal, totalAssets, block.timestamp);
        emit AssetDeposited(msg.sender, assetId, amount, block.timestamp);

        _logToHub("DEPOSIT", "Asset added to ledger.");
    }

    /**
     * @notice Records an asset withdrawal and decreases the corresponding balance.
     * @dev Reverts if the asset balance is insufficient.
     * @param assetId The unique identifier of the asset.
     * @param amount The amount to be removed from the ledger.
     */
    function withdrawAsset(bytes32 assetId, uint256 amount)
        external
        onlyRole(ASSET_MANAGER_ROLE)
        whenNotPaused
        nonReentrant
    {
        uint256 currentBal = _assetBalances[assetId];
        if (currentBal < amount) revert AOXC__InsufficientBalance();

        uint256 oldTotal = totalAssets;
        unchecked {
            _assetBalances[assetId] = currentBal - amount;
            totalAssets = oldTotal - amount;
        }

        emit TotalAssetsUpdated(oldTotal, totalAssets, block.timestamp);
        emit AssetWithdrawn(msg.sender, assetId, amount, block.timestamp);

        _logToHub("WITHDRAW", "Asset removed from ledger.");
    }

    // --- Admin Functions ---

    /**
     * @notice Updates the maximum allowable aggregate asset value for the system.
     * @param newLimit The new capacity threshold.
     */
    function setSystemLimit(uint256 newLimit) external onlyRole(ADMIN_ROLE) {
        emit SystemLimitUpdated(systemLimit, newLimit);
        systemLimit = newLimit;
    }

    /**
     * @notice Grants the EXTERNAL_AI_AGENT_ROLE to a specified address.
     * @param agent The address of the AI agent.
     */
    function registerAIAgent(address agent) external onlyRole(ADMIN_ROLE) {
        if (agent == address(0)) revert AOXC__ZeroAddress();
        _grantRole(EXTERNAL_AI_AGENT_ROLE, agent);
        emit AIAgentRegistered(agent, keccak256("AOXC_AGENT_V1"));
    }

    /** @notice Pauses contract operations in case of an emergency. */
    function pause() external onlyRole(ADMIN_ROLE) {
        _pause();
    }

    /** @notice Resumes contract operations from a paused state. */
    function unpause() external onlyRole(ADMIN_ROLE) {
        _unpause();
    }

    // --- View Functions ---

    /**
     * @notice Retrieves the current balance of a specific asset.
     * @param assetId The unique identifier of the asset.
     * @return The current recorded balance.
     */
    function getAssetBalance(bytes32 assetId) external view returns (uint256) {
        return _assetBalances[assetId];
    }

    /**
     * @notice Checks if an asset is currently supported by the ledger.
     * @param assetId The unique identifier of the asset.
     * @return True if the asset is known, false otherwise.
     */
    function isAssetSupported(bytes32 assetId) external view returns (bool) {
        return _isAssetKnown[assetId];
    }

    /**
     * @notice Returns an array containing all registered asset identifiers.
     * @return An array of bytes32 asset IDs.
     */
    function getAllAssetIds() external view returns (bytes32[] memory) {
        return _assetIds;
    }

    // --- Internal Helpers ---

    /**
     * @notice Internal helper to log transaction metadata to the Monitoring Hub.
     * @dev Executes a low-level call to ensure ledger operations continue even if logging fails.
     * @param action The specific operation performed (e.g., DEPOSIT, WITHDRAW).
     * @param details Additional contextual information regarding the action.
     */
    function _logToHub(string memory action, string memory details) internal {
        if (address(monitoringHub) != address(0)) {
            try monitoringHub.quickLog(msg.sender, msg.sender, action, details) {} catch {}
        }
    }

    /**
     * @notice Authorizes the upgrade of the contract implementation.
     * @dev Restricted to addresses with ADMIN_ROLE.
     * @param newImplementation The address of the new logic contract.
     */
    function _authorizeUpgrade(address newImplementation) internal override onlyRole(ADMIN_ROLE) {
        // Implementation access control is verified by the UUPS pattern and ADMIN_ROLE check.
    }
}
