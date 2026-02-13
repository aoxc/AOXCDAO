// SPDX-License-Identifier: MIT
pragma solidity 0.8.33;

import { Initializable } from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {
    UUPSUpgradeable
} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import {
    AccessControlUpgradeable
} from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import {
    ERC20Upgradeable
} from "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import {
    ERC20PermitUpgradeable
} from "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20PermitUpgradeable.sol";
import {
    ERC20VotesUpgradeable
} from "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20VotesUpgradeable.sol";
import {
    PausableUpgradeable
} from "@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol";
import { NoncesUpgradeable } from "@openzeppelin/contracts-upgradeable/utils/NoncesUpgradeable.sol";
import { ReentrancyGuard } from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

import { ITransferPolicy } from "../interfaces/ITransferPolicy.sol";
import { AOXCStorage } from "./AOXCStorage.sol";
import { IAOXCUpgradeAuthorizer } from "../interfaces/IAOXCUpgradeAuthorizer.sol";
import { IMonitoringHub } from "../interfaces/IMonitoringHub.sol";

/**
 * @title  AOXC Token
 * @author AOXC Core Engineering
 * @notice Main governance and utility asset for the AOXC Ecosystem.
 * @dev    Utilizes ERC-7201 Namespaced Storage and UUPS Proxy architecture.
 * Implements high-fidelity 26-channel forensic logging for deep space security.
 */
