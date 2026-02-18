// SPDX-License-Identifier: MIT
pragma solidity 0.8.33;

/**
 * @title  IComplianceRegistry
 * @notice Institutional-grade interface for blacklist enforcement and regulatory compliance management.
 * @dev    AOXCMainEngine Ultimate Protocol: Vertical Alignment, High Technical Eloquence, and Audit-Ready NatSpec.
 */
interface IComplianceRegistry {
    // --- SECTION: EVENTS ---
    event Blacklisted(address indexed account, string reason, uint256 timestamp);
    event Unblacklisted(address indexed account, uint256 timestamp);

    // --- SECTION: REGULATORY OPERATIONS ---
    function addToBlacklist(address account, string calldata reason) external;
    function removeFromBlacklist(address account) external;

    // --- SECTION: EXTERNAL VIEWERS ---
    function isBlacklisted(address account) external view returns (bool restricted);
    function getBlacklistReason(address account) external view returns (string memory reason);
    function getBlacklistCount() external view returns (uint256 count);
}
