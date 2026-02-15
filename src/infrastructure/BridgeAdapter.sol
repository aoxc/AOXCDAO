// SPDX-License-Identifier: MIT
pragma solidity 0.8.33;

/**
 * @title AOXCBridgeAdapter
 * @author AOXC Core Engineering
 * @notice Enterprise-grade cross-chain liquidity gateway with 26-channel forensic telemetry.
 * @dev Optimized for Akdeniz V2. Features: Yul-based hashing, wrapped modifiers, and zero-lint compliance.
 */

import { Initializable } from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import { AccessControlUpgradeable } from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import { PausableUpgradeable } from "@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol";
import { UUPSUpgradeable } from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import { ReentrancyGuard } from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import { SafeERC20, IERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import { IBridgeAdapter } from "../interfaces/IBridgeAdapter.sol";
import { IMonitoringHub } from "../interfaces/IMonitoringHub.sol";
import { IIdentityRegistry } from "../interfaces/IIdentityRegistry.sol";
import { AOXCBaseReporter } from "../monitoring/AOXCBaseReporter.sol";

contract AOXCBridgeAdapter is
    IBridgeAdapter,
    Initializable,
    AccessControlUpgradeable,
    PausableUpgradeable,
    UUPSUpgradeable,
    ReentrancyGuard,
    AOXCBaseReporter
{
    using SafeERC20 for IERC20;

    // --- Access Control Identifiers ---
    bytes32 public constant ADMIN_ROLE = keccak256("AOXC_ADMIN_ROLE");
    bytes32 public constant UPGRADER_ROLE = keccak256("AOXC_UPGRADER_ROLE");

    // --- System Dependencies ---
    IIdentityRegistry public identityRegistry;
    address public timelock;

    // --- Bridge Logic State ---
    struct BridgeRequest {
        address owner;
        address token;
        uint256 amount;
        address recipient;
        uint256 targetChainId;
        bool finalized;
    }

    mapping(bytes32 => BridgeRequest) public requests;
    mapping(bytes32 => bool) private _finalizedTransactions;

    // --- Professional Error Schema ---
    error AOXC__ComplianceViolation();
    error AOXC__AlreadyFinalized();
    error AOXC__Unauthorized();
    error AOXC__RequestNotFound();
    error AOXC__EthAmountMismatch();
    error AOXC__EthRefundFailed();
    error AOXC__ZeroAddressDetected();

    // --- Wrapped Modifiers (Lint-Compliant & Code-Size Optimized) ---

    modifier onlyTimelock() {
        _validateTimelock();
        _;
    }

    /**
     * @dev Internalizing logic to satisfy forge-lint [unwrapped-modifier-logic]
     */
    function _validateTimelock() internal view {
        if (msg.sender != timelock) revert AOXC__Unauthorized();
    }

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    /**
     * @notice Initializes the sentinel bridge with identity and forensic links.
     * @param admin System overseer.
     * @param _monitoringHub Forensic data aggregator.
     * @param _identity Compliance verification registry.
     * @param _timelock Multi-sig or governance execution delay address.
     */
    function initialize(
        address admin,
        address _monitoringHub,
        address _identity,
        address _timelock
    ) external initializer {
        if (
            admin == address(0) ||
            _monitoringHub == address(0) ||
            _identity == address(0) ||
            _timelock == address(0)
        ) {
            revert AOXC__ZeroAddressDetected();
        }

        __AccessControl_init();
        __Pausable_init();

        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(ADMIN_ROLE, admin);
        _grantRole(UPGRADER_ROLE, admin);

        _setMonitoringHub(_monitoringHub);
        identityRegistry = IIdentityRegistry(_identity);
        timelock = _timelock;

        _performForensicLog(
            IMonitoringHub.Severity.INFO,
            "LIFECYCLE",
            "Bridge Adapter Initialized",
            address(0),
            0,
            ""
        );
    }

    // --- External Transactional Logic ---

    /**
     * @inheritdoc IBridgeAdapter
     * @dev Implementation uses Yul-optimized hashing to circumvent forge-lint [asm-keccak256].
     */
    function bridgeAsset(
        uint256 targetChainId,
        address token,
        uint256 amount,
        address recipient
    ) external payable override nonReentrant whenNotPaused returns (bytes32 txHash) {
        if (!identityRegistry.isRegistered(msg.sender)) revert AOXC__ComplianceViolation();

        // Optimized state-caching for assembly block
        uint256 ts = block.timestamp;
        address sender = msg.sender;
        address adapter = address(this);

        assembly {
            let ptr := mload(0x40)
            mstore(ptr, ts)
            mstore(add(ptr, 0x20), sender)
            mstore(add(ptr, 0x40), recipient)
            mstore(add(ptr, 0x60), amount)
            mstore(add(ptr, 0x80), targetChainId)
            mstore(add(ptr, 0xa0), adapter)
            txHash := keccak256(ptr, 0xc0)
        }

        if (token == address(0)) {
            if (msg.value != amount) revert AOXC__EthAmountMismatch();
        } else {
            IERC20(token).safeTransferFrom(msg.sender, address(this), amount);
        }

        requests[txHash] = BridgeRequest({
            owner: msg.sender,
            token: token,
            amount: amount,
            recipient: recipient,
            targetChainId: targetChainId,
            finalized: false
        });

        emit AssetBridged(targetChainId, token, recipient, amount, txHash, block.timestamp);

        _performForensicLog(
            IMonitoringHub.Severity.INFO,
            "BRIDGE_LOCK",
            "Asset Escrowed",
            recipient,
            15,
            abi.encode(txHash)
        );
    }

    /**
     * @notice Confirms the cross-chain settlement after external validation.
     */
    function finalizeBridge(
        address,
        uint256,
        address,
        uint256,
        bytes32 txHash
    ) external onlyTimelock nonReentrant {
        BridgeRequest storage req = requests[txHash];
        if (req.owner == address(0)) revert AOXC__RequestNotFound();
        if (req.finalized) revert AOXC__AlreadyFinalized();

        req.finalized = true;
        _finalizedTransactions[txHash] = true;

        emit BridgeFinalized(txHash, block.timestamp);

        _performForensicLog(
            IMonitoringHub.Severity.INFO,
            "SETTLEMENT",
            "Bridge Request Finalized",
            req.owner,
            0,
            abi.encode(txHash)
        );
    }

    /**
     * @notice Rollback mechanism for rejected or timed-out bridge attempts.
     */
    function cancelAndRefund(
        bytes32 txHash,
        address token,
        uint256 amount
    ) external onlyTimelock nonReentrant {
        BridgeRequest storage req = requests[txHash];
        address owner = req.owner;
        if (owner == address(0)) revert AOXC__RequestNotFound();
        if (req.finalized) revert AOXC__AlreadyFinalized();

        delete requests[txHash];

        if (token == address(0)) {
            (bool success, ) = payable(owner).call{ value: amount }("");
            if (!success) revert AOXC__EthRefundFailed();
        } else {
            IERC20(token).safeTransfer(owner, amount);
        }

        _performForensicLog(
            IMonitoringHub.Severity.WARNING,
            "ROLLBACK",
            "Asset Refund Executed",
            owner,
            5,
            abi.encode(txHash)
        );
    }

    // --- Metadata & Upgradability ---

    function getAdapterName() external pure override returns (string memory) {
        return "AOXC_Sentinel_V2_Ultimate";
    }

    function getSupportedChains() external pure override returns (uint256[] memory) {
        uint256[] memory chains = new uint256[](1);
        chains[0] = 1; // Mainnet target example
        return chains;
    }

    function isTransactionFinalized(bytes32 txHash) external view override returns (bool) {
        return _finalizedTransactions[txHash];
    }

    function _authorizeUpgrade(
        address newImplementation
    ) internal override onlyRole(UPGRADER_ROLE) {
        _performForensicLog(
            IMonitoringHub.Severity.CRITICAL,
            "UPGRADE",
            "Adapter Implementation Migrated",
            newImplementation,
            100,
            ""
        );
    }

    /**
     * @dev Gap reserved for future state extensions (total 50 slots).
     * identityRegistry (1), timelock (1), requests (1), _finalizedTransactions (1).
     * Reporter base uses slots from its own scope.
     */
    uint256[46] private _gap;
}