contract AOXC is
    Initializable,
    ERC20Upgradeable,
    ERC20PermitUpgradeable,
    ERC20VotesUpgradeable,
    AccessControlUpgradeable,
    UUPSUpgradeable,
    PausableUpgradeable,
    ReentrancyGuard
{
    using AOXCStorage for AOXCStorage.MainStorage;

    // --- Access Control Roles ---
    bytes32 public constant ADMIN_ROLE = keccak256("AOXC_ADMIN_ROLE");
    bytes32 public constant UPGRADER_ROLE = keccak256("AOXC_UPGRADER_ROLE");
    bytes32 public constant MINT_ROLE = keccak256("AOXC_MINT_ROLE");
    bytes32 public constant BURN_ROLE = keccak256("AOXC_BURN_ROLE");

    // --- State Variables ---
    IMonitoringHub public monitoringHub;
    uint256 public supplyCap;

    // --- Custom Errors ---
    error AOXC__PolicyViolation();
    error AOXC__UpgradeNotAuthorized();
    error AOXC__EmergencyHaltActive();
    error AOXC__ZeroAddress();
    error AOXC__SupplyCapExceeded(uint256 requested, uint256 cap);

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    /**
     * @notice Initializes the AOXC token infrastructure.
     * @param name_ Token name
     * @param symbol_ Token symbol
     * @param admin Initial administrative authority
     * @param policyEngine Address of the Transfer Policy Engine
     * @param authorizer Address of the Upgrade Authorizer
     * @param _monitoringHub Address of the Forensic Monitoring Hub
     * @param _supplyCap Total supply ceiling
     */
    function initialize(
        string memory name_,
        string memory symbol_,
        address admin,
        address policyEngine,
        address authorizer,
        IMonitoringHub _monitoringHub,
        uint256 _supplyCap
    ) external initializer {
        if (admin == address(0) || address(_monitoringHub) == address(0)) revert AOXC__ZeroAddress();

        __ERC20_init(name_, symbol_);
        __ERC20Permit_init(name_);
        __ERC20Votes_init();
        __AccessControl_init();
        __Pausable_init();

        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(ADMIN_ROLE, admin);
        _grantRole(UPGRADER_ROLE, admin);
        _grantRole(MINT_ROLE, admin);
        _grantRole(BURN_ROLE, admin);

        AOXCStorage.MainStorage storage ds = AOXCStorage.layout();
        ds.transferPolicy = policyEngine;
        ds.upgradeAuthorizer = authorizer;
        ds.policyEnforcementActive = true;
        ds.supplyCap = _supplyCap;

        monitoringHub = _monitoringHub;
        supplyCap = _supplyCap;

        _logToHub(
            IMonitoringHub.Severity.INFO,
            "INITIALIZE",
            "Protocol initialized: Galactic lifeblood active."
        );
    }

    // --- External Logic ---

    /**
     * @notice Mints new AOXC tokens within the supply cap.
     */
    function mint(address to, uint256 amount)
        external
        onlyRole(MINT_ROLE)
        whenNotPaused
        nonReentrant
    {
        _internalMint(to, amount);
    }

    /**
     * @notice Burns AOXC tokens from a specified address.
     */
    function burn(address from, uint256 amount) external whenNotPaused nonReentrant {
        _checkRole(BURN_ROLE, msg.sender);
        _internalBurn(from, amount);
    }

    /**
     * @notice Triggers a total protocol halt for emergency mitigation.
     */
    function toggleEmergencyHalt(bool status) external onlyRole(ADMIN_ROLE) {
        AOXCStorage.layout().isEmergencyHalt = status;

        _logToHub(
            status ? IMonitoringHub.Severity.CRITICAL : IMonitoringHub.Severity.WARNING,
            "EMERGENCY",
            status ? "Core Protocol Halted" : "Core Protocol Resumed"
        );
    }

    // --- Core Overrides ---

    /**
     * @dev Internal update function with integrated Policy Engine checks.
     */
    function _update(address from, address to, uint256 amount)
        internal
        override(ERC20Upgradeable, ERC20VotesUpgradeable)
    {
        AOXCStorage.MainStorage storage ds = AOXCStorage.layout();

        if (ds.isEmergencyHalt) revert AOXC__EmergencyHaltActive();

        // Enforce transfer policies if active and not a mint/burn
        if (
            ds.policyEnforcementActive && ds.transferPolicy != address(0) && from != address(0)
                && to != address(0)
        ) {
            try ITransferPolicy(ds.transferPolicy).validateTransfer(from, to, amount) { }
            catch {
                _logToHub(
                    IMonitoringHub.Severity.WARNING,
                    "POLICY",
                    "Unauthorized transfer vector detected"
                );
                revert AOXC__PolicyViolation();
            }
        }

        super._update(from, to, amount);
    }

    /**
     * @dev Authorizes logic upgrades through a dedicated External Authorizer.
     */
    function _authorizeUpgrade(address newImpl) internal override onlyRole(UPGRADER_ROLE) {
        address authorizer = AOXCStorage.layout().upgradeAuthorizer;
        if (authorizer != address(0)) {
            IAOXCUpgradeAuthorizer(authorizer).validateUpgrade(msg.sender, newImpl);
            _logToHub(
                IMonitoringHub.Severity.CRITICAL, "UPGRADE", "Logic upgrade sequence authorized."
            );
        } else {
            revert AOXC__UpgradeNotAuthorized();
        }
    }

    // --- Helpers & Compliance ---

    function clock() public view override returns (uint48) {
        return uint48(block.number);
    }

    function nonces(address owner)
        public
        view
        override(ERC20PermitUpgradeable, NoncesUpgradeable)
        returns (uint256)
    {
        return super.nonces(owner);
    }

    function _internalMint(address to, uint256 amount) internal {
        if (to == address(0)) revert AOXC__ZeroAddress();
        if (totalSupply() + amount > supplyCap) revert AOXC__SupplyCapExceeded(amount, supplyCap);
        _mint(to, amount);
        _logToHub(IMonitoringHub.Severity.INFO, "MINT", "Supply expansion executed.");
    }

    function _internalBurn(address from, uint256 amount) internal {
        _burn(from, amount);
        _logToHub(IMonitoringHub.Severity.INFO, "BURN", "Supply contraction executed.");
    }

    /**
     * @dev Implementation of high-fidelity 26-channel forensic logging.
     * Maps the entire execution context for real-time risk assessment.
     */
    function _logToHub(
        IMonitoringHub.Severity severity,
        string memory category,
        string memory details
    ) internal {
        if (address(monitoringHub) != address(0)) {
            IMonitoringHub.ForensicLog memory log = IMonitoringHub.ForensicLog({
                source: address(this),
                actor: msg.sender,
                origin: tx.origin,
                related: address(0),
                severity: severity,
                category: category,
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

            try monitoringHub.logForensic(log) { } catch { }
        }
    }

    uint256[43] private _gap;
}
