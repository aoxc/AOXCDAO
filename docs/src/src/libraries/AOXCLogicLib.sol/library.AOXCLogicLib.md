# AOXCLogicLib
[Git Source](https://github.com/aoxc/AOXCDAO/blob/b2b85b9d29ffbff40854f57fed9136e5c88843dc/src/libraries/AOXCLogicLib.sol)

**Title:**
AOXCLogicLib

**Author:**
AOXC Core Engineering

Centralized library for advanced DeFi calculations and reputation scaling.

All calculations use 10000 as basis points (100%).


## State Variables
### BASIS_POINTS

```solidity
uint256 public constant BASIS_POINTS = 10000
```


### SECONDS_PER_YEAR

```solidity
uint256 public constant SECONDS_PER_YEAR = 31536000
```


## Functions
### calculateReputationWeight

Calculates reputation weight based on amount and lock duration.

Linear scaling: Power = Amount * (1 + (Duration / 1 Year) * Multiplier)


```solidity
function calculateReputationWeight(uint256 amount, uint256 duration, uint256 annualMultiplier)
    internal
    pure
    returns (uint256);
```

### applySlippage

Standard slippage check for swaps.


```solidity
function applySlippage(uint256 amount, uint256 slippageBp) internal pure returns (uint256);
```

