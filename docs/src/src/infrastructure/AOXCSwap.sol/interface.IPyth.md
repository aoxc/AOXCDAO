# IPyth
[Git Source](https://github.com/aoxc/AOXCDAO/blob/b2b85b9d29ffbff40854f57fed9136e5c88843dc/src/infrastructure/AOXCSwap.sol)


## Functions
### getPriceNoOlderThan


```solidity
function getPriceNoOlderThan(bytes32 id, uint256 age) external view returns (Price memory);
```

## Structs
### Price

```solidity
struct Price {
    int64 price;
    uint64 conf;
    int32 expo;
    uint256 publishTime;
}
```

