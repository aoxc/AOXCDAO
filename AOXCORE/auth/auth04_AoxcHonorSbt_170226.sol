// SPDX-License-Identifier: MIT
pragma solidity 0.8.33;

import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {ERC721Upgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import {AccessControlUpgradeable} from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

import {IMonitoringHub} from "@interfaces/IMonitoringHub.sol";
import {AOXCErrors} from "@libraries/AOXCErrors.sol";

/**
 * @title AOXCHonorSBT
 * @author AOXC Core Engineering
 * @notice Soulbound Reputation NFT (SBT) for the AOXC Meritocracy.
 * @dev Levels: 1: Member, 2: Contributor, 3: Expert, 4: Legend.
 * High-fidelity forensic logging integrated for merit changes.
 */
contract AOXCHonorSBT is Initializable, ERC721Upgradeable, AccessControlUpgradeable, UUPSUpgradeable {
    // --- Access Control Roles ---
    bytes32 public constant MINTER_ROLE = keccak256("NFT_ROLE");
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");

    // --- State Variables ---
    IMonitoringHub public monitoringHub;
    uint256 private _nextTokenId;

    mapping(uint256 => uint8) public tokenLevel;
    mapping(address => bool) public hasHonor;
    mapping(address => uint256) private _userTokenId;

    // --- Events ---
    event HonorMinted(address indexed to, uint256 indexed tokenId, uint8 level);
    event LevelUpgraded(uint256 indexed tokenId, uint8 oldLevel, uint8 newLevel);

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    /**
     * @notice Initializes the Honor SBT contract.
     */
    function initialize(address admin, IMonitoringHub _monitoringHub) external initializer {
        if (admin == address(0) || address(_monitoringHub) == address(0)) {
            revert AOXCErrors.ZeroAddressDetected();
        }

        __ERC721_init("AOXC Honor", "AHONOR");
        __AccessControl_init();

        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(UPGRADER_ROLE, admin);
        _grantRole(MINTER_ROLE, admin);

        monitoringHub = _monitoringHub;

        _logToHub(IMonitoringHub.Severity.INFO, "INITIALIZE", "Honor SBT Engine active");
    }

    // --- Core Logic ---

    /**
     * @notice Mints a unique Soulbound Honor NFT to a user.
     */
    function mintHonor(address to, uint8 level) external onlyRole(MINTER_ROLE) {
        if (to == address(0)) revert AOXCErrors.ZeroAddressDetected();
        if (hasHonor[to]) revert AOXCErrors.InvalidConfiguration(); // Already honored

        uint256 tokenId = _nextTokenId++;
        _safeMint(to, tokenId);

        tokenLevel[tokenId] = level;
        hasHonor[to] = true;
        _userTokenId[to] = tokenId;

        emit HonorMinted(to, tokenId, level);
        _logToHub(IMonitoringHub.Severity.INFO, "SBT_MINT", "Merit recognition issued");
    }

    /**
     * @notice Upgrades the merit level of an existing Honor NFT.
     */
    function upgradeLevel(uint256 tokenId, uint8 newLevel) external onlyRole(MINTER_ROLE) {
        if (_ownerOf(tokenId) == address(0)) revert AOXCErrors.InvalidItemID(tokenId);

        uint8 oldLevel = tokenLevel[tokenId];
        tokenLevel[tokenId] = newLevel;

        emit LevelUpgraded(tokenId, oldLevel, newLevel);
        _logToHub(IMonitoringHub.Severity.WARNING, "SBT_UPGRADE", "User merit level elevated");
    }

    // --- Soulbound Enforcement ---

    /**
     * @dev Modern OpenZeppelin v5.x _update hook.
     * Reverts if from != 0 and to != 0 (Transfer between wallets).
     */
    function _update(address to, uint256 tokenId, address auth) internal override returns (address) {
        address from = _ownerOf(tokenId);
        if (from != address(0) && to != address(0)) {
            revert AOXCErrors.ItemLocked(); // Soulbound restriction
        }
        return super._update(to, tokenId, auth);
    }

    // --- View Functions ---

    function getLevel(address user) external view returns (uint8) {
        if (!hasHonor[user]) return 0;
        return tokenLevel[_userTokenId[user]];
    }

    // --- Forensic Forensics ---

    function _logToHub(IMonitoringHub.Severity severity, string memory action, string memory details) internal {
        if (address(monitoringHub) != address(0)) {
            IMonitoringHub.ForensicLog memory log = IMonitoringHub.ForensicLog({
                source: address(this),
                actor: msg.sender,
                origin: tx.origin,
                related: address(0),
                severity: severity,
                category: "REPUTATION_SBT",
                details: details,
                riskScore: severity == IMonitoringHub.Severity.WARNING ? 20 : 5,
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

    function _authorizeUpgrade(address) internal override onlyRole(UPGRADER_ROLE) {
        _logToHub(IMonitoringHub.Severity.CRITICAL, "UPGRADE", "SBT Logic migration");
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721Upgradeable, AccessControlUpgradeable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    uint256[46] private _gap;
}
