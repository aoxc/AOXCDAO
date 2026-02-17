// SPDX-License-Identifier: MIT
pragma solidity 0.8.33;

/**
 * @title  IAOXCUpgradeAuthorizer
 * @notice Institutional interface for the AOXC upgrade authorization logic and logic mutations.
 * @dev    AOXC Ultimate Protocol: Vertical Alignment, High Technical Eloquence, and Audit-Ready NatSpec.
 */
interface IAOXCUpgradeAuthorizer {
    // --- SECTION: EVENTS ---
    event UpgradeValidated(address indexed initiator, address indexed implementation, uint256 timestamp);

    // --- SECTION: AUTHORIZATION OPERATIONS ---
    function validateUpgrade(address initiator, address implementation) external;

    // --- SECTION: VIEW OPERATIONS ---
    function isUpgradeAuthorized(address implementation) external view returns (bool authorized);
    function getAuthorizerVersion() external pure returns (uint256 version);
}
