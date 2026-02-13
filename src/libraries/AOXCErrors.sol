// SPDX-License-Identifier: MIT
pragma solidity 0.8.33;

/**
 * @title AOXCErrors
 * @author AOXC Core Engineering
 * @notice Centralized library for all AOXC Protocol custom errors.
 * @dev Optimized for gas efficiency and Akdeniz V2 26-channel forensic logging.
 * Categories: 1xxx (Access), 2xxx (Finance), 3xxx (Forensic), 4xxx (Assets), 5xxx (Gov), 6xxx (Infra).
 */
library AOXCErrors {
    // --- Access & Security (1000-1999) ---
    error Unauthorized(address actor); // 1001: Caller lacks necessary role
    error OnlyAdminAllowed(); // 1002: Action restricted to ADMIN_ROLE
    error ProtocolPaused(); // 1003: Emergency circuit breaker is active
    error BlacklistedAccount(address account); // 1004: Identity restricted by compliance registry
    error ZeroAddressDetected(); // 1005: Protection against null pointer assignments
    error InvalidConfiguration(); // 1006: Setup parameters are out of bounds
    error RateLimitExceeded(); // 1007: Action frequency exceeds safety limits
    error SecurityAssumptionViolated(); // 1008: MAX SECURITY - Logical boundary breach
    error ThresholdExceeded(); // 1009: MAX SECURITY - Circuit Breaker triggered
    error RiskThresholdReached(); // 1010: MAX SECURITY - Sentinel auto-shutdown
    error SystemFrozen(); // 1011: Heavy circuit breaker active (EmergencyPolicy sync)
    error ActionNotAllowed(); // 1012: General logic restriction (Registry sync)
    error InvalidState(); // 1013: Contract logic state mismatch (ThreatSurface sync)

    // --- Treasury & Finance (2000-2999) ---
    error InsufficientReserves(uint256 bal, uint256 req); // 2001: Vault/Account liquidity failure
    error TransferFailed(); // 2002: Low-level token/ETH call failed
    error InvalidRecipient(); // 2003: Cannot send to self or blackhole address
    error SlippageExceeded(); // 2004: Financial variance higher than tolerance
    error AllowanceExceeded(); // 2005: Spending limit reached for the operator
    error InvariantCheckFailed(); // 2006: MAX SECURITY - Mathematical balance broken

    // --- Monitoring & Forensics (3000-3999) ---
    error InvalidMonitoringHub(); // 3001: Link to the 26-channel hub is broken
    error ForensicPayloadTooLarge(); // 3002: Metadata size exceeds transport limits
    error RiskThresholdExceeded(uint8 score); // 3003: Security risk score blocked the transaction
    error DuplicateNonce(uint256 nonce); // 3004: Replay protection mechanism triggered
    error ForensicDataIncomplete(); // 3005: 26-channel struct fields are missing
    error ForensicLogFailed(); // 3006: Logging bus communication error

    // --- Asset & Game Logic (4000-4999) ---
    error InvalidItemID(uint256 id); // 4001: Asset ID does not exist in the registry
    error MintLimitReached(); // 4002: Maximum supply capacity enforced
    error ItemLocked(); // 4003: Asset is currently in trade or escrow
    error MetadataInconsistent(); // 4004: Cryptographic proof vs. Metadata mismatch

    // --- Governance & Compliance (5000-5999) ---
    error ProposalExpired(uint256 id); // 5001: Voting/Approval period has ended
    error InsufficientReputation(); // 5002: Reputation score too low for this action
    error JurisdictionRestricted(bytes32 region); // 5003: Regional legal compliance block
    error UpgradeNotAuthorized(address impl); // 5004: UUPS consensus validation failed
    error ThresholdNotReached(uint256 req, uint256 cur); // 5005: Multi-sig consensus not achieved
    error ProposalNotActive(); // 5006: Interaction with a non-existent proposal

    // --- Infrastructure & Bridge (6000-6999) ---
    error BridgeLimitReached(); // 6001: Cross-chain capacity maxed for the window
    error InvalidRelayer(); // 6002: Unrecognized or untrusted relay actor
    error SequenceOutOfOrder(); // 6003: Cross-chain bridge packet sync error
}
