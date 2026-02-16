# IAggregatorV3
[Git Source](https://github.com/aoxc/AOXCDAO/blob/b2b85b9d29ffbff40854f57fed9136e5c88843dc/src/infrastructure/PriceOracleAdapter.sol)

**Title:**
IAggregatorV3

Interface for Chainlink Price Feeds or compatible aggregators.


## Functions
### latestRoundData


```solidity
function latestRoundData()
    external
    view
    returns (
        uint80 roundId,
        int256 answer,
        uint256 startedAt,
        uint256 updatedAt,
        uint80 answeredInRound
    );
```

### decimals


```solidity
function decimals() external view returns (uint8);
```

