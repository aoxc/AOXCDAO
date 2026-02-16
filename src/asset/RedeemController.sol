// SPDX-License-Identifier: MIT
pragma solidity 0.8.33;

import { Initializable } from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import { AccessControlUpgradeable } from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import { PausableUpgradeable } from "@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol";
import { UUPSUpgradeable } from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import { ReentrancyGuard } from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

import { AOXC } from "../core/AOXC.sol";
import { AssetBackingLedger } from "./AssetBackingLedger.sol";
import { IMonitoringHub } from "@interfaces/IMonitoringHub.sol";
import { IReputationManager } from "@interfaces/IReputationManager.sol";

/**
 * @title AOXCRedeemController
 * @author AOXC Protocol Team
 * @notice Manages the destruction of AOXC tokens and the systematic release of collateral backing.
 * @dev Implements UUPS Proxy pattern (OpenZeppelin v5) and integrates with a 26-channel forensic monitoring system.
 * This contract ensures that token burning is strictly linked to asset ledger updates.
 */
contract AOXCRedeemController is
    Initializable,
    AccessControlUpgradeable,
    PausableUpgradeable,
    UUPSUpgradeable,
    ReentrancyGuard
{
    // --- Access Control Roles ---
    
    /// @notice Role identifier for administrative actions and upgrades.
    bytes32 public constant ADMIN_ROLE = keccak256("AOXC_ADMIN_ROLE");
    
    /// @notice Role identifier for accounts authorized to trigger the redemption process.
    bytes32 public constant REDEEMER_ROLE = keccak256("AOXC_REDEEMER_ROLE");

    // --- State Variables ---

    /// @notice The core AOXC token contract instance.
    AOXC public token;
    
    /// @notice Ledger tracking the underlying asset backing for tokens.
    AssetBackingLedger public ledger;
    
    /// @notice Interface for high-fidelity forensic logging and security monitoring.
    IMonitoringHub public monitoringHub;
    
    /// @notice Interface for the reputation scoring system.
    IReputationManager public reputationManager;

    // --- Custom Errors ---

    error AOXC__ZeroAddress();
    error AOXC__InsufficientTokens();
    error AOXC__InvalidAssetId();
    error AOXC__UnauthorizedUpgrade();

    // --- Events ---

    /**
     * @dev Emitted when tokens are successfully burned for collateral release.
     * @param caller The account that initiated the transaction.
     * @param from The account whose tokens were burned.
     * @param amount The quantity of tokens destroyed.
     * @param assetId The unique identifier of the linked asset.
     */
    event TokensRedeemed(
        address indexed caller, 
        address indexed from, 
        uint256 indexed amount, 
        bytes32 assetId
    );

    /**
     * @dev Emitted when the backing ledger is updated post-redemption.
     * @param caller The account that initiated the release.
     * @param assetId The identifier of the released asset backing.
     * @param amount The value of the backing released.
     * @param timestamp The block timestamp of the operation.
     */
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
     * @notice Initializes the Redeem Controller with necessary external contract references.
     * @param admin Address to be granted administrative and redeemer roles.
     * @param _token Address of the AOXC token contract.
     * @param _ledger Address of the Asset Backing Ledger.
     * @param _monitoringHub Address of the forensic monitoring system.
     * @param _reputationManager Address of the reputation management system.
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
     * @notice Executes the redemption of tokens, burning them and updating the asset ledger.
     * @dev Requirements:
     * - Caller must have `REDEEMER_ROLE`.
     * - Contract must not be paused.
     * - `from` account must have sufficient balance.
     * @param from The address from which tokens will be burned.
     * @param amount The amount of tokens to redeem.
     * @param assetId The unique identifier of the asset being released.
     */
    function redeem(address from, uint256 amount, bytes32 assetId)
        external
        whenNotPaused
        nonReentrant
        onlyRole(REDEEMER_ROLE)
    {
        if (from == address(0)) revert AOXC__ZeroAddress();
        if (assetId == bytes32(0)) revert AOXC__InvalidAssetId();
        
        // Gas Optimization: burn() usually checks balance, but explicit check provides better error UX.
        if (token.balanceOf(from) < amount) revert AOXC__InsufficientTokens();

        // 1. Update Collateral Record
        ledger.depositAsset(assetId, amount);

        // 2. Token Burning Process
        token.burn(from, amount);

        // 3. Reputation System Integration (Non-critical failure path)
        if (address(reputationManager) != address(0)) {
            try reputationManager.processAction(msg.sender, keccak256("TOKEN_REDEEM")) { } catch { }
        }

        emit BackingReleased(msg.sender, assetId, amount, block.timestamp);
        emit TokensRedeemed(msg.sender, from, amount, assetId);

        _logToHub(
            IMonitoringHub.Severity.INFO, "TOKEN_REDEEM", "Burn and collateral release finalized"
        );
    }

    // --- Governance ---

    /**
     * @notice Pauses all redeem operations in case of emergency.
     */
    function pause() external onlyRole(ADMIN_ROLE) {
        _pause();
        _logToHub(IMonitoringHub.Severity.WARNING, "PAUSE", "Contract execution suspended");
    }

    /**
     * @notice Resumes all redeem operations.
     */
    function unpause() external onlyRole(ADMIN_ROLE) {
        _unpause();
        _logToHub(IMonitoringHub.Severity.WARNING, "UNPAUSE", "Contract execution resumed");
    }

    // --- Internal Helpers ---

    /**
     * @dev Submits a forensic log to the Monitoring Hub.
     * @param severity The risk level of the action.
     * @param action Short string identifier for the action.
     * @param details Descriptive text regarding the execution context.
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
                origin: msg.sender, // SECURE: Avoids tx.origin vulnerability
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

            try monitoringHub.logForensic(log) { } catch { }
        }
    }

    /**
     * @dev Internal function to authorize contract upgrades via UUPS.
     * @param newImplementation Address of the new implementation.
     */
    function _authorizeUpgrade(address newImplementation) internal override onlyRole(ADMIN_ROLE) {
        _logToHub(
            IMonitoringHub.Severity.CRITICAL, "UPGRADE", "RedeemController upgrade authorized"
        );
    }

    /// @dev Storage gap for future upgrades (OpenZeppelin standard).
    uint256[43] private _gap;
}
