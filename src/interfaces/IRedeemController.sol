// SPDX-License-Identifier: MIT
pragma solidity 0.8.33;

/**
 * @title  IRedeemController
 * @notice Institutional interface for regulating token redemption protocols and daily liquidity quotas.
 * @dev    AOXC Ultimate Protocol: Vertical Alignment, High Technical Eloquence, and Audit-Ready NatSpec.
 */
interface IRedeemController {
    // --- SECTION: EVENTS ---

    /// @notice Emitted when a redemption (burn) is executed.
    event RedeemExecuted(address indexed from, uint256 amount, uint256 timestamp);

    /// @notice Emitted when the daily redemption limit is updated.
    event RedeemLimitUpdated(uint256 newLimit, uint256 timestamp);

    /// @notice Emitted when the daily redemption counter is reset.
    event RedeemCounterReset(uint256 timestamp);

    /// @notice Emitted when redemption is paused or resumed.
    event RedeemStatusChanged(bool active, uint256 timestamp);

    // --- SECTION: EXTERNAL FUNCTIONS ---

    /**
     * @notice Executes the permanent removal of tokens from circulation via redemption.
     * @dev    Should implement strict access control and quota verification.
     * @param  from   The account from which tokens will be extracted and neutralized.
     * @param  amount The total volume of assets to be decommissioned.
     */
    function burn(address from, uint256 amount) external;

    /**
     * @notice Configures the maximum permissible asset redemption volume for a 24-hour cycle.
     * @param  newLimit The updated threshold for institutional liquidity exits.
     */
    function setRedeemLimit(uint256 newLimit) external;

    /**
     * @notice Resets the daily redemption counter (typically once per 24h).
     */
    function resetDailyCounter() external;

    /**
     * @notice Activates or deactivates the redemption mechanism.
     * @param  active Boolean flag to set redemption status.
     */
    function setRedeemActive(bool active) external;

    // --- SECTION: VIEW FUNCTIONS ---

    /**
     * @notice Returns the active 24-hour redemption ceiling.
     * @return currentLimit The maximum allowed volume for the current period.
     */
    function getRedeemLimit() external view returns (uint256 currentLimit);

    /**
     * @notice Returns the cumulative volume of assets redeemed within the current 24-hour window.
     * @return dailyTotal The total volume processed since the last reset.
     */
    function getRedeemedToday() external view returns (uint256 dailyTotal);

    /**
     * @notice Returns whether redemption is currently active.
     * @return active Boolean flag indicating if redemption is enabled.
     */
    function isRedeemActive() external view returns (bool active);
}
