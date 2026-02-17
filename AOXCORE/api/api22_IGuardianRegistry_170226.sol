// SPDX-License-Identifier: MIT
pragma solidity 0.8.33;

/**
 * @title  IGuardianRegistry
 * @notice Institutional interface for managing emergency responder authorizations.
 * @dev    AOXC Ultimate Protocol: Vertical Alignment & Technical Eloquence.
 */
interface IGuardianRegistry {
    // --- SECTION: EVENTS ---
    event GuardianAdded(address indexed guardian, uint256 timestamp);
    event GuardianRemoved(address indexed guardian, uint256 timestamp);

    // --- SECTION: VIEW FUNCTIONS ---
    /**
     * @notice Returns the authorization status of a potential guardian.
     * @param  account The address to be verified.
     * @return status  Boolean flag indicating institutional authorization.
     */
    function isGuardian(address account) external view returns (bool status);
}
