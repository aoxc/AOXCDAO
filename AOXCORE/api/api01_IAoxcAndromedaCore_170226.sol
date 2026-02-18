// SPDX-License-Identifier: MIT
// AOXCDAO Institutional Framework v2.0.0
pragma solidity 0.8.33;

/**
 * @title IAOXCAndromedaCore
 * @author AOXCDAO Institutional Engineering
 * @notice Central coordination interface for the AOXCMainEngine v2 Prime "Andromeda" Ecosystem.
 * @dev Defines the communication protocols between the 11 functional hangars.
 * This interface serves as the "Single Source of Truth" for module authorization
 * and protocol state management, ensuring MiCA and FinCEN compliance through
 * structured governance gates.
 *
 * 🎓 LEVEL: Pro Ultimate Academic
 * 🏛️ MODULE: Core Infrastructure
 * 🛡️ STANDARD: OpenZeppelin 5.5.x Compliance
 */
interface IAOXCAndromedaCore {
    // --- 🏛️ Custom Errors (Gas-Efficient & Diagnostic) ---

    /// @dev Thrown when a non-authorized module attempts a restricted action.
    error Andromeda_UnauthorizedModule(address caller, bytes32 requiredModule);

    /// @dev Thrown when attempting to register a module ID that already exists.
    error Andromeda_ModuleAlreadyAnchored(bytes32 moduleId);

    /// @dev Thrown when a provided hangar address is null or invalid.
    error Andromeda_InvalidHangarAddress(address hangar);

    /// @dev Thrown when the protocol is in a state that prevents the requested action.
    error Andromeda_ProtocolStateLock(ProtocolState currentState);

    // --- 📊 State Enums ---

    /**
     * @notice Operational states of the AOXCMainEngine ecosystem.
     * @custom:state-definition ACTIVE Normal protocol operations.
     * @custom:state-definition EMERGENCY_PAUSE Global circuit breaker triggered.
     * @custom:state-definition UPGRADE_MODE Controlled migration for smart contract upgrades.
     */
    enum ProtocolState {
        ACTIVE,
        EMERGENCY_PAUSE,
        UPGRADE_MODE
    }

    // --- 📑 Structs ---

    /**
     * @notice Structural manifest for an anchored hangar module.
     * @param moduleId Keccak256 hash identifier (e.g., keccak256("GOVERNANCE")).
     * @param hangarAddress Contract address of the functional module.
     * @param version Internal semantic versioning (Major.Minor.Patch).
     * @param isCompliant Regulatory compliance verification status.
     * @param isActive Operational availability status.
     */
    struct HangarManifest {
        bytes32 moduleId;
        address hangarAddress;
        uint256 version;
        bool isCompliant;
        bool isActive;
    }

    // --- 🔔 Events (Institutional Audit Trail) ---

    /**
     * @notice Emitted when a new hangar module is formally anchored to the core.
     * @param moduleId The unique identifier of the module.
     * @param hangarAddress The physical address of the hangar.
     * @param version The semantic version of the anchored module.
     */
    event ModuleAnchored(bytes32 indexed moduleId, address indexed hangarAddress, uint256 version);

    /// @notice Emitted when the protocol transitions between operational states.
    event ProtocolStateTransition(ProtocolState indexed previousState, ProtocolState indexed newState);

    /// @notice Emitted when a hangar's compliance status is updated by the ComplianceRegistry.
    event ComplianceStatusUpdated(bytes32 indexed moduleId, bool status);

    // --- 🛠️ Core View Functions ---

    /**
     * @notice Retrieves the full manifest record of a specific hangar.
     * @param moduleId The unique Keccak256 identifier of the hangar.
     * @return HangarManifest The structured record of the requested module.
     */
    function getHangarManifest(bytes32 moduleId) external view returns (HangarManifest memory);

    /**
     * @notice Validates if a specific address is an authorized hangar for a given module ID.
     * @param caller The address to verify.
     * @param targetModule The module ID they claim to represent.
     * @return bool True if the caller is the registered and active hangar address.
     */
    function isAuthorizedModule(address caller, bytes32 targetModule) external view returns (bool);

    /**
     * @notice Returns the current operational state of the entire ecosystem.
     * @return ProtocolState Current state (Active, Paused, or Upgrading).
     */
    function getProtocolState() external view returns (ProtocolState);

    // --- ✍️ State-Changing Functions (Authorized) ---

    /**
     * @notice Transitions the protocol to a new state.
     * @dev Must be restricted to high-tier governance (AOXCGovernor).
     * @param newState The target state to enter.
     */
    function transitionProtocolState(ProtocolState newState) external;

    /**
     * @notice Anchors (registers) a new functional hangar into the Andromeda ecosystem.
     * @dev This is the primary method for modular expansion.
     * @param moduleId The unique identifier for the module.
     * @param hangarAddress The physical address of the deployed contract.
     * @param version The initial version of the module.
     */
    function anchorHangar(bytes32 moduleId, address hangarAddress, uint256 version) external;

    /**
     * @notice Updates the operational status of an existing hangar.
     * @param moduleId The identifier of the module to modify.
     * @param status The new operational status (true for active).
     */
    function setHangarStatus(bytes32 moduleId, bool status) external;
}
