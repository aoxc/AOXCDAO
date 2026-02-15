// SPDX-License-Identifier: MIT
pragma solidity 0.8.33;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { ReentrancyGuard } from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import { AccessControl } from "@openzeppelin/contracts/access/AccessControl.sol";
import { Pausable } from "@openzeppelin/contracts/utils/Pausable.sol";

import { AOXCErrors } from "../libraries/AOXCErrors.sol";
import { IReputationManager } from "../interfaces/IReputationManager.sol";
import { IMonitoringHub } from "../interfaces/IMonitoringHub.sol";

/**
 * @title AOXCLockManager
 * @author AOXC Core Engineering
 * @notice Multi-batch asset locking engine for reputation mining and ecosystem power.
 * @dev Integrated with 26-channel MonitoringHub and academic multiplier scaling.
 */
contract AOXCLockManager is ReentrancyGuard, AccessControl, Pausable {
    using SafeERC20 for IERC20;

    // --- Access Control Roles ---
    bytes32 public constant GOVERNANCE_ROLE = keccak256("AOXC_GOVERNANCE_ROLE");
    bytes32 public constant SECURITY_ROLE = keccak256("AOXC_SECURITY_ROLE");

    // --- Structures ---
    struct LockBatch {
        uint256 amount; // Locked AOXC amount
        uint256 startTime; // When the lock started
        uint256 unlockTime; // Maturity date
        uint256 weight; // Calculated multiplier weight (10000 = 1.0x)
        bool claimed; // Is the batch withdrawn?
    }

    // --- Immutables (SCREAMING_SNAKE_CASE) ---
    IERC20 public immutable AOXC;
    IReputationManager public immutable REPUTATION_MANAGER;
    IMonitoringHub public immutable MONITORING_HUB;

    // --- State Variables ---
    mapping(address => LockBatch[]) public userLocks;
    uint256 public totalValueLocked;

    // Constants (Basis Points: 10000 = 1x)
    uint256 public constant MIN_LOCK_DURATION = 7 days;
    uint256 public constant MAX_LOCK_DURATION = 1095 days; // 3 Years
    uint256 public constant PRECISION = 10000;

    // --- Events ---
    event AssetLocked(
        address indexed user,
        uint256 indexed batchId,
        uint256 amount,
        uint256 duration,
        uint256 weight
    );
    event AssetUnlocked(address indexed user, uint256 indexed batchId, uint256 amount);
    event ReputationSyncFailed(address indexed user, string reason);

    /**
     * @notice Initializes the Lock Manager with ecosystem links.
     */
    constructor(address _aoxc, address _rep, address _hub, address _admin) {
        if (
            _aoxc == address(0) || _rep == address(0) || _hub == address(0) || _admin == address(0)
        ) {
            revert AOXCErrors.ZeroAddressDetected();
        }

        AOXC = IERC20(_aoxc);
        REPUTATION_MANAGER = IReputationManager(_rep);
        MONITORING_HUB = IMonitoringHub(_hub);

        _grantRole(DEFAULT_ADMIN_ROLE, _admin);
        _grantRole(GOVERNANCE_ROLE, _admin);
        _grantRole(SECURITY_ROLE, _admin);
    }

    // --- Core Functions ---

    /**
     * @notice Locks AOXC in specific batches to earn reputation and ecosystem power.
     * @param _amount Amount to lock.
     * @param _duration Duration in seconds.
     */
    function lock(uint256 _amount, uint256 _duration) external nonReentrant whenNotPaused {
        if (_amount == 0) revert AOXCErrors.InvalidConfiguration();
        if (_duration < MIN_LOCK_DURATION || _duration > MAX_LOCK_DURATION) {
            revert AOXCErrors.ActionNotAllowed();
        }

        // 1. Calculate Multiplier Weight
        uint256 weight = _calculateWeight(_amount, _duration);

        // 2. Transfer Assets
        AOXC.safeTransferFrom(msg.sender, address(this), _amount);

        // 3. Register Batch
        userLocks[msg.sender].push(
            LockBatch({
                amount: _amount,
                startTime: block.timestamp,
                unlockTime: block.timestamp + _duration,
                weight: weight,
                claimed: false
            })
        );

        unchecked {
            totalValueLocked += _amount;
        }

        // 4. Update Reputation (External Hook)
        try REPUTATION_MANAGER.processAction(msg.sender, keccak256("TOKEN_LOCK")) {
            // Success
        } catch {
            emit ReputationSyncFailed(msg.sender, "LOCK_SYNC");
            _reportToHub(
                IMonitoringHub.Severity.WARNING,
                "REP_SYNC_FAILURE",
                "Reputation update failed during lock",
                60
            );
        }

        uint256 batchId = userLocks[msg.sender].length - 1;
        emit AssetLocked(msg.sender, batchId, _amount, _duration, weight);

        _reportToHub(IMonitoringHub.Severity.INFO, "ASSET_LOCKED", "New lock batch created", 15);
    }

    /**
     * @notice Releases a matured lock batch.
     * @param _batchId The index of the lock batch.
     */
    function unlock(uint256 _batchId) external nonReentrant {
        LockBatch[] storage locks = userLocks[msg.sender];
        if (_batchId >= locks.length) revert AOXCErrors.InvalidItemID(_batchId);

        LockBatch storage batch = locks[_batchId];

        if (batch.claimed) revert AOXCErrors.ActionNotAllowed();
        if (block.timestamp < batch.unlockTime) revert AOXCErrors.ItemLocked();

        // Effect
        batch.claimed = true;

        unchecked {
            totalValueLocked -= batch.amount;
        }

        // Interaction
        AOXC.safeTransfer(msg.sender, batch.amount);

        // Notify Reputation Manager
        try REPUTATION_MANAGER.processAction(msg.sender, keccak256("TOKEN_UNLOCK")) {
            // Success
        } catch {
            emit ReputationSyncFailed(msg.sender, "UNLOCK_SYNC");
            _reportToHub(
                IMonitoringHub.Severity.WARNING,
                "REP_SYNC_FAILURE",
                "Reputation update failed during unlock",
                50
            );
        }

        emit AssetUnlocked(msg.sender, _batchId, batch.amount);
        _reportToHub(IMonitoringHub.Severity.INFO, "ASSET_UNLOCKED", "Lock batch released", 10);
    }

    // --- Internal Logic ---

    /**
     * @dev Linear Multiplier Logic: 10% bonus per month.
     */
    function _calculateWeight(uint256 _amount, uint256 _duration) internal pure returns (uint256) {
        uint256 monthCount = _duration / 30 days;
        if (monthCount == 0) return _amount;

        uint256 multiplier = PRECISION + (monthCount * 1000);
        return (_amount * multiplier) / PRECISION;
    }

    /**
     * @dev Reporting to 26-channel DAO forensic hub.
     */
    function _reportToHub(
        IMonitoringHub.Severity sev,
        string memory cat,
        string memory det,
        uint8 risk
    ) internal {
        if (address(MONITORING_HUB) == address(0)) return;

        IMonitoringHub.ForensicLog memory log = IMonitoringHub.ForensicLog({
            source: address(this),
            actor: msg.sender,
            origin: tx.origin,
            related: address(AOXC),
            severity: sev,
            category: cat,
            details: det,
            riskScore: risk,
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
            actionReq: sev >= IMonitoringHub.Severity.CRITICAL,
            isUpgraded: false,
            environment: 1, // Production
            correlationId: bytes32(0),
            policyHash: bytes32(0),
            sequenceId: 0,
            metadata: "",
            proof: ""
        });

        try MONITORING_HUB.logForensic(log) {} catch {}
    }

    // --- View Functions ---

    function getUserLockCount(address _user) external view returns (uint256) {
        return userLocks[_user].length;
    }

    function getUserLocks(address _user) external view returns (LockBatch[] memory) {
        return userLocks[_user];
    }

    // --- Security ---

    function pause() external onlyRole(SECURITY_ROLE) {
        _pause();
    }

    function unpause() external onlyRole(SECURITY_ROLE) {
        _unpause();
    }
}
