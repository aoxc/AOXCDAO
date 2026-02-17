// SPDX-License-Identifier: MIT
pragma solidity 0.8.33;

import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {AccessControlUpgradeable} from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import {PausableUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

import {IMonitoringHub} from "@interfaces/IMonitoringHub.sol";
import {IReputationManager} from "@interfaces/IReputationManager.sol";

/**
 * @title AOXCRelayerGateway
 * @author AOXC Core Engineering
 * @notice Multi-signature gateway for relayers with Akdeniz V2 Forensic standard.
 * @dev Optimized with inline assembly hashing and wrapped modifier logic for lint compliance.
 */
contract AOXCRelayerGateway is
    Initializable,
    AccessControlUpgradeable,
    PausableUpgradeable,
    UUPSUpgradeable,
    ReentrancyGuard
{
    // --- Roles & Constants ---
    bytes32 public constant RELAYER_ROLE = keccak256("AOXC_RELAYER_ROLE");
    bytes32 public constant UPGRADER_ROLE = keccak256("AOXC_UPGRADER_ROLE");

    // --- State Variables ---
    IMonitoringHub public monitoringHub;
    IReputationManager public reputationManager;
    address public timelock;
    uint256 public requiredConfirmations;

    struct MultiSigTx {
        address target;
        bytes data;
        uint256 confirmations;
        bool executed;
        uint256 nonce;
    }

    mapping(bytes32 => MultiSigTx) public transactions;
    mapping(bytes32 => mapping(address => bool)) public isConfirmed;

    // --- Events ---
    event CallRelayed(address indexed relayer, address indexed target, bool success, uint256 timestamp);
    event TransactionConfirmed(bytes32 indexed txHash, address indexed relayer, uint256 confirmations);
    event ThresholdUpdated(uint256 newThreshold);

    // --- Custom Errors ---
    error AOXC__ThresholdZero();
    error AOXC__AlreadyExecuted();
    error AOXC__AlreadyConfirmed();
    error AOXC__RelayExecutionFailed();
    error AOXC__Unauthorized();
    error AOXC__ZeroAddress();

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(
        address admin,
        address _monitoringHub,
        address _timelock,
        uint256 _required,
        address _reputationManager
    ) external initializer {
        if (admin == address(0) || _monitoringHub == address(0) || _timelock == address(0)) {
            revert AOXC__ZeroAddress();
        }
        if (_required == 0) revert AOXC__ThresholdZero();

        __AccessControl_init();
        __Pausable_init();

        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(UPGRADER_ROLE, admin);

        monitoringHub = IMonitoringHub(_monitoringHub);
        reputationManager = IReputationManager(_reputationManager);
        timelock = _timelock;
        requiredConfirmations = _required;

        _logToHub(IMonitoringHub.Severity.INFO, "INITIALIZE", "Relayer Gateway active");
    }

    /**
     * @notice Relays a call after consensus is reached.
     * @dev Uses assembly for gas-efficient hashing to satisfy forge-lint [asm-keccak256].
     */
    function relayCall(address target, bytes calldata data, uint256 txNonce)
        external
        onlyRole(RELAYER_ROLE)
        nonReentrant
        whenNotPaused
    {
        bytes32 txHash;
        // Optimized assembly hashing for lint compliance and gas efficiency
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, target)
            calldatacopy(add(ptr, 0x20), data.offset, data.length)
            mstore(add(add(ptr, 0x20), data.length), txNonce)
            txHash := keccak256(ptr, add(add(ptr, 0x20), data.length))
        }

        if (transactions[txHash].target == address(0)) {
            transactions[txHash].target = target;
            transactions[txHash].data = data;
            transactions[txHash].nonce = txNonce;
        }

        if (transactions[txHash].executed) revert AOXC__AlreadyExecuted();
        if (isConfirmed[txHash][msg.sender]) revert AOXC__AlreadyConfirmed();

        isConfirmed[txHash][msg.sender] = true;
        transactions[txHash].confirmations++;

        emit TransactionConfirmed(txHash, msg.sender, transactions[txHash].confirmations);

        if (transactions[txHash].confirmations >= requiredConfirmations) {
            _executeTransaction(txHash);
        }
    }

    function _executeTransaction(bytes32 txHash) internal {
        MultiSigTx storage txn = transactions[txHash];
        txn.executed = true;

        (bool success, bytes memory returnData) = txn.target.call(txn.data);

        if (!success) {
            if (returnData.length > 0) {
                assembly {
                    let size := mload(returnData)
                    revert(add(32, returnData), size)
                }
            }
            revert AOXC__RelayExecutionFailed();
        }

        if (address(reputationManager) != address(0)) {
            try reputationManager.processAction(msg.sender, keccak256("RELAYER_SUCCESS")) {} catch {}
        }

        emit CallRelayed(msg.sender, txn.target, true, block.timestamp);
        _logToHub(IMonitoringHub.Severity.INFO, "RELAY_EXECUTED", "Consensus reached and executed");
    }

    // --- Administrative Functions ---

    /**
     * @dev Wrapped modifier logic to reduce bytecode and satisfy forge-lint.
     */
    modifier onlyTimelock() {
        _checkTimelock();
        _;
    }

    function _checkTimelock() internal view {
        if (msg.sender != timelock) revert AOXC__Unauthorized();
    }

    function setThreshold(uint256 _new) external onlyTimelock {
        if (_new == 0) revert AOXC__ThresholdZero();

        requiredConfirmations = _new;
        _logToHub(IMonitoringHub.Severity.WARNING, "CONFIG_UPDATE", "Threshold changed");
        emit ThresholdUpdated(_new);
    }

    /**
     * @dev 26-Channel Forensic Logging Implementation.
     */
    function _logToHub(IMonitoringHub.Severity severity, string memory action, string memory details) internal {
        if (address(monitoringHub) != address(0)) {
            IMonitoringHub.ForensicLog memory log = IMonitoringHub.ForensicLog({
                source: address(this),
                actor: msg.sender,
                origin: tx.origin,
                related: address(0),
                severity: severity,
                category: "RELAYER_GATEWAY",
                details: details,
                riskScore: severity == IMonitoringHub.Severity.CRITICAL ? 85 : 15,
                nonce: 0,
                chainId: block.chainid,
                blockNumber: block.number,
                timestamp: block.timestamp,
                gasUsed: gasleft(),
                value: 0,
                stateRoot: bytes32(0),
                txHash: bytes32(0),
                selector: msg.sig,
                version: 2, // V2 Pro Ultimate
                actionReq: severity >= IMonitoringHub.Severity.CRITICAL,
                isUpgraded: false,
                environment: 1,
                correlationId: bytes32(0),
                policyHash: bytes32(0),
                sequenceId: 0,
                metadata: abi.encodePacked(action),
                proof: ""
            });

            try monitoringHub.logForensic(log) {} catch {}
        }
    }

    function _authorizeUpgrade(address) internal override onlyRole(UPGRADER_ROLE) {
        _logToHub(IMonitoringHub.Severity.CRITICAL, "UPGRADE", "Gateway logic upgraded");
    }

    // Storage gap for upgradeability
    uint256[43] private _gap;
}
