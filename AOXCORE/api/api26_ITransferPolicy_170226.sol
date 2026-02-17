// SPDX-License-Identifier: MIT
pragma solidity 0.8.33;

/**
 * @title  ITransferPolicy
 * @notice Institutional-grade interface for ecosystem-wide transfer validation and compliance enforcement.
 * @dev    AOXC Ultimate Protocol: Vertical Alignment, High Technical Eloquence, and Audit-Ready NatSpec.
 */
interface ITransferPolicy {
    // --- SECTION: EVENTS ---

    /// @notice Emitted when a transfer passes validation.
    event TransferValidated(address indexed from, address indexed to, uint256 amount, uint256 timestamp);

    /// @notice Emitted when a transfer fails validation.
    event TransferRejected(address indexed from, address indexed to, uint256 amount, uint256 timestamp, string reason);

    /// @notice Emitted when policy status changes (activated/deactivated).
    event PolicyStatusChanged(bool active, uint256 timestamp);

    /// @notice Emitted when policy parameters are updated.
    event PolicyParametersUpdated(string parameter, uint256 newValue, uint256 timestamp);

    // --- SECTION: CORE VALIDATION LOGIC ---

    /**
     * @notice Evaluates a proposed transfer against institutional compliance parameters.
     * @dev    Should revert with a Custom Error if the transfer violates active policies.
     * @param  from   The source address of the asset movement.
     * @param  to     The destination address of the asset movement.
     * @param  amount The total volume of assets to be validated.
     */
    function validateTransfer(address from, address to, uint256 amount) external;

    // --- SECTION: STATUS & METADATA ---

    /**
     * @notice Returns the current operational status of the policy engine.
     * @return active Boolean flag indicating if the policy is currently enforced.
     */
    function isPolicyActive() external view returns (bool active);

    /**
     * @notice Returns the institutional identifier of the policy.
     * @return name Semantic string identifying the specific policy implementation.
     */
    function policyName() external pure returns (string memory name);

    /**
     * @notice Returns the cryptographic versioning index of the policy logic.
     * @return version Unsigned integer representing the current iteration.
     */
    function policyVersion() external pure returns (uint256 version);

    // --- SECTION: ADMIN OPERATIONS ---

    /**
     * @notice Activates or deactivates the policy engine.
     * @param  active Boolean flag to set policy status.
     */
    function setPolicyActive(bool active) external;

    /**
     * @notice Updates a numeric parameter of the policy (e.g., maxTxAmount).
     * @param  parameter Semantic identifier of the parameter.
     * @param  newValue  New numeric value for the parameter.
     */
    function updatePolicyParameter(string calldata parameter, uint256 newValue) external;
}
