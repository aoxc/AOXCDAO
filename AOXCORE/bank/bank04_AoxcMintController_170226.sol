// SPDX-License-Identifier: MIT
pragma solidity 0.8.33;

import {Initializable} from "@openzeppelin-upgradeable/proxy/utils/Initializable.sol";
import {AccessControlUpgradeable} from "@openzeppelin-upgradeable/access/AccessControlUpgradeable.sol";
import {PausableUpgradeable} from "@openzeppelin-upgradeable/utils/PausableUpgradeable.sol";
import {UUPSUpgradeable} from "@openzeppelin-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import {AOXCMainEngine} from "core/core01_AoxcMainEngine_170226.sol";
import {AssetBackingLedger} from "./bank03_AssetBackingLedger_170226.sol";
import {IMonitoringHub} from "@api/api29_IMonitoringHub_170226.sol";
import {IReputationManager} from "@interfaces/api08_IReputationManager_170226.sol";

/**
 * @title AOXCMintController
 * @author AOXC Protocol Team
 * @notice Varlık dayanaklı token basımı ve itfası için merkezi hub.
 */
contract AOXCMintController is
    Initializable,
    AccessControlUpgradeable,
    PausableUpgradeable,
    UUPSUpgradeable,
    ReentrancyGuard
{
    bytes32 public constant MINTER_ROLE = keccak256("AOXC_MINTER_ROLE");
    bytes32 public constant ADMIN_ROLE = keccak256("AOXC_ADMIN_ROLE");
    bytes32 public constant OPERATOR_ROLE = keccak256("AOXC_OPERATOR_ROLE");

    AssetBackingLedger public ledger;
    IMonitoringHub public monitoringHub;
    IReputationManager public reputationManager;

    mapping(bytes32 => IERC20) public assetIdToToken;
    mapping(bytes32 => bool) public frozenAssets;
    mapping(bytes32 => uint256) public maxMintPerTx;

    error AOXC__ZeroAddress();
    error AOXC__ExceedsMintLimit(uint256 requested, uint256 limit);
    error AOXC__AssetFrozen(bytes32 assetId);
    error AOXC__InvalidToken();

    event TokensMinted(address indexed caller, address indexed to, uint256 amount, bytes32 indexed assetId);
    event TokensRedeemed(address indexed caller, address indexed from, uint256 amount, bytes32 indexed assetId);

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(address admin, address _ledger, address _monitoringHub, address _reputationManager)
        external
        initializer
    {
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

        _notifyHub(IMonitoringHub.Severity.INFO, "INIT", "MintController Online");
    }

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

        ledger.withdrawAsset(assetId, amount);

        address tokenAddr = address(assetIdToToken[assetId]);
        if (tokenAddr == address(0)) revert AOXC__InvalidToken();

        AOXC(tokenAddr).mint(to, amount);

        if (address(reputationManager) != address(0)) {
            try reputationManager.processAction(to, keccak256("MINT_ASSET")) {} catch {}
        }

        emit TokensMinted(msg.sender, to, amount, assetId);
        _notifyHub(IMonitoringHub.Severity.INFO, "MINT", "Issuance complete");
    }

    function redeem(uint256 amount, bytes32 assetId) external whenNotPaused nonReentrant {
        if (frozenAssets[assetId]) revert AOXC__AssetFrozen(assetId);

        address tokenAddr = address(assetIdToToken[assetId]);
        if (tokenAddr == address(0)) revert AOXC__InvalidToken();

        AOXC(tokenAddr).burn(msg.sender, amount);
        ledger.depositAsset(assetId, amount);

        emit TokensRedeemed(msg.sender, msg.sender, amount, assetId);
        _notifyHub(IMonitoringHub.Severity.INFO, "REDEEM", "Collateral restored");
    }

    function setAssetMapping(bytes32 assetId, address tokenAddress) external onlyRole(ADMIN_ROLE) {
        if (tokenAddress == address(0)) revert AOXC__ZeroAddress();
        assetIdToToken[assetId] = IERC20(tokenAddress);
    }

    function setSafetyLimit(bytes32 assetId, uint256 limit) external onlyRole(ADMIN_ROLE) {
        maxMintPerTx[assetId] = limit;
    }

    function toggleFreeze(bytes32 assetId, bool status) external onlyRole(OPERATOR_ROLE) {
        frozenAssets[assetId] = status;
    }

    function pause() external onlyRole(ADMIN_ROLE) {
        _pause();
    }

    function unpause() external onlyRole(ADMIN_ROLE) {
        _unpause();
    }

    function _notifyHub(IMonitoringHub.Severity severity, string memory action, string memory message) internal {
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
            try monitoringHub.logForensic(log) {} catch {}
        }
    }

    function _authorizeUpgrade(
        address /* newImplementation */
    )
        internal
        override
        onlyRole(ADMIN_ROLE)
    {}

    uint256[43] private _gap;
}
