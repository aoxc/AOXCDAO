// SPDX-License-Identifier: MIT
pragma solidity 0.8.33;

import { Initializable } from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import { ERC1155Upgradeable } from "@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155Upgradeable.sol";
import { AccessControlUpgradeable } from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import { UUPSUpgradeable } from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

import { IMonitoringHub } from "../interfaces/IMonitoringHub.sol";
import { AOXCErrors } from "../libraries/AOXCErrors.sol";

/**
 * @title AOXP (AOXC Experience & Power)
 * @author AOXC Core Engineering
 * @notice Soulbound (SBT) reputation token for the Akdeniz V2 Ecosystem.
 * @dev High-security ERC1155 implementation for non-transferable governance power.
 * Fully compliant with OpenZeppelin 5.x UUPS patterns.
 */
contract AOXP is Initializable, ERC1155Upgradeable, AccessControlUpgradeable, UUPSUpgradeable {
    // --- Roles ---
    bytes32 public constant UPGRADER_ROLE = keccak256("AOXC_UPGRADER_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("AOXC_MINTER_ROLE");
    bytes32 public constant REVOKER_ROLE = keccak256("AOXC_REVOKER_ROLE");

    // --- Constants ---
    uint256 public constant AOXP_ID = 0;
    string public constant NAME = "AOXC Experience Points";
    string public constant SYMBOL = "AOXP";

    // --- Infrastructure ---
    IMonitoringHub public monitoringHub;

    // --- Events ---
    event AOXPAwarded(address indexed to, uint256 amount, string reason);
    event AOXPRevoked(address indexed from, uint256 amount, string reason);
    event PowerSynchronized(address indexed user, uint256 newPower);

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    /**
     * @notice Initializes the AOXP contract with administrative and monitoring parameters.
     * @dev __UUPSUpgradeable_init() is omitted as it does not exist in OpenZeppelin 5.x.
     * @param admin Primary administrator address.
     * @param _monitoringHub Address of the ecosystem's 26-channel Monitoring Hub.
     */
    function initialize(address admin, address _monitoringHub) external initializer {
        if (admin == address(0) || _monitoringHub == address(0)) {
            revert AOXCErrors.ZeroAddressDetected();
        }

        __ERC1155_init("https://api.aoxc.io/metadata/aoxp/{id}.json");
        __AccessControl_init();

        // Note: UUPSUpgradeable in OZ 5.x does not have an __init function.

        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(UPGRADER_ROLE, admin);
        _grantRole(MINTER_ROLE, admin);
        _grantRole(REVOKER_ROLE, admin);

        monitoringHub = IMonitoringHub(_monitoringHub);

        _logToHub(IMonitoringHub.Severity.INFO, "INITIALIZE", "AOXP Soulbound System Active", 5);
    }

    // --- Core Power Logic ---

    /**
     * @notice Synchronizes a user's total AOXP Power to a specific value.
     * @dev Used by ReputationManager to match lock weights exactly.
     */
    function syncPower(address user, uint256 newTotalPower) external onlyRole(MINTER_ROLE) {
        if (user == address(0)) revert AOXCErrors.ZeroAddressDetected();

        uint256 currentPower = balanceOf(user, AOXP_ID);

        if (newTotalPower > currentPower) {
            _mint(user, AOXP_ID, newTotalPower - currentPower, "");
        } else if (newTotalPower < currentPower) {
            _burn(user, AOXP_ID, currentPower - newTotalPower);
        }

        emit PowerSynchronized(user, newTotalPower);
    }

    /**
     * @notice Individually awards XP for specific ecosystem achievements.
     */
    function awardXp(
        address to,
        uint256 amount,
        string calldata reason
    ) external onlyRole(MINTER_ROLE) {
        if (to == address(0)) revert AOXCErrors.ZeroAddressDetected();
        if (amount == 0) revert AOXCErrors.InvalidConfiguration();

        _mint(to, AOXP_ID, amount, bytes(reason));
        _logToHub(IMonitoringHub.Severity.INFO, "AOXP_MINT", reason, 10);
        emit AOXPAwarded(to, amount, reason);
    }

    /**
     * @notice Revokes XP due to lock expiration or security sanctions.
     */
    function revokeXp(
        address from,
        uint256 amount,
        string calldata reason
    ) external onlyRole(REVOKER_ROLE) {
        if (from == address(0)) revert AOXCErrors.ZeroAddressDetected();

        _burn(from, AOXP_ID, amount);
        _logToHub(IMonitoringHub.Severity.WARNING, "AOXP_REVOKE", reason, 40);
        emit AOXPRevoked(from, amount, reason);
    }

    // --- Soulbound Mechanics ---

    /**
     * @dev Hook that ensures tokens are non-transferable (Soulbound).
     * Only minting (from == 0) and burning (to == 0) are permitted.
     */
    function _update(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory values
    ) internal override {
        if (from != address(0) && to != address(0)) {
            revert AOXCErrors.ActionNotAllowed();
        }
        super._update(from, to, ids, values);
    }

    // --- Views ---

    function getPower(address user) external view returns (uint256) {
        return balanceOf(user, AOXP_ID);
    }

    // --- Internal Monitoring ---

    function _logToHub(
        IMonitoringHub.Severity severity,
        string memory action,
        string memory details,
        uint8 riskScore
    ) internal {
        if (address(monitoringHub) != address(0)) {
            IMonitoringHub.ForensicLog memory log = IMonitoringHub.ForensicLog({
                source: address(this),
                actor: msg.sender,
                origin: tx.origin,
                related: address(0),
                severity: severity,
                category: "AOXP_REPUTATION",
                details: details,
                riskScore: riskScore,
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

    // --- Governance ---

    function _authorizeUpgrade(address) internal override onlyRole(UPGRADER_ROLE) {}

    function supportsInterface(
        bytes4 interfaceId
    ) public view override(ERC1155Upgradeable, AccessControlUpgradeable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    /**
     * @dev Gap for future storage variables to prevent collision in upgradeable contracts.
     */
    uint256[43] private _gap;
}
