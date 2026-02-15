// SPDX-License-Identifier: MIT
pragma solidity 0.8.33;

/**
 * @title  IJurisdictionRegistry
 * @notice Institutional interface for regional legal compliance and cross-border regulatory telemetry.
 * @dev    AOXC Ultimate Protocol: Vertical Alignment, High Technical Eloquence, and Audit-Ready NatSpec.
 */
interface IJurisdictionRegistry {
    // --- SECTION: EVENTS ---

    /// @notice Emitted when a jurisdiction is assigned to a user.
    event JurisdictionAssigned(address indexed user, uint256 jurisdictionId, uint256 timestamp);

    /// @notice Emitted when a jurisdiction is revoked from a user.
    event JurisdictionRevoked(address indexed user, uint256 timestamp);

    /// @notice Emitted when a new jurisdiction is registered in the system.
    event JurisdictionRegistered(uint256 jurisdictionId, string name, uint256 timestamp);

    /// @notice Emitted when a jurisdiction entry is removed from the system.
    event JurisdictionRemoved(uint256 jurisdictionId, uint256 timestamp);

    // --- SECTION: REGULATORY OPERATIONS ---

    /**
     * @notice Designates an institutional regional identifier to a specific account.
     * @dev    Should implement administrative access control.
     * @param  user           The target account for regional classification.
     * @param  jurisdictionId The unique identifier of the legal jurisdiction.
     */
    function assignJurisdiction(address user, uint256 jurisdictionId) external;

    /**
     * @notice Invalidates the current regional classification of an account.
     * @param  user The account whose jurisdiction status is to be decommissioned.
     */
    function revokeJurisdiction(address user) external;

    /**
     * @notice Registers a new jurisdiction entry in the registry.
     * @param  jurisdictionId Unique identifier of the jurisdiction.
     * @param  name           Semantic name of the jurisdiction.
     */
    function registerJurisdiction(uint256 jurisdictionId, string calldata name) external;

    /**
     * @notice Removes a jurisdiction entry from the registry.
     * @param  jurisdictionId Unique identifier of the jurisdiction.
     */
    function removeJurisdiction(uint256 jurisdictionId) external;

    // --- SECTION: EXTERNAL VIEWERS ---

    /**
     * @notice Verifies if an account possesses active compliance clearance for transactions.
     * @param  account The subject address for compliance verification.
     * @return allowed Boolean flag indicating the regulatory clearance status.
     */
    function isAllowed(address account) external view returns (bool allowed);

    /**
     * @notice Returns the semantic name of a specific regional jurisdiction.
     * @param  jurisdictionId The identifier for the targeted region.
     * @return name The institutional name string for the jurisdiction.
     */
    function getJurisdictionName(uint256 jurisdictionId) external view returns (string memory name);

    /**
     * @notice Retrieves the designated jurisdiction identifier for a given account.
     * @param  user The account to be queried.
     * @return jurisdictionId The assigned regional index.
     */
    function getUserJurisdiction(address user) external view returns (uint256 jurisdictionId);

    /**
     * @notice Returns the total volume of documented jurisdictions within the registry.
     * @return count Total number of registered regional identifiers.
     */
    function getJurisdictionCount() external view returns (uint256 count);

    /**
     * @notice Returns whether a jurisdiction ID is currently registered.
     * @param  jurisdictionId The identifier to check.
     * @return exists Boolean flag indicating if the jurisdiction exists.
     */
    function jurisdictionExists(uint256 jurisdictionId) external view returns (bool exists);
}
