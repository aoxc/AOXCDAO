// SPDX-License-Identifier: MIT
/**
 * @title ANDROMEDACORE Institutional Guard
 * @author AOXCDAO Institutional Engineering
 * @notice Central Sector and Policy Layer for the AOXCMainEngine v2 Prime Ecosystem.
 * @dev Optimized for OpenZeppelin 5.5.x.
 * 🎓 LEVEL: Pro Ultimate Academic (Full Functional Security)
 */
pragma solidity 0.8.33;

import {IAOXCAndromedaCore} from "@interfaces/api01_IAoxcAndromedaCore_170226.sol";
import {Initializable} from "@openzeppelin-upgradeable/proxy/utils/Initializable.sol";
import {AccessControlUpgradeable} from "@openzeppelin-upgradeable/access/AccessControlUpgradeable.sol";
import {UUPSUpgradeable} from "@openzeppelin-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract ANDROMEDACORE is
    IAOXCAndromedaCore,
    Initializable,
    AccessControlUpgradeable,
    UUPSUpgradeable,
    ReentrancyGuard
{
    // --- 🏛️ Role Definitions ---
    bytes32 public constant VETO_ROLE = keccak256("VETO_ROLE");
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");
    bytes32 public constant GOVERNANCE_ROLE = keccak256("GOVERNANCE_ROLE");

    // --- 📊 Quantitative Parameters ---
    uint256 public constant MAX_KINETIC_MULTIPLIER = 600;
    uint256 public constant BASE_SCALAR = 100;

    // --- 🛰️ State Storage ---
    ProtocolState private _protocolState;
    bool public rigorousMonetaryPolicyActive;
    uint256 public globalEfficiencyMultiplier;

    // --- 📂 Registries ---
    mapping(bytes32 => HangarManifest) private _hangars;
    mapping(uint256 => address) public sectorRegistry;

    // --- ❌ Logic Errors ---
    error InvalidSectorRange();
    error SectorNotRegistered();
    error MultiplierExceedsLimit();

    // --- 🔔 Events ---
    event SectorLinked(uint256 indexed sectorId, address indexed sectorAddress);
    event SectorRemoved(uint256 indexed sectorId);
    event StabilityPolicyShifted(bool indexed isStrict, uint256 timestamp);
    event KineticCalibrated(uint256 newMultiplier);

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    /**
     * @notice Institutional Initialization
     * @param _admin Primary administrator.
     */
    function initializeAndromeda(address _admin) public initializer {
        if (_admin == address(0)) revert Andromeda_InvalidHangarAddress(address(0));

        __AccessControl_init();

        _grantRole(DEFAULT_ADMIN_ROLE, _admin);
        _grantRole(UPGRADER_ROLE, _admin);
        _grantRole(GOVERNANCE_ROLE, _admin);
        _grantRole(VETO_ROLE, _admin);

        _protocolState = ProtocolState.ACTIVE;
        rigorousMonetaryPolicyActive = true;
        globalEfficiencyMultiplier = BASE_SCALAR;
    }

    // --- 📑 Sector Management ---

    /**
     * @notice Registers a sector-specific logic contract.
     */
    function registerSector(uint256 _sectorId, address _sectorAddress) external onlyRole(GOVERNANCE_ROLE) {
        if (_sectorId == 0 || _sectorId > 7) revert InvalidSectorRange();
        if (_sectorAddress == address(0)) revert Andromeda_InvalidHangarAddress(address(0));

        sectorRegistry[_sectorId] = _sectorAddress;
        emit SectorLinked(_sectorId, _sectorAddress);
    }

    /**
     * @notice Removes a sector from the registry.
     */
    function removeSector(uint256 _sectorId) external onlyRole(GOVERNANCE_ROLE) {
        if (sectorRegistry[_sectorId] == address(0)) revert SectorNotRegistered();

        delete sectorRegistry[_sectorId];
        emit SectorRemoved(_sectorId);
    }

    // --- 📑 IAOXCAndromedaCore Implementation ---

    function getHangarManifest(bytes32 moduleId) external view returns (HangarManifest memory) {
        return _hangars[moduleId];
    }

    function isAuthorizedModule(address caller, bytes32 targetModule) external view returns (bool) {
        return _hangars[targetModule].hangarAddress == caller && _hangars[targetModule].isActive;
    }

    function getProtocolState() external view returns (ProtocolState) {
        return _protocolState;
    }

    function transitionProtocolState(ProtocolState newState) external onlyRole(VETO_ROLE) {
        emit ProtocolStateTransition(_protocolState, newState);
        _protocolState = newState;
    }

    function anchorHangar(bytes32 moduleId, address hangarAddress, uint256 version) external onlyRole(GOVERNANCE_ROLE) {
        if (hangarAddress == address(0)) revert Andromeda_InvalidHangarAddress(address(0));
        if (_hangars[moduleId].hangarAddress != address(0)) {
            revert Andromeda_ModuleAlreadyAnchored(moduleId);
        }

        _hangars[moduleId] = HangarManifest({
            moduleId: moduleId, hangarAddress: hangarAddress, version: version, isCompliant: true, isActive: true
        });

        emit ModuleAnchored(moduleId, hangarAddress, version);
    }

    function setHangarStatus(bytes32 moduleId, bool status) external onlyRole(GOVERNANCE_ROLE) {
        if (_hangars[moduleId].hangarAddress == address(0)) revert SectorNotRegistered();
        _hangars[moduleId].isActive = status;
    }

    // --- ⚖️ Policy Logic ---

    function calibrateGlobalKinetic(uint256 _newMultiplier) external onlyRole(GOVERNANCE_ROLE) {
        if (_newMultiplier > MAX_KINETIC_MULTIPLIER) revert MultiplierExceedsLimit();
        globalEfficiencyMultiplier = _newMultiplier;
        emit KineticCalibrated(_newMultiplier);
    }

    function toggleMonetaryGuard(bool _active) external onlyRole(VETO_ROLE) {
        rigorousMonetaryPolicyActive = _active;
        emit StabilityPolicyShifted(_active, block.timestamp);
    }

    function calculateKineticVotes(uint256 _baseVotes) external view returns (uint256) {
        if (_protocolState == ProtocolState.EMERGENCY_PAUSE) return 0;
        return (_baseVotes * globalEfficiencyMultiplier) / BASE_SCALAR;
    }

    // --- 🏗️ System Authorization ---

    /**
     * @dev Restricts proxy upgrades to the UPGRADER_ROLE.
     * @notice Function mutability restricted to 'view' to satisfy Solc 0.8.33 linting.
     */
    function _authorizeUpgrade(address newImplementation) internal view override onlyRole(UPGRADER_ROLE) {
        if (newImplementation == address(0)) {
            revert Andromeda_InvalidHangarAddress(address(0));
        }
    }

    function supportsInterface(bytes4 interfaceId) public view override(AccessControlUpgradeable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
