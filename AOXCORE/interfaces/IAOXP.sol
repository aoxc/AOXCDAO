// SPDX-License-Identifier: MIT
// Academic Grade - AOXC Ultimate Pro Standard v2.0
pragma solidity 0.8.33;

import { IERC165 } from "@openzeppelin/contracts/utils/introspection/IERC165.sol";

/**
 * @title IAOXP
 * @author AOXC Core Engineering
 * @notice Interface for Soulbound Experience Points (XP) and Reputation Badges.
 * @dev Compliant with 2026 standards: Includes ERC-165 for interface detection
 * and explicit supply tracking for Invariant Checkers.
 */
interface IAOXP is IERC165 {
    // --- Custom Errors (2026 Best Practice) ---
    error AOXP__UnauthorizedMinter(address account);
    error AOXP__SoulboundTokenNonTransferable();
    error AOXP__InvalidXpAmount();

    // --- Events ---
    event XpAwarded(address indexed to, uint256 indexed id, uint256 amount);
    event BadgeGranted(address indexed user, uint256 indexed badgeId);

    /**
     * @notice Returns the global total supply of XP/Tokens.
     * @dev Required for AOXCInvariantChecker solvency audits.
     * @return The total circulating supply in 10^18 decimals.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @notice Awards Experience Points (XP) or Badges to a participant.
     * @param to The recipient address.
     * @param id Token/XP category identifier (e.g., 0 for General XP, 1+ for Badges).
     * @param amount The quantity to award.
     * @param data Additional metadata for the transaction (off-chain reference).
     */
    function awardXp(address to, uint256 id, uint256 amount, bytes calldata data) external;

    /**
     * @notice Returns the total XP accumulated by a user.
     * @param user The participant's address.
     * @return The total XP balance for the given user.
     */
    function getUserXp(address user) external view returns (uint256);

    /**
     * @notice Checks if a user possesses a specific badge.
     * @param user The participant's address.
     * @param badgeId The unique identifier of the badge.
     * @return True if the user owns the badge, false otherwise.
     */
    function hasBadge(address user, uint256 badgeId) external view returns (bool);
}
