// SPDX-License-Identifier: MIT
pragma solidity 0.8.33;

/**
 * @title AOXCLogicLib
 * @author AOXCMainEngine Core Engineering
 * @notice Centralized library for advanced DeFi calculations and reputation scaling.
 * @dev All calculations use 10000 as basis points (100%).
 */
library AOXCLogicLib {
    uint256 public constant BASIS_POINTS = 10000;
    uint256 public constant SECONDS_PER_YEAR = 31536000;

    /**
     * @notice Calculates reputation weight based on amount and lock duration.
     * @dev Linear scaling: Power = Amount * (1 + (Duration / 1 Year) * Multiplier)
     */
    function calculateReputationWeight(uint256 amount, uint256 duration, uint256 annualMultiplier)
        internal
        pure
        returns (uint256)
    {
        if (duration == 0) return amount;

        // Example: 1 year lock with 2x multiplier (20000 BP)
        // Power = amount * (10000 + (31536000/31536000 * 10000)) / 10000 = amount * 2
        uint256 timeFactor = (duration * annualMultiplier) / SECONDS_PER_YEAR;
        return (amount * (BASIS_POINTS + timeFactor)) / BASIS_POINTS;
    }

    /**
     * @notice Standard slippage check for swaps.
     */
    function applySlippage(uint256 amount, uint256 slippageBp) internal pure returns (uint256) {
        return (amount * (BASIS_POINTS - slippageBp)) / BASIS_POINTS;
    }
}
