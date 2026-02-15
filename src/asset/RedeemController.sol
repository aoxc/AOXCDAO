// SPDX-License-Identifier: MIT
pragma solidity 0.8.33;

import { Initializable } from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import { AccessControlUpgradeable } from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import { PausableUpgradeable } from "@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol";
import { UUPSUpgradeable } from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import { ReentrancyGuard } from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

import { AOXC } from "../core/AOXC.sol";
import { AssetBackingLedger } from "./AssetBackingLedger.sol";
import { IMonitoringHub } from "../interfaces/IMonitoringHub.sol";
import { IReputationManager } from "../interfaces/IReputationManager.sol";

/**
 * @title AOXCRedeemController
 * @notice Manages AOXC token destruction and the release of corresponding collateral backing.
 * @dev Fully compliant with 26-channel MonitoringHub and UUPS Proxy pattern (OZ v5).
 */
contract AOXCRedeemController is
    Initializable,
    AccessControlUpgradeable,
    PausableUpgradeable,
    UUPSUpgradeable,
    ReentrancyGuard
{
    // --- Access Control Roles ---
    bytes32 public constant ADMIN_ROLE = keccak256("AOXC_ADMIN_ROLE");
    bytes32 public constant REDEEMER_ROLE = keccak256("AOXC_REDEEMER_ROLE");

    // --- State Variables ---
    AOXC public token;
    AssetBackingLedger public ledger;
    IMonitoringHub public monitoringHub;
    IReputationManager public reputationManager;

    // --- Custom Errors ---
    error AOXC__ZeroAddress();
    error AOXC__InsufficientTokens();
    error AOXC__InvalidAssetId();

    // --- Events ---
    event TokensRedeemed(
        address indexed caller,
        address indexed from,
        uint256 amount,
        bytes32 assetId
    );
    event BackingReleased(
        address indexed caller,
        bytes32 indexed assetId,
        uint256 amount,
        uint256 timestamp
    );

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    /**
     * @notice Initializes the Redeem Controller.
     */
    function initialize(
        address admin,
        address _token,
        address _ledger,
        address _monitoringHub,
        address _reputationManager
    ) external initializer {
        if (admin == address(0) || _token == address(0) || _ledger == address(0)) {
            revert AOXC__ZeroAddress();
        }

        __AccessControl_init();
        __Pausable_init();

        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(ADMIN_ROLE, admin);
        _grantRole(REDEEMER_ROLE, admin);

        token = AOXC(_token);
        ledger = AssetBackingLedger(_ledger);
        monitoringHub = IMonitoringHub(_monitoringHub);
        reputationManager = IReputationManager(_reputationManager);

        _logToHub(IMonitoringHub.Severity.INFO, "INITIALIZE", "RedeemController Online");
    }

    /**
     * @notice Redeems AOXC tokens and updates collateral records in the ledger.
     */
    function redeem(
        address from,
        uint256 amount,
        bytes32 assetId
    ) external whenNotPaused nonReentrant onlyRole(REDEEMER_ROLE) {
        if (from == address(0)) revert AOXC__ZeroAddress();
        if (assetId == bytes32(0)) revert AOXC__InvalidAssetId();
        if (token.balanceOf(from) < amount) revert AOXC__InsufficientTokens();

        // 1. Update Collateral Record
        ledger.depositAsset(assetId, amount);

        // 2. Token Burning Process
        token.burn(from, amount);

        // 3. Reputation System Integration
        if (address(reputationManager) != address(0)) {
            try reputationManager.processAction(msg.sender, keccak256("TOKEN_REDEEM")) {} catch {}
        }

        emit BackingReleased(msg.sender, assetId, amount, block.timestamp);
        emit TokensRedeemed(msg.sender, from, amount, assetId);

        _logToHub(
            IMonitoringHub.Severity.INFO,
            "TOKEN_REDEEM",
            "Burn and collateral release finalized"
        );
    }

    // --- Governance ---

    function pause() external onlyRole(ADMIN_ROLE) {
        _pause();
        _logToHub(IMonitoringHub.Severity.WARNING, "PAUSE", "Contract execution suspended");
    }

    function unpause() external onlyRole(ADMIN_ROLE) {
        _unpause();
        _logToHub(IMonitoringHub.Severity.WARNING, "UNPAUSE", "Contract execution resumed");
    }

    // --- Internal Helpers ---

    /**
     * @dev High-fidelity 26-channel forensic logging.
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
                category: "REDEEM_CONTROLLER",
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
                environment: 0, // 0: Production
                correlationId: bytes32(0),
                policyHash: bytes32(0),
                sequenceId: 0,
                metadata: abi.encodePacked(action),
                proof: ""
            });

            try monitoringHub.logForensic(log) {} catch {}
        }
    }

    function _authorizeUpgrade(address) internal override onlyRole(ADMIN_ROLE) {
        _logToHub(
            IMonitoringHub.Severity.CRITICAL,
            "UPGRADE",
            "RedeemController upgrade authorized"
        );
    }

    uint256[43] private _gap;
}
