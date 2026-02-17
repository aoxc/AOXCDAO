// SPDX-License-Identifier: MIT
pragma solidity 0.8.33;

import {Initializable} from "@openzeppelin-upgradeable/proxy/utils/Initializable.sol";
import {AccessControlUpgradeable} from "@openzeppelin-upgradeable/access/AccessControlUpgradeable.sol";
import {PausableUpgradeable} from "@openzeppelin-upgradeable/utils/PausableUpgradeable.sol";
import {UUPSUpgradeable} from "@openzeppelin-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

import {IMonitoringHub} from "@api/api29_IMonitoringHub_170226.sol";
import {IReputationManager} from "@interfaces/api08_IReputationManager_170226.sol";

/**
 * @title AssetBackingLedger
 * @author AOXCDAO
 * @notice RWA muhasebe motoru ve sistem limit yönetim merkezi.
 * @dev UUPS mimarisi ve 26-parametre Forensic standartlarına tam uyumlu profesyonel sürüm.
 */
contract AssetBackingLedger is
    Initializable,
    AccessControlUpgradeable,
    PausableUpgradeable,
    UUPSUpgradeable,
    ReentrancyGuard
{
    // --- Constant Roles ---
    bytes32 public constant ADMIN_ROLE = keccak256("AOXC_ADMIN_ROLE");
    bytes32 public constant ASSET_MANAGER_ROLE = keccak256("AOXC_ASSET_MANAGER_ROLE");
    bytes32 public constant EXTERNAL_AI_AGENT_ROLE = keccak256("EXTERNAL_AI_AGENT_ROLE");

    // --- Action Tags ---
    bytes32 public constant ACTION_DEPOSIT = keccak256("ACTION_ASSET_DEPOSIT");
    bytes32 public constant ACTION_WITHDRAW = keccak256("ACTION_ASSET_WITHDRAW");

    // --- State Variables ---
    IMonitoringHub public monitoringHub;
    IReputationManager public reputationManager;

    uint256 public totalAssets;
    uint256 public systemLimit;

    bytes32[] private _assetIds;
    mapping(bytes32 => uint256) private _assetBalances;
    mapping(bytes32 => bool) private _isAssetKnown;

    struct AiAgentMetadata {
        bytes32 contractHash;
        uint256 registeredAt;
        uint256 totalOperations;
        bool isActive;
    }
    mapping(address => AiAgentMetadata) private _agentRegistry;
    uint256 public activeAgentCount;

    // --- Custom Errors ---
    error AOXC__ZeroAddress();
    error AOXC__ZeroAmount();
    error AOXC__InsufficientBalance();
    error AOXC__InvalidAssetId();
    error AOXC__SystemCapReached(uint256 current, uint256 limit);
    error AOXC__AgentAlreadyRegistered(address agent);
    error AOXC__InvalidContractHash();

    // --- Events ---
    event AssetDeposited(address indexed manager, bytes32 indexed assetId, uint256 amount, uint256 total);
    event AssetWithdrawn(address indexed manager, bytes32 indexed assetId, uint256 amount, uint256 total);
    event SystemLimitUpdated(uint256 oldLimit, uint256 newLimit);
    event AiAgentRegistered(address indexed agent, bytes32 indexed contractHash);
    event DependencyUpdated(address indexed monitoringHub, address indexed reputationManager);

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    /**
     * @notice Kontrat başlatıcı fonksiyon.
     */
    function initialize(address admin, address _monitoringHub, address _reputationManager) external initializer {
        if (admin == address(0) || _monitoringHub == address(0)) {
            revert AOXC__ZeroAddress();
        }

        __AccessControl_init();
        __Pausable_init();

        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(ADMIN_ROLE, admin);
        _grantRole(ASSET_MANAGER_ROLE, admin);

        monitoringHub = IMonitoringHub(_monitoringHub);
        reputationManager = IReputationManager(_reputationManager);

        systemLimit = type(uint256).max;

        _logToHub(IMonitoringHub.Severity.INFO, "LDR_INIT", "Ledger logic online.");
    }

    // --- Core Operations ---

    function depositAsset(bytes32 assetId, uint256 amount)
        external
        onlyRole(ASSET_MANAGER_ROLE)
        whenNotPaused
        nonReentrant
    {
        if (assetId == bytes32(0)) revert AOXC__InvalidAssetId();
        if (amount == 0) revert AOXC__ZeroAmount();
        if (totalAssets + amount > systemLimit) {
            revert AOXC__SystemCapReached(totalAssets, systemLimit);
        }

        if (!_isAssetKnown[assetId]) {
            _assetIds.push(assetId);
            _isAssetKnown[assetId] = true;
        }

        _processAccounting(assetId, amount, true);
        emit AssetDeposited(msg.sender, assetId, amount, totalAssets);
        _logToHub(IMonitoringHub.Severity.INFO, "DEP_SUC", "Deposit verified.");
    }

    function withdrawAsset(bytes32 assetId, uint256 amount)
        external
        onlyRole(ASSET_MANAGER_ROLE)
        whenNotPaused
        nonReentrant
    {
        uint256 balance = _assetBalances[assetId];
        if (balance < amount) revert AOXC__InsufficientBalance();

        _processAccounting(assetId, amount, false);
        emit AssetWithdrawn(msg.sender, assetId, amount, totalAssets);
        _logToHub(IMonitoringHub.Severity.WARNING, "WIT_SUC", "Withdrawal verified.");
    }

    function _processAccounting(bytes32 assetId, uint256 amount, bool isIncrease) internal {
        if (isIncrease) {
            _assetBalances[assetId] += amount;
            totalAssets += amount;
            _triggerReputation(ACTION_DEPOSIT);
        } else {
            _assetBalances[assetId] -= amount;
            totalAssets -= amount;
            _triggerReputation(ACTION_WITHDRAW);
        }

        if (hasRole(EXTERNAL_AI_AGENT_ROLE, msg.sender)) {
            _agentRegistry[msg.sender].totalOperations++;
        }
    }

    // --- Admin Functions ---

    function setSystemLimit(uint256 newLimit) external onlyRole(ADMIN_ROLE) {
        emit SystemLimitUpdated(systemLimit, newLimit);
        systemLimit = newLimit;
    }

    function registerAiAgent(address agent, bytes32 contractHash) external onlyRole(ADMIN_ROLE) {
        if (agent == address(0) || contractHash == bytes32(0)) revert AOXC__ZeroAddress();
        if (_agentRegistry[agent].isActive) revert AOXC__AgentAlreadyRegistered(agent);

        _grantRole(EXTERNAL_AI_AGENT_ROLE, agent);
        _agentRegistry[agent] = AiAgentMetadata({
            contractHash: contractHash, registeredAt: block.timestamp, totalOperations: 0, isActive: true
        });

        activeAgentCount++;
        emit AiAgentRegistered(agent, contractHash);
    }

    function updateDependencies(address hub, address rep) external onlyRole(ADMIN_ROLE) {
        if (hub != address(0)) monitoringHub = IMonitoringHub(hub);
        if (rep != address(0)) reputationManager = IReputationManager(rep);
        emit DependencyUpdated(hub, rep);
    }

    function pause() external onlyRole(ADMIN_ROLE) {
        _pause();
    }

    function unpause() external onlyRole(ADMIN_ROLE) {
        _unpause();
    }

    // --- View Functions ---

    function getAssetBalance(bytes32 assetId) external view returns (uint256) {
        return _assetBalances[assetId];
    }

    function getAllAssetIds() external view returns (bytes32[] memory) {
        return _assetIds;
    }

    // --- Internal Helpers ---

    function _triggerReputation(bytes32 actionType) internal {
        if (address(reputationManager) != address(0)) {
            try reputationManager.processAction(msg.sender, actionType) {} catch {}
        }
    }

    function _logToHub(IMonitoringHub.Severity severity, string memory cat, string memory details) internal {
        if (address(monitoringHub) != address(0)) {
            IMonitoringHub.ForensicLog memory log = IMonitoringHub.ForensicLog({
                source: address(this),
                actor: msg.sender,
                origin: tx.origin,
                related: address(0),
                severity: severity,
                category: cat,
                details: details,
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
                metadata: "",
                proof: ""
            });
            try monitoringHub.logForensic(log) {} catch {}
        }
    }

    /**
     * @dev UUPS upgrade yetkilendirmesi.
     */
    function _authorizeUpgrade(
        address /* newImplementation */
    )
        internal
        override
        onlyRole(ADMIN_ROLE)
    {
        _logToHub(IMonitoringHub.Severity.CRITICAL, "UPGRADE", "Logic upgrade sequence.");
    }

    uint256[40] private _gap;
}
