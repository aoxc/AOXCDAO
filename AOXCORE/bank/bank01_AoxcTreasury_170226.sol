// SPDX-License-Identifier: MIT
pragma solidity 0.8.33;

import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {AccessControlUpgradeable} from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import {PausableUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
// Rules: Use standard ReentrancyGuard from @openzeppelin/contracts as per instruction.
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {SafeERC20, IERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import {ITreasury} from "@interfaces/ITreasury.sol";
import {IMonitoringHub} from "@interfaces/IMonitoringHub.sol";
import {IBridgeAdapter} from "@interfaces/IBridgeAdapter.sol";
import {IReputationManager} from "@interfaces/IReputationManager.sol";
import {AOXCErrors} from "@libraries/AOXCErrors.sol";

/**
 * @title Treasury
 * @author AOXC Core Engineering
 * @notice Central ecosystem vault with Akdeniz V2 Forensic standard and cross-chain bridging.
 * @dev Fully compliant with OZ 5.x (No __UUPSUpgradeable_init) and standard ReentrancyGuard.
 */
contract Treasury is
    ITreasury,
    Initializable,
    AccessControlUpgradeable,
    PausableUpgradeable,
    UUPSUpgradeable,
    ReentrancyGuard
{
    using SafeERC20 for IERC20;

    // --- Access Control Roles ---
    bytes32 public constant ADMIN_ROLE = keccak256("AOXC_ADMIN_ROLE");
    bytes32 public constant MANAGER_ROLE = keccak256("AOXC_MANAGER_ROLE");
    bytes32 public constant GUARDIAN_ROLE = keccak256("AOXC_GUARDIAN_ROLE");
    bytes32 public constant UPGRADER_ROLE = keccak256("AOXC_UPGRADER_ROLE");

    // --- System Infrastructure ---
    IMonitoringHub public monitoringHub;
    IReputationManager public reputationManager;
    IBridgeAdapter public bridgeAdapter;
    address public timelock;

    // --- Liquidity State ---
    address[] private _supportedTokensList;
    mapping(address => bool) public isTokenSupported;

    // --- Events ---
    event TokenSupportUpdated(address indexed token, bool status);
    event Deposited(address indexed sender, address indexed token, uint256 amount);
    event Withdrawn(address indexed recipient, address indexed token, uint256 amount);
    event EmergencyAssetReleased(address indexed token, uint256 amount, address recipient);

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    /**
     * @notice Proxy initialization for Akdeniz V2.
     * @dev __UUPSUpgradeable_init is not present in OZ 5.x.
     */
    function initialize(
        address admin,
        address _monitoringHub,
        address _timelock,
        address _bridgeAdapter,
        address _reputationManager
    ) external initializer {
        if (admin == address(0) || _monitoringHub == address(0) || _timelock == address(0)) {
            revert AOXCErrors.ZeroAddressDetected();
        }

        __AccessControl_init();
        __Pausable_init();

        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(ADMIN_ROLE, admin);
        _grantRole(MANAGER_ROLE, admin);
        _grantRole(GUARDIAN_ROLE, admin);
        _grantRole(UPGRADER_ROLE, admin);

        monitoringHub = IMonitoringHub(_monitoringHub);
        timelock = _timelock;
        bridgeAdapter = IBridgeAdapter(_bridgeAdapter);
        reputationManager = IReputationManager(_reputationManager);

        _logToHub(IMonitoringHub.Severity.INFO, "INITIALIZE", "Treasury vault active", 10);
    }

    // --- Implementation of ITreasury ---

    /**
     * @notice Returns the list of all tokens currently supported by the Treasury.
     */
    function getSupportedTokens() external view override returns (address[] memory) {
        return _supportedTokensList;
    }

    /**
     * @notice Returns total reserves value (Simplified balance check).
     */
    function getTotalReserves() external view override returns (uint256 totalReserves) {
        totalReserves = address(this).balance;
        uint256 length = _supportedTokensList.length;
        for (uint256 i = 0; i < length;) {
            totalReserves += IERC20(_supportedTokensList[i]).balanceOf(address(this));
            unchecked {
                ++i;
            }
        }
    }

    /**
     * @notice Primary deposit mechanism for Native and ERC20 assets.
     */
    function deposit(address token, uint256 amount) external payable override whenNotPaused nonReentrant {
        if (token == address(0)) {
            if (msg.value != amount) revert AOXCErrors.InvalidConfiguration();
            emit Deposited(msg.sender, address(0), msg.value);
        } else {
            uint256 balanceBefore = IERC20(token).balanceOf(address(this));
            IERC20(token).safeTransferFrom(msg.sender, address(this), amount);
            uint256 actualAmount = IERC20(token).balanceOf(address(this)) - balanceBefore;
            emit Deposited(msg.sender, token, actualAmount);
        }

        if (address(reputationManager) != address(0)) {
            try reputationManager.processAction(msg.sender, keccak256("TREASURY_DEPOSIT")) {} catch {}
        }
    }

    /**
     * @notice Controlled withdrawal through Governance (Timelock) or authorized Manager roles.
     */
    function withdraw(address token, address to, uint256 amount) external override nonReentrant {
        if (msg.sender != timelock && !hasRole(MANAGER_ROLE, msg.sender)) {
            revert AOXCErrors.Unauthorized(msg.sender);
        }

        _executeTransfer(token, to, amount);

        emit Withdrawn(to, token, amount);
        _logToHub(IMonitoringHub.Severity.INFO, "WITHDRAW", "Asset release executed", 30);
    }

    /**
     * @notice Guardian-led emergency asset recovery.
     */
    function emergencyWithdraw(address token, address to, uint256 amount)
        external
        override
        onlyRole(GUARDIAN_ROLE)
        nonReentrant
    {
        _executeTransfer(token, to, amount);

        emit EmergencyAssetReleased(token, amount, to);
        _logToHub(IMonitoringHub.Severity.CRITICAL, "EMERGENCY_RELEASE", "Guardian override triggered", 90);
    }

    /**
     * @notice Cross-chain liquidity deployment via Bridge Adapter.
     */
    function bridgeOut(uint256 targetChainId, address token, uint256 amount, address recipient)
        external
        payable
        onlyRole(ADMIN_ROLE)
        nonReentrant
    {
        if (getBalance(token) < amount) {
            revert AOXCErrors.InsufficientReserves(getBalance(token), amount);
        }

        if (token != address(0)) {
            IERC20(token).forceApprove(address(bridgeAdapter), amount);
        }

        bridgeAdapter.bridgeAsset{value: msg.value}(targetChainId, token, amount, recipient);

        _logToHub(IMonitoringHub.Severity.INFO, "BRIDGE_OUT", "Cross-chain liquidity move", 40);
    }

    // --- Configuration ---

    function addSupportedToken(address token) external override onlyRole(ADMIN_ROLE) {
        if (token == address(0)) revert AOXCErrors.ZeroAddressDetected();
        if (!isTokenSupported[token]) {
            isTokenSupported[token] = true;
            _supportedTokensList.push(token);
            emit TokenSupportUpdated(token, true);
        }
    }

    function removeSupportedToken(address token) external override onlyRole(ADMIN_ROLE) {
        isTokenSupported[token] = false;
        emit TokenSupportUpdated(token, false);
    }

    function getBalance(address token) public view override returns (uint256) {
        return token == address(0) ? address(this).balance : IERC20(token).balanceOf(address(this));
    }

    // --- Internal Helpers ---

    function _executeTransfer(address token, address to, uint256 amount) internal {
        if (to == address(0)) revert AOXCErrors.InvalidRecipient();
        if (getBalance(token) < amount) {
            revert AOXCErrors.InsufficientReserves(getBalance(token), amount);
        }

        if (token == address(0)) {
            (bool success,) = payable(to).call{value: amount}("");
            if (!success) revert AOXCErrors.TransferFailed();
        } else {
            IERC20(token).safeTransfer(to, amount);
        }
    }

    function _logToHub(IMonitoringHub.Severity severity, string memory action, string memory details, uint8 riskScore)
        internal
    {
        if (address(monitoringHub) != address(0)) {
            IMonitoringHub.ForensicLog memory log = IMonitoringHub.ForensicLog({
                source: address(this),
                actor: msg.sender,
                origin: tx.origin,
                related: address(0),
                severity: severity,
                category: "TREASURY_VAULT",
                details: details,
                riskScore: riskScore,
                nonce: 0,
                chainId: block.chainid,
                blockNumber: block.number,
                timestamp: block.timestamp,
                gasUsed: gasleft(),
                value: msg.value,
                stateRoot: bytes32(0),
                txHash: bytes32(0),
                selector: msg.sig,
                version: 1,
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

    function pause() external onlyRole(ADMIN_ROLE) {
        _pause();
    }

    function unpause() external onlyRole(ADMIN_ROLE) {
        _unpause();
    }

    function _authorizeUpgrade(address) internal override onlyRole(UPGRADER_ROLE) {
        _logToHub(IMonitoringHub.Severity.CRITICAL, "TREASURY_UPGRADE", "Logic upgraded", 100);
    }

    receive() external payable {
        if (msg.value > 0) emit Deposited(msg.sender, address(0), msg.value);
    }

    uint256[43] private _gap;
}
