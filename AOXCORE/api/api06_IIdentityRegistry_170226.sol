// SPDX-License-Identifier: MIT
pragma solidity 0.8.33;

/**
 * @title  IIdentityRegistry
 * @notice Institutional interface for identity verification, KYC telemetry, and account registry.
 * @dev    AOXCMainEngine Ultimate Protocol: Vertical Alignment, High Technical Eloquence, and Audit-Ready NatSpec.
 */
interface IIdentityRegistry {
    // --- SECTION: EVENTS ---
    event IdentityRegistered(address indexed account, string id, uint256 timestamp);
    event IdentityDeregistered(address indexed account, uint256 timestamp);

    // --- SECTION: IDENTITY OPERATIONS ---
    function register(address account, string calldata id) external;
    function deregister(address account) external;

    // --- SECTION: EXTERNAL VIEWERS ---
    function getIdentity(address account) external view returns (string memory identityId);
    function isRegistered(address account) external view returns (bool registered);
    function getRegisteredCount() external view returns (uint256 totalCount);
}
