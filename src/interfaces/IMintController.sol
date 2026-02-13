// SPDX-License-Identifier: MIT
pragma solidity 0.8.33;

/**
 * @title  IMintController
 * @notice Institutional interface for regulating token issuance protocols and fiscal yearly quotas.
 * @dev    AOXC Ultimate Protocol: Vertical Alignment, High Technical Eloquence, and Audit-Ready NatSpec.
 */
interface IMintController {
    // --- SECTION: EVENTS ---

    /// @notice Emitted when a mint operation is executed.
    event MintExecuted(address indexed to, uint256 amount, uint256 timestamp);

    /// @notice Emitted when the mint limit is updated.
    event MintLimitUpdated(uint256 newLimit, uint256 timestamp);

    /// @notice Emitted when the yearly mint counter is reset.
    event MintCounterReset(uint256 timestamp);

    /// @notice Emitted when minting is paused or resumed.
    event MintStatusChanged(bool active, uint256 timestamp);

    // --- SECTION: EXTERNAL FUNCTIONS ---

    /**
     * @notice Executes the issuance of new tokens into institutional circulation.
     * @dev    Implementation must enforce strict minting limits and administrative roles.
     * @param  to     The destination account for the newly generated assets.
     * @param  amount The total volume of assets to be synthesized.
     */
    function mint(address to, uint256 amount) external;

    /**
     * @notice Configures the maximum permissible token issuance for the current fiscal cycle.
     * @param  newLimit The updated threshold for institutional asset generation.
     */
    function setMintLimit(uint256 newLimit) external;

    /**
     * @notice Resets the yearly mint counter (typically once per fiscal year).
     */
    function resetYearlyCounter() external;

    /**
     * @notice Activates or deactivates the minting mechanism.
     * @param  active Boolean flag to set minting status.
     */
    function setMintActive(bool active) external;

    // --- SECTION: VIEW FUNCTIONS ---

    /**
     * @notice Returns the active token issuance ceiling for the current cycle.
     * @return currentLimit The maximum allowed minting volume.
     */
    function getMintLimit() external view returns (uint256 currentLimit);

    /**
     * @notice Returns the cumulative volume of assets issued within the current fiscal year.
     * @return yearlyTotal The total volume processed since the annual reset.
     */
    function getMintedThisYear() external view returns (uint256 yearlyTotal);

    /**
     * @notice Returns whether minting is currently active.
     * @return active Boolean flag indicating if minting is enabled.
     */
    function isMintActive() external view returns (bool active);
}

